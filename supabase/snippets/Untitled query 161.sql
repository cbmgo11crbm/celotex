begin;

-- ============================================================================
-- Painel de Poder Operacional - por unidade, aniversários e insights
-- Usa variantes multi-unidade das RPCs de pessoal e viaturas.
-- ============================================================================

create or replace function public.dashboard_personnel_operational_summary(
  p_unit_ids uuid[] default null
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  with
  military as (
    select d.*
    from public.v_military_directory d
    where (p_unit_ids is null or array_length(p_unit_ids, 1) is null or d.unit_id = any(p_unit_ids))
      and d.is_inactive = false
  ),
  totals as (
    select
      count(*) as total,
      count(*) filter (where activity_status = 'ativo') as available,
      count(*) filter (where activity_status = 'afastado') as away,
      count(*) filter (where classification = 'operacional') as operational,
      count(*) filter (where classification = 'administrativo') as administrative
    from military
  ),
  driver as (
    select
      count(*) filter (where driver_license_expiration is not null) as with_license,
      count(*) filter (
        where driver_license_expiration is not null
          and driver_license_expiration < current_date
      ) as expired,
      count(*) filter (
        where driver_license_expiration is not null
          and driver_license_expiration between current_date and current_date + 30
      ) as expiring_30,
      count(*) filter (
        where driver_license_expiration is not null
          and driver_license_expiration >= current_date
          and activity_status = 'ativo'
      ) as drivers_available
    from military
  ),
  ala as (
    select
      platoon as ala,
      count(*) as total,
      count(*) filter (where activity_status = 'ativo') as available
    from military
    where platoon is not null
    group by platoon
  ),
  dl_cat as (
    select
      driver_license_category as category,
      count(*) as qualified,
      count(*) filter (where activity_status = 'ativo') as available,
      count(*) filter (where activity_status <> 'ativo') as away,
      count(*) filter (
        where driver_license_expiration is not null
          and driver_license_expiration between current_date and current_date + 30
      ) as expiring_30,
      count(*) filter (
        where driver_license_expiration is not null
          and driver_license_expiration < current_date
      ) as expired
    from military
    where driver_license_category is not null
    group by driver_license_category
  ),
  rank_stats as (
    select
      rank_order,
      rank_code,
      rank_name,
      count(*) as total,
      count(*) filter (where activity_status = 'ativo') as available,
      count(*) filter (where activity_status = 'afastado') as away,
      count(*) filter (where classification = 'operacional') as operational,
      count(*) filter (where classification = 'administrativo') as administrative
    from military
    group by rank_order, rank_code, rank_name
  ),
  leaves_source as (
    select
      l.id,
      l.military_id,
      d.full_name,
      d.war_name,
      d.rank_code,
      d.rank_order,
      d.unit_acronym,
      lt.name as leave_type_name,
      l.start_date,
      l.end_date,
      l.is_indefinite
    from public.leaves l
    join public.v_military_directory d on d.id = l.military_id
    join public.leave_types lt on lt.id = l.leave_type_id
    where (p_unit_ids is null or array_length(p_unit_ids, 1) is null or d.unit_id = any(p_unit_ids))
      and d.is_inactive = false
      and l.start_date <= current_date
      and (
        l.is_indefinite = true
        or coalesce(l.end_date, current_date) >= current_date
      )
  ),
  leaves_by_type as (
    select
      leave_type_name,
      count(*) as total,
      count(*) filter (where start_date <= current_date and (end_date is null or end_date >= current_date)) as current
    from leaves_source
    group by leave_type_name
  ),
  current_leaves as (
    select
      id,
      war_name,
      rank_code,
      unit_acronym,
      leave_type_name,
      start_date,
      end_date,
      is_indefinite
    from leaves_source
    order by rank_order, war_name
    limit 20
  ),
  upcoming_returns as (
    select
      id,
      war_name,
      rank_code,
      unit_acronym,
      leave_type_name,
      start_date,
      end_date,
      is_indefinite
    from leaves_source
    where end_date is not null
      and end_date > current_date
      and end_date <= current_date + 30
    order by end_date, rank_order, war_name
    limit 20
  ),
  by_unit as (
    select
      unit_id,
      unit_acronym,
      unit_name,
      count(*) as total,
      count(*) filter (where activity_status = 'ativo') as available,
      count(*) filter (where activity_status = 'afastado') as away,
      count(*) filter (where classification = 'operacional') as operational,
      count(*) filter (where classification = 'administrativo') as administrative
    from military
    group by unit_id, unit_acronym, unit_name
  ),
  sections_agg as (
    select
      s.id as section_id,
      s.acronym as section_acronym,
      s.name as section_name,
      count(distinct ms.military_id) as total,
      count(distinct ms.military_id) filter (where m.activity_status = 'ativo') as available,
      count(distinct ms.military_id) filter (where m.activity_status = 'afastado') as away
    from military m
    join public.military_sections ms on ms.military_id = m.id
    join public.sections s on s.id = ms.section_id
    group by s.id, s.acronym, s.name
  ),
  birthdays_source as (
    select
      id,
      war_name,
      rank_code,
      rank_order,
      unit_acronym,
      birth_date,
      extract(month from birth_date) as m,
      extract(day from birth_date) as d,
      make_date(extract(year from current_date)::int, extract(month from birth_date)::int, extract(day from birth_date)::int) as this_year,
      case
        when make_date(extract(year from current_date)::int, extract(month from birth_date)::int, extract(day from birth_date)::int) < current_date
          then make_date(extract(year from current_date)::int + 1, extract(month from birth_date)::int, extract(day from birth_date)::int)
        else make_date(extract(year from current_date)::int, extract(month from birth_date)::int, extract(day from birth_date)::int)
      end as next_birthday
    from military
    where birth_date is not null
  ),
  birthdays_calc as (
    select
      *,
      (next_birthday - current_date) as days_until
    from birthdays_source
  ),
  b_today as (
    select *
    from birthdays_calc
    where days_until = 0
    order by rank_order, war_name
    limit 20
  ),
  b_next7 as (
    select *
    from birthdays_calc
    where days_until > 0 and days_until <= 7
    order by days_until, rank_order, war_name
    limit 50
  ),
  b_next30 as (
    select *
    from birthdays_calc
    where days_until > 7 and days_until <= 30
    order by days_until, rank_order, war_name
    limit 100
  ),
  insights_raw as (
    select
      'drivers_expiring_30'::text as code,
      'warning'::text as severity,
      format('%s CNHs vencem nos próximos 30 dias.', coalesce((select expiring_30 from driver), 0)) as message,
      coalesce((select expiring_30 from driver), 0) as weight
    union all
    select
      'drivers_expired',
      'error',
      format('%s CNHs já estão vencidas.', coalesce((select expired from driver), 0)),
      coalesce((select expired from driver), 0)
    union all
    select
      'leaves_upcoming_returns',
      'info',
      format('%s militares retornam de afastamento nos próximos 30 dias.', coalesce((select count(*) from upcoming_returns), 0)),
      coalesce((select count(*) from upcoming_returns), 0)
  ),
  insights_filtered as (
    select *
    from insights_raw
    where weight > 0
  )
  select jsonb_build_object(
    'context', jsonb_build_object(
      'unitIds', p_unit_ids,
      'generatedAt', now(),
      'reference', jsonb_build_object(
        'mode', 'current',
        'timestamp', now()
      ),
      'population', jsonb_build_object(
        'totalCounted', coalesce((select total from totals), 0)
      )
    ),
    'totals', (
      select jsonb_build_object(
        'total', coalesce(total, 0),
        'available', coalesce(available, 0),
        'operational', coalesce(operational, 0),
        'administrative', coalesce(administrative, 0),
        'away', coalesce(away, 0),
        'inCourse', 0
      )
      from totals
    ),
    'availability', (
      select jsonb_build_object(
        'rate', case when total > 0 then available::numeric / total else 0 end,
        'percentage', case when total > 0 then round(available::numeric * 100 / total, 1) else 0 end,
        'available', coalesce(available, 0),
        'total', coalesce(total, 0),
        'formula', 'available / total'
      )
      from totals
    ),
    'classification', (
      select jsonb_build_object(
        'operational', jsonb_build_object(
          'count', coalesce(operational, 0),
          'percentageOfTotal', case when total > 0 then round(operational::numeric * 100 / total, 1) else 0 end
        ),
        'administrative', jsonb_build_object(
          'count', coalesce(administrative, 0),
          'percentageOfTotal', case when total > 0 then round(administrative::numeric * 100 / total, 1) else 0 end
        )
      )
      from totals
    ),
    'statusBreakdown', jsonb_build_object(
      'available', jsonb_build_object(
        'typeCode', 'DISPONIVEL',
        'typeName', 'Disponíveis',
        'count', coalesce((select available from totals), 0),
        'percentageOfTotal', case when (select total from totals) > 0
          then round((select available::numeric * 100 / total from totals), 1)
          else 0 end
      ),
      'other', jsonb_build_object(
        'typeCode', 'OUTROS',
        'typeName', 'Outros',
        'count', greatest(coalesce((select total from totals), 0) - coalesce((select available from totals), 0), 0),
        'percentageOfTotal', case when (select total from totals) > 0
          then round((greatest(coalesce((select total from totals), 0) - coalesce((select available from totals), 0), 0))::numeric * 100 / (select total from totals), 1)
          else 0 end
      )
    ),
    'byAla', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'ala', a.ala,
            'total', a.total,
            'available', a.available,
            'away', a.total - a.available,
            'availabilityRate', case when a.total > 0 then a.available::numeric / a.total else 0 end,
            'availabilityPercentage', case when a.total > 0 then round(a.available::numeric * 100 / a.total, 1) else 0 end
          )
          order by a.ala
        )
        from ala a
      ),
      jsonb_build_array()
    ),
    'byUnit', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'unitId', bu.unit_id,
            'unitAcronym', bu.unit_acronym,
            'unitName', bu.unit_name,
            'total', bu.total,
            'available', bu.available,
            'away', bu.away,
            'operational', bu.operational,
            'administrative', bu.administrative,
            'availabilityPercentage', case when bu.total > 0 then round(bu.available::numeric * 100 / bu.total, 1) else 0 end
          )
          order by bu.unit_acronym
        )
        from by_unit bu
      ),
      jsonb_build_array()
    ),
    'byRank', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'rankOrder', rs.rank_order,
            'rankCode', rs.rank_code,
            'rankName', rs.rank_name,
            'total', rs.total,
            'available', rs.available,
            'away', rs.away,
            'operational', rs.operational,
            'administrative', rs.administrative
          )
          order by rs.rank_order, rs.rank_code
        )
        from rank_stats rs
      ),
      jsonb_build_array()
    ),
    'bySection', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'sectionId', s.section_id,
            'sectionAcronym', s.section_acronym,
            'sectionName', s.section_name,
            'total', s.total,
            'available', s.available,
            'away', s.away,
            'availabilityPercentage', case when s.total > 0 then round(s.available::numeric * 100 / s.total, 1) else 0 end
          )
          order by s.section_acronym
        )
        from sections_agg s
      ),
      jsonb_build_array()
    ),
    'driverLicenses', (
      select jsonb_build_object(
        'summary', jsonb_build_object(
          'withLicense', coalesce(with_license, 0),
          'driversAvailable', coalesce(drivers_available, 0),
          'expired', coalesce(expired, 0),
          'expiringIn30Days', coalesce(expiring_30, 0)
        ),
        'byCategory', coalesce(
          (
            select jsonb_agg(
              jsonb_build_object(
                'category', c.category,
                'qualified', c.qualified,
                'available', c.available,
                'away', c.away,
                'expiringIn30Days', c.expiring_30,
                'expired', c.expired
              )
              order by c.category
            )
            from dl_cat c
          ),
          jsonb_build_array()
        )
      )
      from driver
    ),
    'leaves', jsonb_build_object(
      'byType', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'leaveTypeName', lt.leave_type_name,
              'total', lt.total,
              'current', lt.current
            )
            order by lt.leave_type_name
          )
          from leaves_by_type lt
        ),
        jsonb_build_array()
      ),
      'currentLeaves', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'id', c.id,
              'warName', c.war_name,
              'rankCode', c.rank_code,
              'unitAcronym', c.unit_acronym,
              'leaveTypeName', c.leave_type_name,
              'startDate', c.start_date,
              'endDate', c.end_date,
              'isIndefinite', c.is_indefinite
            )
          )
          from current_leaves c
        ),
        jsonb_build_array()
      ),
      'upcomingReturns', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'id', u.id,
              'warName', u.war_name,
              'rankCode', u.rank_code,
              'unitAcronym', u.unit_acronym,
              'leaveTypeName', u.leave_type_name,
              'startDate', u.start_date,
              'EndDate', u.end_date,
              'isIndefinite', u.is_indefinite
            )
          )
          from upcoming_returns u
        ),
        jsonb_build_array()
      )
    ),
    'birthdays', jsonb_build_object(
      'today', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'warName', b.war_name,
              'rankCode', b.rank_code,
              'unitAcronym', b.unit_acronym,
              'birthDate', b.birth_date,
              'daysUntil', 0
            )
          )
          from b_today b
        ),
        jsonb_build_array()
      ),
      'next7Days', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'warName', b.war_name,
              'rankCode', b.rank_code,
              'unitAcronym', b.unit_acronym,
              'birthDate', b.birth_date,
              'daysUntil', b.days_until
            )
          )
          from b_next7 b
        ),
        jsonb_build_array()
      ),
      'next30Days', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'warName', b.war_name,
              'rankCode', b.rank_code,
              'unitAcronym', b.unit_acronym,
              'birthDate', b.birth_date,
              'daysUntil', b.days_until
            )
          )
          from b_next30 b
        ),
        jsonb_build_array()
      )
    ),
    'insights', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'code', i.code,
            'severity', i.severity,
            'message', i.message
          )
          order by i.severity desc, i.code
        )
        from insights_filtered i
      ),
      jsonb_build_array()
    ),
    'meta', jsonb_build_object('version', 1)
  );
$$;

revoke all on function public.dashboard_personnel_operational_summary(uuid[]) from public;
grant execute on function public.dashboard_personnel_operational_summary(uuid[]) to authenticated;

create or replace function public.dashboard_vehicle_operational_summary(
  p_unit_ids uuid[] default null
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  with
  vehicles as (
    select v.*
    from public.vehicles v
    where (p_unit_ids is null or array_length(p_unit_ids, 1) is null or v.unit_id = any(p_unit_ids))
      and coalesce(v.is_inactive, false) = false
  ),
  totals as (
    select
      count(*) as total,
      count(*) filter (where status = 'ativo') as active,
      count(*) filter (where status = 'baixado') as withdrawn,
      count(*) filter (where status = 'cautelado') as cauteladas
    from vehicles
  ),
  conservation as (
    select
      count(*) as total,
      count(*) filter (where conservation_state = 'novo') as novo,
      count(*) filter (where conservation_state = 'bom') as bom,
      count(*) filter (where conservation_state = 'regular') as regular,
      count(*) filter (where conservation_state = 'ruim') as ruim,
      count(*) filter (where conservation_state = 'inservivel') as inservivel
    from vehicles
  ),
  conservation_by_state as (
    select
      conservation_state as state,
      count(*) as count,
      round(count(*)::numeric * 100 / nullif((select total from conservation), 0), 1) as percentage_of_total
    from vehicles
    group by conservation_state
  ),
  type_map as (
    select
      v.id,
      v.vtr,
      case
        when v.vtr ilike 'ABT%' then 'ABT'
        when v.vtr ilike 'ABR%' then 'ABR'
        when v.vtr ilike 'AR%' then 'AR'
        when v.vtr ilike 'ASA%' then 'ASA'
        when v.vtr ilike 'UR%' then 'UR'
        when v.vtr ilike 'APA%' then 'APA'
        when v.vtr ilike 'AT%' then 'AT'
        else 'OUTROS'
      end as type_code
    from vehicles v
  ),
  by_type as (
    select
      type_code,
      count(*) as total,
      count(*) filter (where status = 'ativo') as active,
      count(*) filter (where status = 'baixado') as withdrawn,
      count(*) filter (where status = 'cautelado') as cauteladas
    from type_map tm
    join vehicles v on v.id = tm.id
    group by type_code
  ),
  by_unit as (
    select
      v.unit_id,
      u.acronym as unit_acronym,
      u.name as unit_name,
      count(*) as total,
      count(*) filter (where status = 'ativo') as active,
      count(*) filter (where status = 'baixado') as withdrawn,
      count(*) filter (where status = 'cautelado') as cauteladas
    from vehicles v
    join public.units u on u.id = v.unit_id
    group by v.unit_id, u.acronym, u.name
  ),
  matrix as (
    select
      v.unit_id,
      u.acronym as unit_acronym,
      t.type_code,
      count(*) as total,
      count(*) filter (where v.status = 'ativo') as active
    from vehicles v
    join type_map t on t.id = v.id
    join public.units u on u.id = v.unit_id
    group by v.unit_id, u.acronym, t.type_code
  )
  select jsonb_build_object(
    'context', jsonb_build_object(
      'unitIds', p_unit_ids,
      'generatedAt', now(),
      'reference', jsonb_build_object(
        'mode', 'current',
        'timestamp', now()
      ),
      'population', jsonb_build_object(
        'totalCounted', coalesce((select total from totals), 0)
      )
    ),
    'totals', (
      select jsonb_build_object(
        'total', coalesce(total, 0),
        'active', coalesce(active, 0),
        'withdrawn', coalesce(withdrawn, 0),
        'cauteladas', coalesce(cauteladas, 0)
      )
      from totals
    ),
    'availability', (
      select jsonb_build_object(
        'rate', case when total > 0 then active::numeric / total else 0 end,
        'percentage', case when total > 0 then round(active::numeric * 100 / total, 1) else 0 end,
        'active', coalesce(active, 0),
        'total', coalesce(total, 0),
        'formula', 'active / total'
      )
      from totals
    ),
    'conservation', (
      select jsonb_build_object(
        'total', coalesce(total, 0),
        'byState', coalesce(
          (
            select jsonb_agg(
              jsonb_build_object(
                'state', c.state,
                'count', c.count,
                'percentageOfTotal', coalesce(c.percentage_of_total, 0)
              )
              order by c.state
            )
            from conservation_by_state c
          ),
          jsonb_build_array()
        ),
        'poorOrWorse', jsonb_build_object(
          'count', coalesce((
            select ruim + inservivel from conservation
          ), 0),
          'percentageOfTotal', coalesce((
            select case when total > 0 then round((ruim + inservivel)::numeric * 100 / total, 1) else 0 end from conservation
          ), 0)
        )
      )
      from conservation
    ),
    'byType', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'typeCode', bt.type_code,
            'total', bt.total,
            'active', bt.active,
            'withdrawn', bt.withdrawn,
            'cauteladas', bt.cauteladas
          )
          order by bt.type_code
        )
        from by_type bt
      ),
      jsonb_build_array()
    ),
    'byUnit', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'unitId', bu.unit_id,
            'unitAcronym', bu.unit_acronym,
            'unitName', bu.unit_name,
            'total', bu.total,
            'active', bu.active,
            'withdrawn', bu.withdrawn,
            'cauteladas', bu.cauteladas,
            'availabilityPercentage', case when bu.total > 0 then round(bu.active::numeric * 100 / bu.total, 1) else 0 end
          )
          order by bu.unit_acronym
        )
        from by_unit bu
      ),
      jsonb_build_array()
    ),
    'matrixTypeByUnit', (
      select jsonb_build_object(
        'units', coalesce(
          (
            select jsonb_agg(
              jsonb_build_object(
                'unitId', m.unit_id,
                'unitAcronym', m.unit_acronym
              )
              order by m.unit_acronym
            )
            from matrix m
          ),
          jsonb_build_array()
        ),
        'types', coalesce(
          (
            select jsonb_agg(distinct m.type_code order by m.type_code)
            from matrix m
          ),
          jsonb_build_array()
        ),
        'cells', coalesce(
          (
            select jsonb_agg(
              jsonb_build_object(
                'unitId', m.unit_id,
                'typeCode', m.type_code,
                'total', m.total,
                'active', m.active,
                'availabilityPercentage', case when m.total > 0 then round(m.active::numeric * 100 / m.total, 1) else 0 end
              )
            )
            from matrix m
          ),
          jsonb_build_array()
        )
      )
    ),
    'attentionVehicles', jsonb_build_array(),
    'combinedIndicators', jsonb_build_object(
      'driversAvailable', null,
      'activeVehicles', coalesce((select active from totals), 0),
      'ratioDriversPerActiveVehicle', null
    ),
    'insights', jsonb_build_array(),
    'meta', jsonb_build_object('version', 1)
  );
$$;

revoke all on function public.dashboard_vehicle_operational_summary(uuid[]) from public;
grant execute on function public.dashboard_vehicle_operational_summary(uuid[]) to authenticated;

commit;

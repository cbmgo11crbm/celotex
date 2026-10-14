begin;

-- 0031_vehicle_state_status_rpcs_v2.sql
-- Versão inicial de experimento: ajusta parcialmente o dashboard de viaturas
-- para usar as novas tabelas vehicle_conservation_states e vehicle_statuses.
--
-- IMPORTANTE: esta versão mantém o formato atual do JSON, mas continua
-- utilizando os enums existentes em alguns pontos. Avaliar cuidadosamente
-- no ambiente de testes antes de promover em produção.

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
  age_years_v as (
    select
      case
        when year is null then null
        else extract(year from current_date)::int - year::int
      end as age
    from vehicles
  ),
  age_buckets_v as (
    select
      case
        when age is null then 'sem_info'
        when age < 5 then '<5'
        when age between 5 and 9 then '5-9'
        when age between 10 and 14 then '10-14'
        when age between 15 and 19 then '15-19'
        else '20+'
      end as bucket,
      case
        when age is null then 99
        when age < 5 then 0
        when age between 5 and 9 then 1
        when age between 10 and 14 then 2
        when age between 15 and 19 then 3
        else 4
      end as sort_order,
      count(*) as total
    from age_years_v
    group by 1, 2
  ),
  conservation_catalog as (
    select id, code, name, sort_order
    from public.vehicle_conservation_states
    where is_active = true
  ),
  conservation_by_state as (
    select
      cc.code as state,
      count(v.id) as count,
      round(count(v.id)::numeric * 100 / nullif((select count(*) from vehicles), 0), 1) as percentage_of_total
    from conservation_catalog cc
    left join vehicles v on v.conservation_state_id = cc.id
    group by cc.code, cc.sort_order
  ),
  conservation_totals as (
    select
      count(*) as total,
      count(*) filter (where conservation_state = 'novo') as novo,
      count(*) filter (where conservation_state = 'bom') as bom,
      count(*) filter (where conservation_state = 'regular') as regular,
      count(*) filter (where conservation_state = 'ruim') as ruim,
      count(*) filter (where conservation_state = 'inservivel') as inservivel
    from vehicles
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
        'total', coalesce(ct.total, 0),
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
            select ruim + inservivel from conservation_totals
          ), 0),
          'percentageOfTotal', coalesce((
            select case when total > 0 then round((ruim + inservivel)::numeric * 100 / total, 1) else 0 end from conservation_totals
          ), 0)
        )
      )
      from conservation_totals ct
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
    'meta', jsonb_build_object('version', 2)
  );
$$;

revoke all on function public.dashboard_vehicle_operational_summary(uuid[]) from public;
grant execute on function public.dashboard_vehicle_operational_summary(uuid[]) to authenticated;

commit;

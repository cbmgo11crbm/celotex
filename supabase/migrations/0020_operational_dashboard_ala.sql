begin;

-- ============================================================================
-- Painel de Poder Operacional - complemento: resumo por Ala
-- Ajusta dashboard_personnel_operational_summary para preencher byAla.
-- ============================================================================

create or replace function public.dashboard_personnel_operational_summary(
  p_unit_id uuid default null
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
    where (p_unit_id is null or d.unit_id = p_unit_id)
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
  )
  select jsonb_build_object(
    'context', jsonb_build_object(
      'unitId', p_unit_id,
      'unitName', (
        select u.name from public.units u where u.id = p_unit_id
      ),
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
    'byUnit', jsonb_build_array(),
    'byRank', jsonb_build_array(),
    'bySection', jsonb_build_array(),
    'driverLicenses', (
      select jsonb_build_object(
        'summary', jsonb_build_object(
          'withLicense', coalesce(with_license, 0),
          'driversAvailable', coalesce(drivers_available, 0),
          'expired', coalesce(expired, 0),
          'expiringIn30Days', coalesce(expiring_30, 0)
        ),
        'byCategory', jsonb_build_array()
      )
      from driver
    ),
    'leaves', jsonb_build_object(
      'byType', jsonb_build_array(),
      'currentLeaves', jsonb_build_array(),
      'upcomingReturns', jsonb_build_array()
    ),
    'birthdays', jsonb_build_object(
      'today', jsonb_build_array(),
      'next7Days', jsonb_build_array(),
      'next30Days', jsonb_build_array()
    ),
    'insights', jsonb_build_array(),
    'meta', jsonb_build_object('version', 1)
  );
$$;

revoke all on function public.dashboard_personnel_operational_summary(uuid) from public;
grant execute on function public.dashboard_personnel_operational_summary(uuid) to authenticated;

commit;

begin;

-- ============================================================================
-- Painel de Poder Operacional - RPCs específicas para dashboard
-- ============================================================================
-- 1) dashboard_personnel_operational_summary
-- 2) dashboard_vehicle_operational_summary
-- ----------------------------------------------------------------------------

-- 1. RESUMO OPERACIONAL DE PESSOAL
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
    -- Quebra por status detalhado ainda não está implementada; retornamos estrutura mínima.
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
    'byAla', jsonb_build_array(),
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
        'byCategory', jsonb_build_array() -- por enquanto vazio; pode ser preenchido em migração futura
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

-- 2. RESUMO OPERACIONAL DE FROTA
create or replace function public.dashboard_vehicle_operational_summary(
  p_unit_id uuid default null
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  with
  vehicle as (
    select v.*
    from public.vehicles v
    where (p_unit_id is null or v.unit_id = p_unit_id)
      and coalesce(v.is_inactive, false) = false
  ),
  totals as (
    select
      count(*) as total,
      count(*) filter (where status = 'ativo') as active,
      count(*) filter (where status = 'baixado') as withdrawn,
      count(*) filter (where status = 'cautelado') as cauteladas
    from vehicle
  ),
  conservation as (
    select
      count(*) as total,
      count(*) filter (where conservation_state = 'novo') as novo,
      count(*) filter (where conservation_state = 'bom') as bom,
      count(*) filter (where conservation_state = 'regular') as regular,
      count(*) filter (where conservation_state = 'ruim') as ruim,
      count(*) filter (where conservation_state = 'inservivel') as inservivel
    from vehicle
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
        'byState', jsonb_build_array(
          jsonb_build_object('state', 'novo', 'count', coalesce(novo, 0), 'percentageOfTotal', case when total > 0 then round(novo::numeric * 100 / total, 1) else 0 end),
          jsonb_build_object('state', 'bom', 'count', coalesce(bom, 0), 'percentageOfTotal', case when total > 0 then round(bom::numeric * 100 / total, 1) else 0 end),
          jsonb_build_object('state', 'regular', 'count', coalesce(regular, 0), 'percentageOfTotal', case when total > 0 then round(regular::numeric * 100 / total, 1) else 0 end),
          jsonb_build_object('state', 'ruim', 'count', coalesce(ruim, 0), 'percentageOfTotal', case when total > 0 then round(ruim::numeric * 100 / total, 1) else 0 end),
          jsonb_build_object('state', 'inservivel', 'count', coalesce(inservivel, 0), 'percentageOfTotal', case when total > 0 then round(inservivel::numeric * 100 / total, 1) else 0 end)
        ),
        'poorOrWorse', jsonb_build_object(
          'count', coalesce(ruim, 0) + coalesce(inservivel, 0),
          'percentageOfTotal', case when total > 0 then round(((coalesce(ruim, 0) + coalesce(inservivel, 0))::numeric * 100) / total, 1) else 0 end
        )
      )
      from conservation
    ),
    'byType', jsonb_build_array(),
    'byUnit', jsonb_build_array(),
    'matrixTypeByUnit', jsonb_build_object(
      'units', jsonb_build_array(),
      'types', jsonb_build_array(),
      'cells', jsonb_build_array()
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

revoke all on function public.dashboard_vehicle_operational_summary(uuid) from public;
grant execute on function public.dashboard_vehicle_operational_summary(uuid) to authenticated;

commit;

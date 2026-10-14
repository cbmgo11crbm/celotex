begin;

-- ============================================================================
-- Painel de Poder Operacional - complemento: viaturas por tipo de atendimento
-- Usa prefixos da coluna vtr para inferir tipo operacional.
-- ============================================================================

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
  vehicles as (
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
      end as vehicle_type
    from vehicles v
  ),
  by_type as (
    select
      vehicle_type as type_code,
      count(*) as total,
      count(*) filter (where status = 'ativo') as active,
      count(*) filter (where status = 'baixado') as withdrawn,
      count(*) filter (where status = 'cautelado') as cauteladas
    from type_map tm
    join vehicles v on v.id = tm.id
    group by vehicle_type
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

begin;

-- Expande taf_latest_overview para retornar contagens de cada menção e "não fez".
drop function if exists public.taf_latest_overview(uuid);

create or replace function public.taf_latest_overview(p_unit_id uuid default null)
returns table (
  unit_id uuid,
  total_military integer,
  with_taf integer,
  without_taf integer,
  count_excellent integer,
  count_very_good integer,
  count_good integer,
  count_regular integer,
  count_insufficient integer
)
language sql
stable
security invoker
set search_path = ''
as $$
  with base as (
    select
      d.id as military_id,
      d.unit_id,
      lt.mention
    from public.v_military_directory d
    left join public.v_military_taf_latest lt
      on lt.military_id = d.id
    where
      (p_unit_id is null or d.unit_id = p_unit_id)
      and d.is_inactive = false
  )
  select
    coalesce(p_unit_id, null) as unit_id,
    count(*)::integer as total_military,
    count(mention)::integer as with_taf,
    (count(*) - count(mention))::integer as without_taf,
    count(*) filter (where mention = 'E')::integer as count_excellent,
    count(*) filter (where mention = 'MB')::integer as count_very_good,
    count(*) filter (where mention = 'B')::integer as count_good,
    count(*) filter (where mention = 'R')::integer as count_regular,
    count(*) filter (where mention = 'I')::integer as count_insufficient
  from base;
$$;

revoke all on function public.taf_latest_overview(uuid) from public;
grant execute on function public.taf_latest_overview(uuid) to authenticated;

commit;

begin;

-- Atualiza a função de busca de militares para permitir também buscar
-- pelo nome de cursos vinculados (tabela courses / military_courses).
create or replace function public.search_military(
  p_query text,
  p_unit_id uuid default null,
  p_limit integer default 20,
  p_inactive_only boolean default false
)
returns table (
  id uuid,
  unit_id uuid,
  unit_acronym citext,
  rank_code citext,
  rank_order smallint,
  full_name text,
  war_name text,
  rg text,
  cpf text,
  classification public.military_classification,
  platoon public.platoon_code,
  activity_status text,
  photo_path text,
  quadro public.military_board
)
language sql
stable
security invoker
set search_path = ''
as $$
  with base as (
    select
      d.id,
      d.unit_id,
      d.unit_acronym,
      d.rank_code,
      d.rank_order,
      d.full_name,
      d.war_name,
      d.rg,
      d.cpf,
      d.classification,
      d.platoon,
      d.activity_status,
      d.photo_path,
      d.quadro,
      s.acronym as section_acronym,
      s.name as section_name,
      mp.intra_rank_order,
      c.name as course_name
    from public.v_military_directory d
    join public.military_personnel mp on mp.id = d.id
    left join public.military_sections ms on ms.military_id = d.id
    left join public.sections s on s.id = ms.section_id
    left join public.military_courses mc on mc.military_id = d.id
    left join public.courses c on c.id = mc.course_id
    where
      (p_unit_id is null or d.unit_id = p_unit_id)
      and (
        (p_inactive_only is true and d.is_inactive = true)
        or (coalesce(p_inactive_only, false) is false and d.is_inactive = false)
      )
      and (
        coalesce(btrim(p_query), '') = ''
        or (
          lower(d.full_name) like '%' || lower(btrim(p_query)) || '%'
          or lower(d.war_name) like '%' || lower(btrim(p_query)) || '%'
          or lower(d.rg) like '%' || lower(btrim(p_query)) || '%'
          or d.cpf like '%' || regexp_replace(p_query, '\\D', '', 'g') || '%'
          or (s.acronym is not null and lower(s.acronym) like '%' || lower(btrim(p_query)) || '%')
          or (s.name    is not null and lower(s.name)    like '%' || lower(btrim(p_query)) || '%')
          or (d.platoon is not null and lower(d.platoon::text) like '%' || lower(btrim(p_query)) || '%')
          or (c.name   is not null and lower(c.name)   like '%' || lower(btrim(p_query)) || '%')
        )
      )
  ),
  dedup as (
    select distinct on (id)
      id,
      unit_id,
      unit_acronym,
      rank_code,
      rank_order,
      full_name,
      war_name,
      rg,
      cpf,
      classification,
      platoon,
      activity_status,
      photo_path,
      quadro,
      intra_rank_order
    from base
    order by id, rank_order, intra_rank_order, war_name, full_name
  )
  select
    id,
    unit_id,
    unit_acronym,
    rank_code,
    rank_order,
    full_name,
    war_name,
    rg,
    cpf,
    classification,
    platoon,
    activity_status,
    photo_path,
    quadro
  from dedup
  order by rank_order, intra_rank_order, war_name, full_name
  limit greatest(coalesce(p_limit, 20), 1);
$$;

revoke all on function public.search_military(text, uuid, integer, boolean) from public;
grant execute on function public.search_military(text, uuid, integer, boolean) to authenticated;

commit;

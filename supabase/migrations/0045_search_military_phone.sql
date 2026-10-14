begin;

-- Expõe o telefone na busca de militares para exibição no card.
drop function if exists public.search_military(text, uuid, integer, boolean);

create function public.search_military(
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
  phone text,
  classification public.military_classification,
  platoon public.platoon_code,
  activity_status text,
  photo_path text,
  quadro public.military_board,
  blood_type text,
  last_taf_mention text,
  last_health_is_fit boolean,
  last_health_validity_date date
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
      d.phone,
      d.classification,
      d.platoon,
      d.activity_status,
      d.photo_path,
      d.quadro,
      d.blood_type,
      s.acronym as section_acronym,
      s.name as section_name,
      mp.intra_rank_order,
      c.name as course_name,
      lt.mention as last_taf_mention,
      hl.is_fit as last_health_is_fit,
      hl.validity_date as last_health_validity_date
    from public.v_military_directory d
    join public.military_personnel mp on mp.id = d.id
    left join public.military_sections ms on ms.military_id = d.id
    left join public.sections s on s.id = ms.section_id
    left join public.military_courses mc on mc.military_id = d.id
    left join public.courses c on c.id = mc.course_id
    left join public.v_military_taf_latest lt on lt.military_id = d.id
    left join public.v_military_health_latest hl on hl.military_id = d.id
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
          or d.cpf like '%' || regexp_replace(p_query, '\D', '', 'g') || '%'
          or (s.acronym is not null and lower(s.acronym) like '%' || lower(btrim(p_query)) || '%')
          or (s.name    is not null and lower(s.name)    like '%' || lower(btrim(p_query)) || '%')
          or (d.platoon is not null and lower(d.platoon::text) like '%' || lower(btrim(p_query)) || '%')
          or (c.name   is not null and lower(c.name)   like '%' || lower(btrim(p_query)) || '%')
          or (d.blood_type is not null and lower(d.blood_type) like '%' || lower(btrim(p_query)) || '%')
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
      phone,
      classification,
      platoon,
      activity_status,
      photo_path,
      quadro,
      blood_type,
      intra_rank_order,
      last_taf_mention,
      last_health_is_fit,
      last_health_validity_date
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
    phone,
    classification,
    platoon,
    activity_status,
    photo_path,
    quadro,
    blood_type,
    last_taf_mention,
    last_health_is_fit,
    last_health_validity_date
  from dedup
  order by rank_order, intra_rank_order, war_name, full_name
  limit greatest(coalesce(p_limit, 20), 1);
$$;

revoke all on function public.search_military(text, uuid, integer, boolean) from public;
grant execute on function public.search_military(text, uuid, integer, boolean) to authenticated;

commit;

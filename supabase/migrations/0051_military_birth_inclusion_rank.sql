begin;

-- Expõe birth_date, inclusion_date e rank_id na view do diretório.
drop view if exists public.v_military_order_admin;
drop view if exists public.v_military_directory;

create view public.v_military_directory
with (security_invoker = true)
as
select
  mp.id,
  mp.unit_id,
  u.acronym as unit_acronym,
  u.name as unit_name,
  mp.rank_id,
  r.code as rank_code,
  r.name as rank_name,
  r.sort_order as rank_order,
  mp.rg,
  mp.full_name,
  mp.war_name,
  mp.phone,
  mp.cpf,
  mp.email,
  mp.driver_license_category,
  mp.driver_license_expiration,
  mp.classification,
  mp.platoon,
  mp.photo_path,
  case
    when mp.is_inactive then 'inativado'
    else coalesce(ms.activity_status, 'ativo')
  end as activity_status,
  mp.created_at,
  mp.updated_at,
  mp.is_inactive,
  mp.quadro,
  mp.blood_type,
  mp.birth_date,
  mp.inclusion_date
from public.military_personnel mp
join public.units u on u.id = mp.unit_id
join public.ranks r on r.id = mp.rank_id
left join public.v_military_status ms on ms.military_id = mp.id;

-- Recria view dependente que foi removida pelo cascade.
create view public.v_military_order_admin as
select
  mp.id,
  d.full_name,
  d.war_name,
  d.rank_code,
  d.rank_order      as rank_sort_order,
  r.name            as rank_name,
  mp.intra_rank_order
from public.military_personnel mp
join public.v_military_directory d
  on d.id = mp.id
left join public.ranks r
  on r.id = mp.rank_id
where
  d.is_inactive = false
order by
  d.rank_order asc,
  mp.intra_rank_order asc,
  d.war_name asc,
  d.full_name asc;

revoke all on public.v_military_order_admin from public;
grant select on public.v_military_order_admin to authenticated;

-- Atualiza search_military para retornar os novos campos.
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
  rank_id uuid,
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
  birth_date date,
  inclusion_date date,
  last_taf_mention text,
  last_health_is_fit boolean,
  last_health_validity_date date
)
language sql
stable
security invoker
set search_path = ''
as $$
  with raw_query as (
    select lower(btrim(coalesce(p_query, ''))) as term
  ),
  base as (
    select
      d.id,
      d.unit_id,
      d.unit_acronym,
      d.rank_id,
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
      d.birth_date,
      d.inclusion_date,
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
    cross join raw_query r
    where
      (p_unit_id is null or d.unit_id = p_unit_id)
      and (
        (p_inactive_only is true and d.is_inactive = true)
        or (coalesce(p_inactive_only, false) is false and d.is_inactive = false)
      )
      and (
        r.term = ''
        or lower(d.full_name) like '%' || r.term || '%'
        or lower(d.war_name) like '%' || r.term || '%'
        or lower(d.rg) like '%' || r.term || '%'
        or d.cpf like '%' || regexp_replace(p_query, '\D', '', 'g') || '%'
        or (s.acronym is not null and lower(s.acronym) like '%' || r.term || '%')
        or (s.name    is not null and lower(s.name)    like '%' || r.term || '%')
        or (d.platoon is not null and lower(d.platoon::text) like '%' || r.term || '%')
        or (c.name   is not null and lower(c.name)   like '%' || r.term || '%')
        or (d.blood_type is not null and lower(d.blood_type) like '%' || r.term || '%')
      )
  ),
  dedup as (
    select distinct on (id)
      id,
      unit_id,
      unit_acronym,
      rank_id,
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
      birth_date,
      inclusion_date,
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
    rank_id,
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
    birth_date,
    inclusion_date,
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

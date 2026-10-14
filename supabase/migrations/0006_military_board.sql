begin;

-- Enum de quadros militares.
create type public.military_board as enum (
  'QOC',
  'QOS/Médico',
  'QOS/Dentista',
  'QOE/Complementar',
  'QOE/Músico',
  'QOE/Convocado',
  'QP/Especial',
  'QP/Combatente',
  'QP/Músico',
  'QP/Convocado'
);

-- Coluna de quadro no cadastro de militares.
alter table public.military_personnel
  add column if not exists quadro public.military_board;

comment on column public.military_personnel.quadro is
  'Quadro do militar (QOC, QOS/Médico, QOE/Complementar, QP/Combatente, etc).';

-- Atualiza a view de diretório para expor o quadro.
create or replace view public.v_military_directory
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
  mp.birth_date,
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
  mp.quadro
from public.military_personnel mp
join public.units u on u.id = mp.unit_id
join public.ranks r on r.id = mp.rank_id
left join public.v_military_status ms on ms.military_id = mp.id;

-- Ajusta a função de busca para retornar o quadro.
drop function if exists public.search_military(text, uuid, integer, boolean);

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
    d.quadro
  from public.v_military_directory d
  where
    (p_unit_id is null or d.unit_id = p_unit_id)
    and (
      (p_inactive_only is true and d.is_inactive = true)
      or (coalesce(p_inactive_only, false) is false and d.is_inactive = false)
    )
    and (
      p_query is null
      or btrim(p_query) = ''
      or lower(d.full_name) OPERATOR(extensions.%) lower(btrim(p_query))
      or lower(d.war_name) OPERATOR(extensions.%) lower(btrim(p_query))
      or lower(d.rg) like '%' || lower(btrim(p_query)) || '%'
      or d.cpf like '%' || regexp_replace(p_query, '\\D', '', 'g') || '%'
      or lower(d.full_name) like '%' || lower(btrim(p_query)) || '%'
      or lower(d.war_name) like '%' || lower(btrim(p_query)) || '%'
    )
  order by d.rank_order, d.war_name, d.full_name
  limit least(greatest(coalesce(p_limit, 20), 1), 100);
$$;

revoke all on function public.search_military(text, uuid, integer, boolean) from public;
grant execute on function public.search_military(text, uuid, integer, boolean) to authenticated;

commit;

begin;

-- Flag de inativação de militares.
alter table public.military_personnel
  add column if not exists is_inactive boolean not null default false;

create index if not exists military_is_inactive_idx
  on public.military_personnel (is_inactive);

-- Atualiza a view de diretório para expor is_inactive e sinalizar status "inativado".
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
  mp.is_inactive
from public.military_personnel mp
join public.units u on u.id = mp.unit_id
join public.ranks r on r.id = mp.rank_id
left join public.v_military_status ms on ms.military_id = mp.id;

comment on column public.military_personnel.is_inactive is
  'Indica que o militar foi inativado administrativamente e não deve ser considerado em listagens e métricas padrão.';

-- Ajusta a busca de militares para permitir ver apenas inativados quando solicitado
-- e, por padrão, ignorar inativados.
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
  photo_path text
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
    d.photo_path
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

-- Ajusta o resumo do dashboard para desconsiderar militares inativados nas métricas.
create or replace function public.dashboard_summary(p_unit_id uuid default null)
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
  vehicle as (
    select v.*
    from public.vehicles v
    where p_unit_id is null or v.unit_id = p_unit_id
  ),
  equip as (
    select e.*
    from public.equipment e
    where p_unit_id is null or e.unit_id = p_unit_id
  )
  select jsonb_build_object(
    'military', jsonb_build_object(
      'total', (select count(*) from military),
      'active', (select count(*) from military where activity_status = 'ativo'),
      'away', (select count(*) from military where activity_status = 'afastado'),
      'operational', (select count(*) from military where classification = 'operacional'),
      'administrative', (select count(*) from military where classification = 'administrativo'),
      'expiredDriverLicenses', (
        select count(*) from military
        where driver_license_expiration is not null
          and driver_license_expiration < current_date
      ),
      'driverLicensesExpiring30Days', (
        select count(*) from military
        where driver_license_expiration between current_date and current_date + 30
      )
    ),
    'vehicles', jsonb_build_object(
      'total', (select count(*) from vehicle)
    ),
    'equipment', jsonb_build_object(
      'total', (select count(*) from equip)
    )
  );
$$;

commit;

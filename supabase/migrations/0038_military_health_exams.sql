begin;

-- 0038_military_health_exams.sql
-- Registra as avaliações periódicas de saúde por militar e expõe
-- visão agregada para o dashboard operacional e busca.

create table public.military_health_exams (
  id uuid primary key default gen_random_uuid(),
  military_id uuid not null references public.military_personnel(id) on delete cascade,
  year integer not null,
  exam_date date not null,
  is_fit boolean not null,
  validity_date date not null,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint military_health_year_valid check (year >= 2000 and year <= extract(year from now())::integer + 1),
  constraint military_health_validity_not_before_exam check (validity_date >= exam_date)
);

create index military_health_exams_military_id_idx on public.military_health_exams (military_id);
create index military_health_exams_validity_idx on public.military_health_exams (validity_date);

-- RLS e permissões básicas
alter table public.military_health_exams enable row level security;

grant select, insert, update, delete on public.military_health_exams to authenticated;

create policy "military_health_authenticated_read"
  on public.military_health_exams for select
  to authenticated
  using ((select private.current_user_is_active()));

create policy "military_health_master_editor_all"
  on public.military_health_exams for all
  to authenticated
  using (
    (select private.can_write_unit((select private.military_unit_id(military_id))))
  )
  with check (
    (select private.can_write_unit((select private.military_unit_id(military_id))))
  );

-- Visão com a última avaliação de saúde por militar
create or replace view public.v_military_health_latest
with (security_invoker = true)
as
with ranked as (
  select
    h.id,
    h.military_id,
    h.year,
    h.exam_date,
    h.is_fit,
    h.validity_date,
    h.created_at,
    row_number() over (
      partition by h.military_id
      order by h.exam_date desc, h.created_at desc
    ) as rn
  from public.military_health_exams h
)
select
  id,
  military_id,
  year,
  exam_date,
  is_fit,
  validity_date,
  created_at
from ranked
where rn = 1;

revoke all on public.v_military_health_latest from public;
grant select on public.v_military_health_latest to authenticated;

-- Função para o dashboard: panorama da avaliação de saúde mais recente
create or replace function public.health_latest_overview(p_unit_id uuid default null)
returns table (
  unit_id uuid,
  total_military integer,
  with_exam integer,
  without_exam integer,
  count_unfit integer,
  count_expired integer,
  expired_list jsonb
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
      d.is_inactive,
      hl.exam_date,
      hl.is_fit,
      hl.validity_date,
      d.rank_code,
      d.war_name,
      d.unit_acronym
    from public.v_military_directory d
    left join public.v_military_health_latest hl
      on hl.military_id = d.id
    where
      (p_unit_id is null or d.unit_id = p_unit_id)
      and d.is_inactive = false
  )
  select
    coalesce(p_unit_id, null) as unit_id,
    count(*)::integer as total_military,
    count(exam_date)::integer as with_exam,
    (count(*) - count(exam_date))::integer as without_exam,
    count(*) filter (where is_fit = false)::integer as count_unfit,
    count(*) filter (where validity_date < current_date)::integer as count_expired,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'military_id', military_id,
          'rank_code', rank_code,
          'war_name', war_name,
          'unit_acronym', unit_acronym,
          'validity_date', validity_date
        )
        order by validity_date asc
      ) filter (where validity_date < current_date),
      '[]'::jsonb
    ) as expired_list
  from base;
$$;

revoke all on function public.health_latest_overview(uuid) from public;
grant execute on function public.health_latest_overview(uuid) to authenticated;

-- Atualiza search_military para incluir dados de último TAF e última avaliação de saúde
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
  classification public.military_classification,
  platoon public.platoon_code,
  activity_status text,
  photo_path text,
  quadro public.military_board,
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
      d.classification,
      d.platoon,
      d.activity_status,
      d.photo_path,
      d.quadro,
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
    classification,
    platoon,
    activity_status,
    photo_path,
    quadro,
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

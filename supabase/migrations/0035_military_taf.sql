begin;

-- 0035_military_taf.sql
-- Registra os resultados de TAF (Teste de Aptidão Física) por militar e
-- expõe uma visão agregada para o dashboard operacional.

create table public.military_taf (
  id uuid primary key default gen_random_uuid(),
  military_id uuid not null references public.military_personnel(id) on delete cascade,
  year integer not null,
  semester smallint not null,
  -- Menções: E, MB, B, R, I, NF (Não fez)
  mention text not null,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint military_taf_year_valid check (year >= 2000 and year <= extract(year from now())::integer + 1),
  constraint military_taf_semester_valid check (semester in (1, 2)),
  constraint military_taf_mention_valid check (mention in ('E', 'MB', 'B', 'R', 'I', 'NF'))
);

create index military_taf_military_id_idx on public.military_taf (military_id);
create index military_taf_year_semester_idx on public.military_taf (year desc, semester desc);

-- RLS e permissões básicas
alter table public.military_taf enable row level security;

grant select, insert, update, delete on public.military_taf to authenticated;

create policy "military_taf_authenticated_read"
  on public.military_taf for select
  to authenticated
  using ((select private.current_user_is_active()));

create policy "military_taf_master_editor_all"
  on public.military_taf for all
  to authenticated
  using (
    (select private.can_write_unit((select private.military_unit_id(military_id))))
  )
  with check (
    (select private.can_write_unit((select private.military_unit_id(military_id))))
  );

-- Visão com o último TAF por militar
create or replace view public.v_military_taf_latest
with (security_invoker = true)
as
with ranked as (
  select
    t.id,
    t.military_id,
    t.year,
    t.semester,
    t.mention,
    t.created_at,
    row_number() over (
      partition by t.military_id
      order by t.year desc, t.semester desc, t.created_at desc
    ) as rn
  from public.military_taf t
)
select
  id,
  military_id,
  year,
  semester,
  mention,
  created_at
from ranked
where rn = 1;

-- Função para o dashboard: panorama do TAF mais recente
create or replace function public.taf_latest_overview(p_unit_id uuid default null)
returns table (
  unit_id uuid,
  total_military integer,
  with_taf integer,
  without_taf integer,
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
      d.is_inactive,
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
    count(*) filter (where mention = 'R')::integer as count_regular,
    count(*) filter (where mention = 'I')::integer as count_insufficient
  from base;
$$;

revoke all on function public.taf_latest_overview(uuid) from public;
grant execute on function public.taf_latest_overview(uuid) to authenticated;

commit;

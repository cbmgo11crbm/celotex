begin;

-- 0029_vehicle_state_status_tables.sql
-- Cria tabelas administráveis para estado de conservação e situação da viatura,
-- mantendo compatibilidade com os enums existentes.

create table public.vehicle_conservation_states (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  sort_order integer not null,
  is_active boolean not null default true,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint vehicle_conservation_states_code_not_blank check (btrim(code) <> ''),
  constraint vehicle_conservation_states_name_not_blank check (btrim(name) <> '')
);

create unique index vehicle_conservation_states_code_unique
  on public.vehicle_conservation_states (lower(code));

create table public.vehicle_statuses (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  sort_order integer not null,
  is_active boolean not null default true,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint vehicle_statuses_code_not_blank check (btrim(code) <> ''),
  constraint vehicle_statuses_name_not_blank check (btrim(name) <> '')
);

create unique index vehicle_statuses_code_unique
  on public.vehicle_statuses (lower(code));

-- Seed inicial baseado nos enums atuais
insert into public.vehicle_conservation_states (code, name, sort_order, is_active) values
  ('novo',       'Novo',        1, true),
  ('bom',        'Bom',         2, true),
  ('regular',    'Regular',     3, true),
  ('ruim',       'Ruim',        4, true),
  ('inservivel', 'Inservível',  5, true);

insert into public.vehicle_statuses (code, name, sort_order, is_active) values
  ('ativo',     'Ativo',      1, true),
  ('baixado',   'Baixado',    2, true),
  ('cautelado', 'Cautelado',  3, true);

-- Novas colunas de FK em vehicles e equipment, mantendo enums originais
alter table public.vehicles
  add column conservation_state_id uuid references public.vehicle_conservation_states(id),
  add column status_id uuid references public.vehicle_statuses(id);

alter table public.equipment
  add column conservation_state_id uuid references public.vehicle_conservation_states(id);

-- Backfill a partir dos enums existentes
update public.vehicles v
set conservation_state_id = s.id
from public.vehicle_conservation_states s
where s.code = v.conservation_state::text;

update public.vehicles v
set status_id = st.id
from public.vehicle_statuses st
where st.code = v.status::text;

update public.equipment e
set conservation_state_id = s.id
from public.vehicle_conservation_states s
where s.code = e.conservation_state::text;

-- Depois do backfill, tornamos as FKs obrigatórias
alter table public.vehicles
  alter column conservation_state_id set not null,
  alter column status_id set not null;

alter table public.equipment
  alter column conservation_state_id set not null;

-- RLS: apenas Master pode manter tabelas de estado/situação
alter table public.vehicle_conservation_states enable row level security;
alter table public.vehicle_statuses enable row level security;

create policy "vehicle_conservation_states_master_write"
  on public.vehicle_conservation_states for all
  to authenticated
  using ((select private.is_master()))
  with check ((select private.is_master()));

create policy "vehicle_statuses_master_write"
  on public.vehicle_statuses for all
  to authenticated
  using ((select private.is_master()))
  with check ((select private.is_master()));

-- Grants para papel authenticated (controlados por RLS)
grant select, insert, update, delete
  on public.vehicle_conservation_states
  to authenticated;

grant select, insert, update, delete
  on public.vehicle_statuses
  to authenticated;

commit;

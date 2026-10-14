begin;

-- 0033_military_boards_table.sql
-- Cria tabela administrável para quadros militares, mantendo o enum existente
-- public.military_board como fonte atual de dados nos cadastros.

create table public.military_boards (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  sort_order integer not null,
  is_active boolean not null default true,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint military_boards_code_not_blank check (btrim(code) <> ''),
  constraint military_boards_name_not_blank check (btrim(name) <> '')
);

create unique index military_boards_code_unique
  on public.military_boards (lower(code));

-- Seed inicial baseado nos valores atuais do enum public.military_board
insert into public.military_boards (code, name, sort_order, is_active)
values
  ('QOC',           'QOC',              1, true),
  ('QOS/M\u00e9dico',   'QOS/M\u00e9dico',      2, true),
  ('QOS/Dentista',  'QOS/Dentista',     3, true),
  ('QOE/Complementar', 'QOE/Complementar', 4, true),
  ('QOE/M\u00fasico',   'QOE/M\u00fasico',      5, true),
  ('QOE/Convocado', 'QOE/Convocado',    6, true),
  ('QP/Especial',   'QP/Especial',      7, true),
  ('QP/Combatente', 'QP/Combatente',    8, true),
  ('QP/M\u00fasico',   'QP/M\u00fasico',      9, true),
  ('QP/Convocado',  'QP/Convocado',    10, true);

-- RLS: apenas Master pode manter tabela de quadros
alter table public.military_boards enable row level security;

create policy "military_boards_master_write"
  on public.military_boards for all
  to authenticated
  using ((select private.is_master()))
  with check ((select private.is_master()));

-- Grants para papel authenticated (controlados por RLS)
grant select, insert, update, delete
  on public.military_boards
  to authenticated;

commit;

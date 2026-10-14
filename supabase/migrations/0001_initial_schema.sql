-- ============================================================================
-- Sistema de Gestão do Comando Regional de Bombeiros Militar
-- Migration: 0001_initial_schema.sql
-- PostgreSQL / Supabase
-- ============================================================================
-- PRINCÍPIOS:
--   * Todos os usuários autenticados podem visualizar os dados operacionais.
--   * MASTER pode administrar todas as unidades e registros.
--   * EDITOR pode criar/alterar/excluir somente registros da própria unidade.
--   * VIEWER possui somente leitura.
--   * Autorização real é feita por RLS, não apenas pela interface.
--   * Dados de auditoria são registrados nas entidades principais.
-- ============================================================================

begin;

-- ----------------------------------------------------------------------------
-- 0. EXTENSÕES E SCHEMAS
-- ----------------------------------------------------------------------------

create extension if not exists pgcrypto;
create extension if not exists citext;

create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to authenticated;

-- ----------------------------------------------------------------------------
-- 1. TIPOS FIXOS
-- ----------------------------------------------------------------------------

do $$
begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum ('master', 'editor', 'viewer');
  end if;

  if not exists (select 1 from pg_type where typname = 'military_classification') then
    create type public.military_classification as enum ('operacional', 'administrativo');
  end if;

  if not exists (select 1 from pg_type where typname = 'driver_license_category') then
    create type public.driver_license_category as enum ('A', 'B', 'AB', 'C', 'D', 'E', 'AC', 'AD', 'AE');
  end if;

  if not exists (select 1 from pg_type where typname = 'platoon_code') then
    create type public.platoon_code as enum ('A', 'B', 'C', 'D');
  end if;

  if not exists (select 1 from pg_type where typname = 'conservation_state') then
    create type public.conservation_state as enum ('novo', 'bom', 'regular', 'ruim', 'inservivel');
  end if;

  if not exists (select 1 from pg_type where typname = 'vehicle_status') then
    create type public.vehicle_status as enum ('ativo', 'baixado', 'cautelado');
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- 2. UNIDADES
-- ----------------------------------------------------------------------------

create table public.units (
  id uuid primary key default gen_random_uuid(),
  acronym citext not null,
  name text not null,
  municipality text,
  address text,
  phone text,
  email citext,
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint units_acronym_not_blank check (btrim(acronym::text) <> ''),
  constraint units_name_not_blank check (btrim(name) <> ''),
  constraint units_email_format check (
    email is null
    or email::text ~* '^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$'
  ),
  constraint units_phone_digits check (
    phone is null
    or regexp_replace(phone, '\D', '', 'g') ~ '^[0-9]{10,11}$'
  )
);

create unique index units_acronym_unique_active
  on public.units (lower(acronym::text))
  where is_active = true;

create index units_is_active_idx on public.units (is_active);
create index units_municipality_idx on public.units (municipality);

-- ----------------------------------------------------------------------------
-- 3. PERFIS / AUTORIZAÇÃO
-- ----------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email citext not null,
  role public.app_role not null default 'viewer',
  unit_id uuid references public.units(id) on delete restrict,
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint profiles_full_name_not_blank check (btrim(full_name) <> ''),
  constraint profiles_email_not_blank check (btrim(email::text) <> ''),
  constraint profiles_master_unit_rule check (
    role = 'master' or unit_id is not null or is_active = false
  )
);

create unique index profiles_email_unique on public.profiles (lower(email::text));
create index profiles_role_idx on public.profiles (role);
create index profiles_unit_id_idx on public.profiles (unit_id);
create index profiles_is_active_idx on public.profiles (is_active);

comment on table public.profiles is
'Perfil de aplicação associado 1:1 a auth.users. Role e unit_id são fonte confiável para autorização.';

-- ----------------------------------------------------------------------------
-- 4. CATÁLOGO DE POSTOS/GRADUAÇÕES
-- ----------------------------------------------------------------------------

create table public.ranks (
  id uuid primary key default gen_random_uuid(),
  code citext not null,
  name text not null,
  sort_order smallint not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint ranks_code_not_blank check (btrim(code::text) <> ''),
  constraint ranks_name_not_blank check (btrim(name) <> ''),
  constraint ranks_sort_order_positive check (sort_order > 0)
);

create unique index ranks_code_unique on public.ranks (lower(code::text));
create unique index ranks_sort_order_unique on public.ranks (sort_order);
create index ranks_is_active_idx on public.ranks (is_active);

-- ----------------------------------------------------------------------------
-- 5. CATÁLOGOS ADMINISTRÁVEIS
-- ----------------------------------------------------------------------------

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  name citext not null,
  description text,
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint courses_name_not_blank check (btrim(name::text) <> '')
);

create unique index courses_name_unique on public.courses (lower(name::text));
create index courses_is_active_idx on public.courses (is_active);

create table public.sections (
  id uuid primary key default gen_random_uuid(),
  acronym citext not null,
  name text,
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint sections_acronym_not_blank check (btrim(acronym::text) <> '')
);

create unique index sections_acronym_unique on public.sections (lower(acronym::text));
create index sections_is_active_idx on public.sections (is_active);

create table public.functions (
  id uuid primary key default gen_random_uuid(),
  name citext not null,
  description text,
  is_operational boolean not null default false,
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint functions_name_not_blank check (btrim(name::text) <> '')
);

create unique index functions_name_unique on public.functions (lower(name::text));
create index functions_is_operational_idx on public.functions (is_operational);
create index functions_is_active_idx on public.functions (is_active);

create table public.leave_types (
  id uuid primary key default gen_random_uuid(),
  name citext not null,
  requires_detail boolean not null default false,
  is_active boolean not null default true,
  sort_order smallint not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint leave_types_name_not_blank check (btrim(name::text) <> ''),
  constraint leave_types_sort_positive check (sort_order > 0)
);

create unique index leave_types_name_unique on public.leave_types (lower(name::text));
create index leave_types_is_active_idx on public.leave_types (is_active);
create index leave_types_sort_order_idx on public.leave_types (sort_order);

-- ----------------------------------------------------------------------------
-- 6. MILITARES
-- ----------------------------------------------------------------------------

create table public.military_personnel (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.units(id) on delete restrict,
  rank_id uuid not null references public.ranks(id) on delete restrict,

  rg text not null,
  full_name text not null,
  war_name text not null,
  birth_date date not null,
  phone text not null,
  cpf text not null,
  email citext,

  driver_license_category public.driver_license_category not null,
  driver_license_expiration date,

  -- A classificação é sincronizada automaticamente pelas funções associadas.
  classification public.military_classification not null default 'administrativo',
  platoon public.platoon_code,

  photo_path text,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint military_rg_not_blank check (btrim(rg) <> ''),
  constraint military_full_name_not_blank check (btrim(full_name) <> ''),
  constraint military_war_name_not_blank check (btrim(war_name) <> ''),
  constraint military_birth_not_future check (birth_date <= current_date),

  -- CPF deve ser persistido normalizado, sem pontuação.
  constraint military_cpf_digits check (cpf ~ '^[0-9]{11}$'),

  -- Telefone deve ser persistido normalizado, somente dígitos.
  constraint military_phone_digits check (phone ~ '^[0-9]{10,11}$'),

  constraint military_email_format check (
    email is null
    or email::text ~* '^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$'
  ),

  constraint military_operational_platoon_rule check (
    classification <> 'operacional' or platoon is not null
  )
);

create unique index military_cpf_unique on public.military_personnel (cpf);
create unique index military_rg_unique on public.military_personnel (lower(rg));
create index military_unit_id_idx on public.military_personnel (unit_id);
create index military_rank_id_idx on public.military_personnel (rank_id);
create index military_full_name_idx on public.military_personnel (lower(full_name));
create index military_war_name_idx on public.military_personnel (lower(war_name));
create index military_classification_idx on public.military_personnel (classification);
create index military_platoon_idx on public.military_personnel (platoon);
create index military_license_expiration_idx on public.military_personnel (driver_license_expiration);

-- ----------------------------------------------------------------------------
-- 7. RELACIONAMENTOS N:N DO MILITAR
-- ----------------------------------------------------------------------------

create table public.military_courses (
  military_id uuid not null references public.military_personnel(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete restrict,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (military_id, course_id)
);

create index military_courses_course_id_idx on public.military_courses (course_id);

create table public.military_sections (
  military_id uuid not null references public.military_personnel(id) on delete cascade,
  section_id uuid not null references public.sections(id) on delete restrict,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (military_id, section_id)
);

create index military_sections_section_id_idx on public.military_sections (section_id);

create table public.military_functions (
  military_id uuid not null references public.military_personnel(id) on delete cascade,
  function_id uuid not null references public.functions(id) on delete restrict,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (military_id, function_id)
);

create index military_functions_function_id_idx on public.military_functions (function_id);

-- ----------------------------------------------------------------------------
-- 8. AFASTAMENTOS
-- ----------------------------------------------------------------------------

create table public.leaves (
  id uuid primary key default gen_random_uuid(),
  military_id uuid not null references public.military_personnel(id) on delete cascade,
  leave_type_id uuid not null references public.leave_types(id) on delete restrict,

  start_date date not null,
  end_date date,
  is_indefinite boolean not null default false,

  -- Ex.: nome do curso quando leave_types.requires_detail = true.
  detail text,
  notes text,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint leaves_period_rule check (
    (is_indefinite = true and end_date is null)
    or
    (is_indefinite = false and end_date is not null and end_date >= start_date)
  )
);

create index leaves_military_id_idx on public.leaves (military_id);
create index leaves_leave_type_id_idx on public.leaves (leave_type_id);
create index leaves_period_idx on public.leaves (start_date, end_date);
create index leaves_indefinite_idx on public.leaves (is_indefinite) where is_indefinite = true;

-- ----------------------------------------------------------------------------
-- 9. VIATURAS
-- ----------------------------------------------------------------------------

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.units(id) on delete restrict,

  vtr citext not null,
  brand text not null,
  model text not null,
  year smallint not null,
  conservation_state public.conservation_state not null,
  status public.vehicle_status not null,
  location text not null,
  notes text,
  photo_path text,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint vehicles_vtr_not_blank check (btrim(vtr::text) <> ''),
  constraint vehicles_brand_not_blank check (btrim(brand) <> ''),
  constraint vehicles_model_not_blank check (btrim(model) <> ''),
  constraint vehicles_location_not_blank check (btrim(location) <> ''),
  constraint vehicles_year_reasonable check (year between 1900 and 2100)
);

create unique index vehicles_vtr_unique on public.vehicles (lower(vtr::text));
create index vehicles_unit_id_idx on public.vehicles (unit_id);
create index vehicles_status_idx on public.vehicles (status);
create index vehicles_conservation_idx on public.vehicles (conservation_state);
create index vehicles_year_idx on public.vehicles (year);

-- ----------------------------------------------------------------------------
-- 10. EQUIPAMENTOS
-- ----------------------------------------------------------------------------

create table public.equipment (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.units(id) on delete restrict,

  item text not null,
  model_brand text,
  quantity integer not null default 1,
  conservation_state public.conservation_state not null,
  notes text,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint equipment_item_not_blank check (btrim(item) <> ''),
  constraint equipment_quantity_nonnegative check (quantity >= 0)
);

create index equipment_unit_id_idx on public.equipment (unit_id);
create index equipment_item_idx on public.equipment (lower(item));
create index equipment_conservation_idx on public.equipment (conservation_state);

-- ----------------------------------------------------------------------------
-- 11. AUDITORIA
-- ----------------------------------------------------------------------------

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  schema_name text not null,
  table_name text not null,
  record_id text,
  old_data jsonb,
  new_data jsonb,
  occurred_at timestamptz not null default now(),

  constraint audit_action_check check (action in ('INSERT', 'UPDATE', 'DELETE'))
);

create index audit_logs_actor_idx on public.audit_logs (actor_user_id);
create index audit_logs_table_idx on public.audit_logs (table_name);
create index audit_logs_occurred_at_idx on public.audit_logs (occurred_at desc);

-- ----------------------------------------------------------------------------
-- 12. FUNÇÕES GENÉRICAS DE TIMESTAMP / AUTORIA
-- ----------------------------------------------------------------------------

create or replace function private.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function private.set_actor_fields()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if v_uid is not null then
      new.created_by := v_uid;
      new.updated_by := v_uid;
    end if;
  elsif tg_op = 'UPDATE' then
    if v_uid is not null then
      new.updated_by := v_uid;
    end if;
  end if;

  return new;
end;
$$;

create or replace function private.set_created_by()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is not null then
    new.created_by := v_uid;
  end if;

  return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- 13. HELPERS DE AUTORIZAÇÃO
-- ----------------------------------------------------------------------------

create or replace function private.current_user_role()
returns public.app_role
language sql
stable
security definer
set search_path = ''
as $$
  select p.role
  from public.profiles p
  where p.id = (select auth.uid())
    and p.is_active = true
  limit 1;
$$;

create or replace function private.current_user_unit_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select p.unit_id
  from public.profiles p
  where p.id = (select auth.uid())
    and p.is_active = true
  limit 1;
$$;

create or replace function private.current_user_is_active()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.is_active = true
  );
$$;

create or replace function private.is_master()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select private.current_user_role()) = 'master'::public.app_role, false);
$$;

create or replace function private.can_write_unit(target_unit_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    coalesce((select private.is_master()), false)
    or (
      (select private.current_user_role()) = 'editor'::public.app_role
      and (select private.current_user_unit_id()) = target_unit_id
    );
$$;

revoke all on function private.current_user_role() from public;
revoke all on function private.current_user_unit_id() from public;
revoke all on function private.current_user_is_active() from public;
revoke all on function private.is_master() from public;
revoke all on function private.can_write_unit(uuid) from public;

grant execute on function private.current_user_role() to authenticated;
grant execute on function private.current_user_unit_id() to authenticated;
grant execute on function private.current_user_is_active() to authenticated;
grant execute on function private.is_master() to authenticated;
grant execute on function private.can_write_unit(uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 14. VALIDAÇÕES COMPLEXAS DE NEGÓCIO
-- ----------------------------------------------------------------------------

-- Verificação matemática de CPF normalizado.
create or replace function private.is_valid_cpf(p_cpf text)
returns boolean
language plpgsql
immutable
security invoker
set search_path = ''
as $$
declare
  sum1 integer := 0;
  sum2 integer := 0;
  digit1 integer;
  digit2 integer;
begin
  if p_cpf is null or p_cpf !~ '^[0-9]{11}$' then
    return false;
  end if;

  if p_cpf ~ '^([0-9])\1{10}$' then
    return false;
  end if;

  for i in 1..9 loop
    sum1 := sum1 + substring(p_cpf from i for 1)::integer * (11 - i);
  end loop;

  digit1 := (sum1 * 10) % 11;
  if digit1 = 10 then digit1 := 0; end if;

  if digit1 <> substring(p_cpf from 10 for 1)::integer then
    return false;
  end if;

  for i in 1..10 loop
    sum2 := sum2 + substring(p_cpf from i for 1)::integer * (12 - i);
  end loop;

  digit2 := (sum2 * 10) % 11;
  if digit2 = 10 then digit2 := 0; end if;

  return digit2 = substring(p_cpf from 11 for 1)::integer;
end;
$$;

create or replace function private.validate_military_cpf()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not private.is_valid_cpf(new.cpf) then
    raise exception 'CPF inválido.'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

-- Tipos de afastamento que exigem detalhe (ex.: Curso).
create or replace function private.validate_leave_detail()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_requires_detail boolean;
begin
  select lt.requires_detail
    into v_requires_detail
  from public.leave_types lt
  where lt.id = new.leave_type_id
    and lt.is_active = true;

  if v_requires_detail is null then
    raise exception 'Tipo de afastamento inválido ou inativo.'
      using errcode = '23514';
  end if;

  if v_requires_detail and (new.detail is null or btrim(new.detail) = '') then
    raise exception 'Este tipo de afastamento exige detalhamento.'
      using errcode = '23514';
  end if;

  if not v_requires_detail then
    new.detail := null;
  end if;

  return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- 15. CLASSIFICAÇÃO OPERACIONAL AUTOMÁTICA
-- ----------------------------------------------------------------------------

-- A classificação é derivada das funções associadas.
-- Um militar operacional deve ter Ala preenchida.
--
-- Como a associação é N:N, uma alteração de funções pode transformar um
-- militar administrativo em operacional. Nesse caso, não podemos completar
-- a operação sem Ala. A aplicação deve definir a Ala antes/de forma atômica.
--
-- Esta função é chamada por RPC de sincronização e por triggers de remoção.
create or replace function private.compute_military_classification(p_military_id uuid)
returns public.military_classification
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when exists (
      select 1
      from public.military_functions mf
      join public.functions f on f.id = mf.function_id
      where mf.military_id = p_military_id
        and f.is_operational = true
    )
    then 'operacional'::public.military_classification
    else 'administrativo'::public.military_classification
  end;
$$;

create or replace function private.sync_military_classification(p_military_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_classification public.military_classification;
  v_platoon public.platoon_code;
begin
  v_classification := private.compute_military_classification(p_military_id);

  select mp.platoon
    into v_platoon
  from public.military_personnel mp
  where mp.id = p_military_id;

  if v_classification = 'operacional' and v_platoon is null then
    raise exception 'A Ala é obrigatória para militares operacionais.'
      using errcode = '23514';
  end if;

  update public.military_personnel
  set
    classification = v_classification,
    platoon = case
      when v_classification = 'administrativo' then null
      else platoon
    end,
    updated_at = now(),
    updated_by = coalesce((select auth.uid()), updated_by)
  where id = p_military_id;
end;
$$;

-- Para INSERT de função operacional, valida que a Ala já está definida.
create or replace function private.validate_operational_function_assignment()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_is_operational boolean;
  v_platoon public.platoon_code;
begin
  select f.is_operational
    into v_is_operational
  from public.functions f
  where f.id = new.function_id
    and f.is_active = true;

  if v_is_operational is null then
    raise exception 'Função inválida ou inativa.'
      using errcode = '23514';
  end if;

  if v_is_operational then
    select mp.platoon
      into v_platoon
    from public.military_personnel mp
    where mp.id = new.military_id;

    if v_platoon is null then
      raise exception 'Defina a Ala antes de associar uma função operacional.'
        using errcode = '23514';
    end if;
  end if;

  return new;
end;
$$;

create or replace function private.after_military_function_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_military_id uuid;
begin
  v_military_id := coalesce(new.military_id, old.military_id);
  perform private.sync_military_classification(v_military_id);
  return coalesce(new, old);
end;
$$;

-- Impede a remoção manual da Ala enquanto existirem funções operacionais.
create or replace function private.validate_military_platoon_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_has_operational_function boolean := false;
begin
  -- Um novo militar nasce administrativo; a classificação será sincronizada
  -- assim que suas funções forem associadas. Isso impede que o cliente
  -- escolha arbitrariamente a classificação.
  if tg_op = 'INSERT' then
    new.classification := 'administrativo'::public.military_classification;
    return new;
  end if;

  select exists (
    select 1
    from public.military_functions mf
    join public.functions f on f.id = mf.function_id
    where mf.military_id = new.id
      and f.is_operational = true
  ) into v_has_operational_function;

  if new.platoon is null and v_has_operational_function then
    raise exception 'Não é possível remover a Ala enquanto houver função operacional.'
      using errcode = '23514';
  end if;

  -- O cliente nunca é fonte da classificação: recalcular com base nas
  -- associações que existem neste instante.
  new.classification := case
    when v_has_operational_function
      then 'operacional'::public.military_classification
    else 'administrativo'::public.military_classification
  end;

  return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- 16. HELPERS PARA RLS DAS TABELAS FILHAS
-- ----------------------------------------------------------------------------

create or replace function private.military_unit_id(p_military_id uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select mp.unit_id
  from public.military_personnel mp
  where mp.id = p_military_id
  limit 1;
$$;

revoke all on function private.military_unit_id(uuid) from public;
grant execute on function private.military_unit_id(uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 17. AUDIT TRIGGER
-- ----------------------------------------------------------------------------

create or replace function private.audit_row_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_record_id text;
begin
  if tg_op = 'INSERT' then
    v_record_id := coalesce(to_jsonb(new)->>'id', '');
    insert into public.audit_logs (
      actor_user_id, action, schema_name, table_name, record_id, new_data
    )
    values (
      (select auth.uid()), tg_op, tg_table_schema, tg_table_name, v_record_id, to_jsonb(new)
    );
    return new;

  elsif tg_op = 'UPDATE' then
    v_record_id := coalesce(to_jsonb(new)->>'id', to_jsonb(old)->>'id', '');
    insert into public.audit_logs (
      actor_user_id, action, schema_name, table_name, record_id, old_data, new_data
    )
    values (
      (select auth.uid()), tg_op, tg_table_schema, tg_table_name, v_record_id, to_jsonb(old), to_jsonb(new)
    );
    return new;

  elsif tg_op = 'DELETE' then
    v_record_id := coalesce(to_jsonb(old)->>'id', '');
    insert into public.audit_logs (
      actor_user_id, action, schema_name, table_name, record_id, old_data
    )
    values (
      (select auth.uid()), tg_op, tg_table_schema, tg_table_name, v_record_id, to_jsonb(old)
    );
    return old;
  end if;

  return null;
end;
$$;

-- ----------------------------------------------------------------------------
-- 18. TRIGGERS
-- ----------------------------------------------------------------------------

-- updated_at
do $$
declare
  t text;
begin
  foreach t in array array[
    'units','profiles','ranks','courses','sections','functions','leave_types',
    'military_personnel','leaves','vehicles','equipment'
  ]
  loop
    execute format(
      'create trigger %I before update on public.%I
       for each row execute function private.set_updated_at()',
      t || '_set_updated_at', t
    );
  end loop;
end $$;

-- created_by / updated_by
do $$
declare
  t text;
begin
  foreach t in array array[
    'units','courses','sections','functions','military_personnel',
    'leaves','vehicles','equipment'
  ]
  loop
    execute format(
      'create trigger %I before insert or update on public.%I
       for each row execute function private.set_actor_fields()',
      t || '_set_actor_fields', t
    );
  end loop;
end $$;

-- created_by em relações
do $$
declare
  t text;
begin
  foreach t in array array[
    'military_courses','military_sections','military_functions'
  ]
  loop
    execute format(
      'create trigger %I before insert on public.%I
       for each row execute function private.set_created_by()',
      t || '_set_created_by', t
    );
  end loop;
end $$;

create trigger military_validate_cpf
before insert or update of cpf on public.military_personnel
for each row execute function private.validate_military_cpf();

create trigger leaves_validate_detail
before insert or update on public.leaves
for each row execute function private.validate_leave_detail();

create trigger military_validate_platoon
before insert or update of platoon, classification on public.military_personnel
for each row execute function private.validate_military_platoon_update();

create trigger military_functions_validate_operational
before insert or update on public.military_functions
for each row execute function private.validate_operational_function_assignment();

create trigger military_functions_sync_after_insert_update
after insert or update on public.military_functions
for each row execute function private.after_military_function_change();

create trigger military_functions_sync_after_delete
after delete on public.military_functions
for each row execute function private.after_military_function_change();

-- Auditoria nas entidades principais.
do $$
declare
  t text;
begin
  foreach t in array array[
    'units','profiles','courses','sections','functions','military_personnel',
    'military_courses','military_sections','military_functions',
    'leaves','vehicles','equipment'
  ]
  loop
    execute format(
      'create trigger %I after insert or update or delete on public.%I
       for each row execute function private.audit_row_change()',
      t || '_audit', t
    );
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- 19. VIEWS DE LEITURA
-- ----------------------------------------------------------------------------

create or replace view public.v_military_status
with (security_invoker = true)
as
select
  mp.id as military_id,
  case
    when exists (
      select 1
      from public.leaves l
      where l.military_id = mp.id
        and l.start_date <= current_date
        and (
          l.is_indefinite = true
          or l.end_date >= current_date
        )
    )
    then 'afastado'
    else 'ativo'
  end as activity_status
from public.military_personnel mp;

create or replace view public.v_current_leaves
with (security_invoker = true)
as
select
  l.id,
  l.military_id,
  l.leave_type_id,
  lt.name as leave_type_name,
  l.start_date,
  l.end_date,
  l.is_indefinite,
  l.detail,
  l.notes
from public.leaves l
join public.leave_types lt on lt.id = l.leave_type_id
where l.start_date <= current_date
  and (
    l.is_indefinite = true
    or l.end_date >= current_date
  );

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
  coalesce(ms.activity_status, 'ativo') as activity_status,
  mp.created_at,
  mp.updated_at
from public.military_personnel mp
join public.units u on u.id = mp.unit_id
join public.ranks r on r.id = mp.rank_id
left join public.v_military_status ms on ms.military_id = mp.id;

-- ----------------------------------------------------------------------------
-- 20. RLS - HABILITAÇÃO
-- ----------------------------------------------------------------------------

alter table public.units enable row level security;
alter table public.profiles enable row level security;
alter table public.ranks enable row level security;
alter table public.courses enable row level security;
alter table public.sections enable row level security;
alter table public.functions enable row level security;
alter table public.leave_types enable row level security;
alter table public.military_personnel enable row level security;
alter table public.military_courses enable row level security;
alter table public.military_sections enable row level security;
alter table public.military_functions enable row level security;
alter table public.leaves enable row level security;
alter table public.vehicles enable row level security;
alter table public.equipment enable row level security;
alter table public.audit_logs enable row level security;

-- ----------------------------------------------------------------------------
-- 21. GRANTS
-- ----------------------------------------------------------------------------

grant usage on schema public to authenticated;

grant select on public.units to authenticated;
grant select on public.ranks to authenticated;
grant select on public.courses to authenticated;
grant select on public.sections to authenticated;
grant select on public.functions to authenticated;
grant select on public.leave_types to authenticated;
grant select on public.military_personnel to authenticated;
grant select on public.military_courses to authenticated;
grant select on public.military_sections to authenticated;
grant select on public.military_functions to authenticated;
grant select on public.leaves to authenticated;
grant select on public.vehicles to authenticated;
grant select on public.equipment to authenticated;

grant select on public.v_military_status to authenticated;
grant select on public.v_current_leaves to authenticated;
grant select on public.v_military_directory to authenticated;

grant insert, update, delete on public.units to authenticated;
grant insert, update, delete on public.courses to authenticated;
grant insert, update, delete on public.sections to authenticated;
grant insert, update, delete on public.functions to authenticated;
grant insert, update, delete on public.military_personnel to authenticated;
grant insert, update, delete on public.military_courses to authenticated;
grant insert, update, delete on public.military_sections to authenticated;
grant insert, update, delete on public.military_functions to authenticated;
grant insert, update, delete on public.leaves to authenticated;
grant insert, update, delete on public.vehicles to authenticated;
grant insert, update, delete on public.equipment to authenticated;

-- Profiles: SELECT/UPDATE controlados abaixo; criação administrativa deve ser
-- feita por código server-side após criar auth.users via Admin API.
grant select, update on public.profiles to authenticated;

-- audit_logs somente leitura para Master por policy.
grant select on public.audit_logs to authenticated;
grant usage, select on sequence public.audit_logs_id_seq to authenticated;

-- ranks e leave_types são catálogo de sistema nesta versão: leitura para todos.
-- Mudanças podem ser feitas por migration. Se futuramente houver CRUD, criar
-- policies Master específicas.

-- ----------------------------------------------------------------------------
-- 22. RLS - LEITURA GLOBAL AUTENTICADA
-- ----------------------------------------------------------------------------

create policy "units_authenticated_read"
on public.units for select
to authenticated
using ((select private.current_user_is_active()));

create policy "ranks_authenticated_read"
on public.ranks for select
to authenticated
using ((select private.current_user_is_active()));

create policy "courses_authenticated_read"
on public.courses for select
to authenticated
using ((select private.current_user_is_active()));

create policy "sections_authenticated_read"
on public.sections for select
to authenticated
using ((select private.current_user_is_active()));

create policy "functions_authenticated_read"
on public.functions for select
to authenticated
using ((select private.current_user_is_active()));

create policy "leave_types_authenticated_read"
on public.leave_types for select
to authenticated
using ((select private.current_user_is_active()));

create policy "military_authenticated_read"
on public.military_personnel for select
to authenticated
using ((select private.current_user_is_active()));

create policy "military_courses_authenticated_read"
on public.military_courses for select
to authenticated
using ((select private.current_user_is_active()));

create policy "military_sections_authenticated_read"
on public.military_sections for select
to authenticated
using ((select private.current_user_is_active()));

create policy "military_functions_authenticated_read"
on public.military_functions for select
to authenticated
using ((select private.current_user_is_active()));

create policy "leaves_authenticated_read"
on public.leaves for select
to authenticated
using ((select private.current_user_is_active()));

create policy "vehicles_authenticated_read"
on public.vehicles for select
to authenticated
using ((select private.current_user_is_active()));

create policy "equipment_authenticated_read"
on public.equipment for select
to authenticated
using ((select private.current_user_is_active()));

-- ----------------------------------------------------------------------------
-- 23. RLS - PROFILES
-- ----------------------------------------------------------------------------

-- Master vê todos os perfis. Usuário vê o próprio perfil.
create policy "profiles_master_or_self_read"
on public.profiles for select
to authenticated
using (
  (select private.current_user_is_active())
  and (
    id = (select auth.uid())
    or (select private.is_master())
  )
);

-- Somente Master pode alterar perfil/role/unidade/estado de usuários.
-- Alterações no auth.users continuam sendo responsabilidade de Admin API server-side.
create policy "profiles_master_update"
on public.profiles for update
to authenticated
using ((select private.is_master()))
with check ((select private.is_master()));

-- ----------------------------------------------------------------------------
-- 24. RLS - MASTER PARA UNIDADES E CATÁLOGOS ADMINISTRÁVEIS
-- ----------------------------------------------------------------------------

create policy "units_master_insert"
on public.units for insert
to authenticated
with check ((select private.is_master()));

create policy "units_master_update"
on public.units for update
to authenticated
using ((select private.is_master()))
with check ((select private.is_master()));

create policy "units_master_delete"
on public.units for delete
to authenticated
using ((select private.is_master()));

create policy "courses_master_write"
on public.courses for all
to authenticated
using ((select private.is_master()))
with check ((select private.is_master()));

create policy "sections_master_write"
on public.sections for all
to authenticated
using ((select private.is_master()))
with check ((select private.is_master()));

create policy "functions_master_write"
on public.functions for all
to authenticated
using ((select private.is_master()))
with check ((select private.is_master()));

-- ----------------------------------------------------------------------------
-- 25. RLS - MILITARES
-- ----------------------------------------------------------------------------

create policy "military_master_editor_insert"
on public.military_personnel for insert
to authenticated
with check (
  (select private.can_write_unit(unit_id))
);

create policy "military_master_editor_update"
on public.military_personnel for update
to authenticated
using (
  (select private.can_write_unit(unit_id))
)
with check (
  (select private.can_write_unit(unit_id))
);

create policy "military_master_editor_delete"
on public.military_personnel for delete
to authenticated
using (
  (select private.can_write_unit(unit_id))
);

-- ----------------------------------------------------------------------------
-- 26. RLS - RELAÇÕES DO MILITAR
-- ----------------------------------------------------------------------------

create policy "military_courses_write"
on public.military_courses for all
to authenticated
using (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
)
with check (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
);

create policy "military_sections_write"
on public.military_sections for all
to authenticated
using (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
)
with check (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
);

create policy "military_functions_write"
on public.military_functions for all
to authenticated
using (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
)
with check (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
);

-- ----------------------------------------------------------------------------
-- 27. RLS - AFASTAMENTOS
-- ----------------------------------------------------------------------------

create policy "leaves_master_editor_insert"
on public.leaves for insert
to authenticated
with check (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
);

create policy "leaves_master_editor_update"
on public.leaves for update
to authenticated
using (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
)
with check (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
);

create policy "leaves_master_editor_delete"
on public.leaves for delete
to authenticated
using (
  (select private.can_write_unit((select private.military_unit_id(military_id))))
);

-- ----------------------------------------------------------------------------
-- 28. RLS - VIATURAS
-- ----------------------------------------------------------------------------

create policy "vehicles_master_editor_insert"
on public.vehicles for insert
to authenticated
with check (
  (select private.can_write_unit(unit_id))
);

create policy "vehicles_master_editor_update"
on public.vehicles for update
to authenticated
using (
  (select private.can_write_unit(unit_id))
)
with check (
  (select private.can_write_unit(unit_id))
);

create policy "vehicles_master_editor_delete"
on public.vehicles for delete
to authenticated
using (
  (select private.can_write_unit(unit_id))
);

-- ----------------------------------------------------------------------------
-- 29. RLS - EQUIPAMENTOS
-- ----------------------------------------------------------------------------

create policy "equipment_master_editor_insert"
on public.equipment for insert
to authenticated
with check (
  (select private.can_write_unit(unit_id))
);

create policy "equipment_master_editor_update"
on public.equipment for update
to authenticated
using (
  (select private.can_write_unit(unit_id))
)
with check (
  (select private.can_write_unit(unit_id))
);

create policy "equipment_master_editor_delete"
on public.equipment for delete
to authenticated
using (
  (select private.can_write_unit(unit_id))
);

-- ----------------------------------------------------------------------------
-- 30. RLS - AUDITORIA
-- ----------------------------------------------------------------------------

create policy "audit_logs_master_read"
on public.audit_logs for select
to authenticated
using ((select private.is_master()));

-- Nenhuma policy INSERT/UPDATE/DELETE é concedida aos clientes.
-- Os inserts são realizados pelo trigger SECURITY DEFINER.

-- ----------------------------------------------------------------------------
-- 31. STORAGE BUCKETS
-- ----------------------------------------------------------------------------
-- Buckets privados: leitura somente por usuário autenticado via RLS.
-- Se preferir URLs públicas, altere "public" para true conscientemente.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'military-photos',
    'military-photos',
    false,
    5242880,
    array['image/jpeg','image/png','image/webp']
  ),
  (
    'vehicle-photos',
    'vehicle-photos',
    false,
    5242880,
    array['image/jpeg','image/png','image/webp']
  )
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Convenção obrigatória dos paths:
--   military-photos/{unit_id}/{military_id}/profile.webp
--   vehicle-photos/{unit_id}/{vehicle_id}/vehicle.webp
--
-- O primeiro segmento identifica a unidade e é validado por RLS.

create policy "storage_authenticated_read_photos"
on storage.objects for select
to authenticated
using (
  (select private.current_user_is_active())
  and bucket_id in ('military-photos', 'vehicle-photos')
);

create policy "storage_master_editor_insert_photos"
on storage.objects for insert
to authenticated
with check (
  bucket_id in ('military-photos', 'vehicle-photos')
  and (storage.foldername(name))[1] is not null
  and (storage.foldername(name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  and (
    select private.can_write_unit(((storage.foldername(name))[1])::uuid)
  )
);

create policy "storage_master_editor_update_photos"
on storage.objects for update
to authenticated
using (
  bucket_id in ('military-photos', 'vehicle-photos')
  and (storage.foldername(name))[1] is not null
  and (storage.foldername(name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  and (
    select private.can_write_unit(((storage.foldername(name))[1])::uuid)
  )
)
with check (
  bucket_id in ('military-photos', 'vehicle-photos')
  and (storage.foldername(name))[1] is not null
  and (storage.foldername(name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  and (
    select private.can_write_unit(((storage.foldername(name))[1])::uuid)
  )
);

create policy "storage_master_editor_delete_photos"
on storage.objects for delete
to authenticated
using (
  bucket_id in ('military-photos', 'vehicle-photos')
  and (storage.foldername(name))[1] is not null
  and (storage.foldername(name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  and (
    select private.can_write_unit(((storage.foldername(name))[1])::uuid)
  )
);

-- ----------------------------------------------------------------------------
-- 32. PERFIL AUTOMÁTICO PARA NOVOS auth.users
-- ----------------------------------------------------------------------------
-- Segurança: todo usuário novo nasce VIEWER e INATIVO se for criado sem
-- metadados administrativos adequados. A aplicação de administração deverá
-- usar Admin API no servidor e depois atualizar public.profiles como Master.
--
-- Não usar raw_user_meta_data para autorização.

create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (
    id,
    full_name,
    email,
    role,
    unit_id,
    is_active
  )
  values (
    new.id,
    coalesce(nullif(btrim(new.raw_user_meta_data ->> 'full_name'), ''), split_part(new.email, '@', 1)),
    new.email,
    'viewer'::public.app_role,
    null,
    false
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_auth_user();

-- ----------------------------------------------------------------------------
-- 33. FUNÇÃO OPCIONAL PARA ATUALIZAR LAST_LOGIN_AT
-- ----------------------------------------------------------------------------

create or replace function public.touch_last_login()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.profiles
  set last_login_at = now()
  where id = (select auth.uid())
    and is_active = true;
$$;

revoke all on function public.touch_last_login() from public;
grant execute on function public.touch_last_login() to authenticated;

-- ----------------------------------------------------------------------------
-- 34. COMENTÁRIOS IMPORTANTES
-- ----------------------------------------------------------------------------

comment on column public.military_personnel.cpf is
'CPF normalizado com 11 dígitos, sem pontuação. Validado também matematicamente por trigger.';

comment on column public.military_personnel.phone is
'Telefone normalizado, somente dígitos. Máscara pertence à camada de UI.';

comment on column public.military_personnel.classification is
'Valor derivado das funções associadas: operacional se ao menos uma função possuir is_operational=true.';

comment on column public.military_personnel.platoon is
'Ala A/B/C/D. Obrigatória quando classification=operacional e nula quando administrativo.';

comment on column public.leaves.detail is
'Detalhe obrigatório somente quando leave_types.requires_detail=true, como no afastamento Curso.';

commit;

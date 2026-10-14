-- ============================================================================
-- Sistema de Gestão do Comando Regional de Bombeiros Militar
-- Migration: 0002_security_rpcs_search_dashboard.sql
-- ============================================================================
-- Esta migration:
--   1. corrige duas regras de integridade da migration inicial;
--   2. cria bootstrap seguro do primeiro Master;
--   3. cria RPC administrativa para configuração de usuários;
--   4. cria RPC atômica para funções/Ala de militares;
--   5. adiciona busca textual eficiente;
--   6. cria RPC de resumo do dashboard;
--   7. endurece algumas permissões.
-- ============================================================================

begin;

-- ----------------------------------------------------------------------------
-- 1. EXTENSÃO PARA BUSCA
-- ----------------------------------------------------------------------------

create extension if not exists pg_trgm with schema extensions;

-- ----------------------------------------------------------------------------
-- 2. CORREÇÃO: PERFIL INATIVO PODE AGUARDAR UNIDADE/ROLE DEFINITIVOS
-- ----------------------------------------------------------------------------
-- A migration inicial cria novos auth.users como viewer + is_active=false +
-- unit_id=null. A constraint original impedia exatamente esse estado.
--
-- Regra final:
--   * Master pode não possuir unidade.
--   * Conta inativa pode ficar sem unidade durante provisionamento.
--   * Editor/Viewer ATIVOS obrigatoriamente têm unidade.

alter table public.profiles
  drop constraint if exists profiles_master_unit_rule;

alter table public.profiles
  add constraint profiles_master_unit_rule check (
    role = 'master'
    or is_active = false
    or unit_id is not null
  );

-- ----------------------------------------------------------------------------
-- 3. CORREÇÃO: TRANSIÇÃO ADMINISTRATIVO <-> OPERACIONAL
-- ----------------------------------------------------------------------------
-- A CHECK original era imediata e criava um impasse:
--   * administrativo não podia receber Ala antes da função operacional;
--   * função operacional não podia ser associada sem Ala.
--
-- Substituímos por constraint trigger DEFERRABLE. Assim a transação pode passar
-- por um estado intermediário, mas ao COMMIT o estado final obrigatoriamente é:
--
--   operacional    => Ala não nula
--   administrativo => Ala nula

alter table public.military_personnel
  drop constraint if exists military_operational_platoon_rule;

create or replace function private.validate_military_final_state()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_classification public.military_classification;
  v_platoon public.platoon_code;
  v_id uuid;
begin
  v_id := coalesce(new.id, old.id);

  select mp.classification, mp.platoon
    into v_classification, v_platoon
  from public.military_personnel mp
  where mp.id = v_id;

  -- Registro pode ter sido excluído.
  if not found then
    return coalesce(new, old);
  end if;

  if v_classification = 'operacional' and v_platoon is null then
    raise exception 'A Ala é obrigatória para militares operacionais.'
      using errcode = '23514';
  end if;

  if v_classification = 'administrativo' and v_platoon is not null then
    raise exception 'Militares administrativos não podem permanecer vinculados a uma Ala.'
      using errcode = '23514';
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists military_final_state_constraint on public.military_personnel;

create constraint trigger military_final_state_constraint
after insert or update on public.military_personnel
deferrable initially deferred
for each row
execute function private.validate_military_final_state();

-- ----------------------------------------------------------------------------
-- 4. BOOTSTRAP SEGURO DO PRIMEIRO MASTER
-- ----------------------------------------------------------------------------
-- Esta função NÃO é acessível ao browser/autenticado.
-- Deve ser chamada somente com service_role em ambiente server-side/local.
--
-- Uso:
--   select public.bootstrap_first_master('<auth-user-uuid>');
--
-- Só funciona se ainda não existir Master ativo.

create or replace function public.bootstrap_first_master(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (
    select 1
    from public.profiles p
    where p.role = 'master'
      and p.is_active = true
  ) then
    raise exception 'Já existe um usuário Master ativo.'
      using errcode = '42501';
  end if;

  if not exists (
    select 1
    from auth.users u
    where u.id = p_user_id
  ) then
    raise exception 'Usuário de autenticação não encontrado.'
      using errcode = 'P0002';
  end if;

  update public.profiles
  set
    role = 'master',
    unit_id = null,
    is_active = true,
    updated_at = now()
  where id = p_user_id;

  if not found then
    raise exception 'Perfil do usuário não encontrado.'
      using errcode = 'P0002';
  end if;
end;
$$;

revoke all on function public.bootstrap_first_master(uuid) from public;
revoke all on function public.bootstrap_first_master(uuid) from anon;
revoke all on function public.bootstrap_first_master(uuid) from authenticated;
grant execute on function public.bootstrap_first_master(uuid) to service_role;

comment on function public.bootstrap_first_master(uuid) is
'Bootstrap server-side do primeiro Master. Nunca expor service_role no frontend.';

-- ----------------------------------------------------------------------------
-- 5. RPC MASTER PARA CONFIGURAÇÃO DE PERFIL
-- ----------------------------------------------------------------------------
-- A criação de auth.users continua devendo ocorrer via Admin API server-side.
-- Após a criação, esta RPC permite ao Master configurar o perfil de aplicação.

create or replace function public.admin_configure_user(
  p_user_id uuid,
  p_full_name text,
  p_role public.app_role,
  p_unit_id uuid default null,
  p_is_active boolean default true
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
begin
  if not (select private.is_master()) then
    raise exception 'Apenas usuários Master podem administrar usuários.'
      using errcode = '42501';
  end if;

  if p_full_name is null or btrim(p_full_name) = '' then
    raise exception 'Nome completo é obrigatório.'
      using errcode = '23514';
  end if;

  if p_role <> 'master'::public.app_role
     and p_is_active = true
     and p_unit_id is null then
    raise exception 'Editor e Viewer ativos devem possuir uma unidade.'
      using errcode = '23514';
  end if;

  if p_unit_id is not null and not exists (
    select 1
    from public.units u
    where u.id = p_unit_id
      and u.is_active = true
  ) then
    raise exception 'Unidade inválida ou inativa.'
      using errcode = '23514';
  end if;

  if not exists (select 1 from auth.users u where u.id = p_user_id) then
    raise exception 'Usuário de autenticação não encontrado.'
      using errcode = 'P0002';
  end if;

  update public.profiles
  set
    full_name = btrim(p_full_name),
    role = p_role,
    unit_id = case when p_role = 'master' then p_unit_id else p_unit_id end,
    is_active = p_is_active,
    updated_at = now()
  where id = p_user_id
  returning * into v_profile;

  if v_profile.id is null then
    raise exception 'Perfil não encontrado.'
      using errcode = 'P0002';
  end if;

  return v_profile;
end;
$$;

revoke all on function public.admin_configure_user(uuid, text, public.app_role, uuid, boolean) from public;
grant execute on function public.admin_configure_user(uuid, text, public.app_role, uuid, boolean)
  to authenticated;

-- ----------------------------------------------------------------------------
-- 6. RPC ATÔMICA PARA FUNÇÕES + ALA
-- ----------------------------------------------------------------------------
-- Deve ser usada pela aplicação ao salvar Funções/Ala do militar.
-- Evita estados intermediários e garante:
--   * somente funções ativas;
--   * ausência de duplicidades;
--   * Ala obrigatória quando existir função operacional;
--   * Ala nula quando todas forem administrativas;
--   * autorização por unidade.

create or replace function public.set_military_functions(
  p_military_id uuid,
  p_function_ids uuid[],
  p_platoon public.platoon_code default null
)
returns public.military_personnel
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_unit_id uuid;
  v_operational boolean;
  v_expected_count integer;
  v_valid_count integer;
  v_result public.military_personnel;
begin
  select mp.unit_id
    into v_unit_id
  from public.military_personnel mp
  where mp.id = p_military_id
  for update;

  if v_unit_id is null then
    raise exception 'Militar não encontrado.'
      using errcode = 'P0002';
  end if;

  if not (select private.can_write_unit(v_unit_id)) then
    raise exception 'Você não possui permissão para alterar este militar.'
      using errcode = '42501';
  end if;

  if p_function_ids is null or cardinality(p_function_ids) = 0 then
    raise exception 'Selecione pelo menos uma função.'
      using errcode = '23514';
  end if;

  select count(distinct x)
    into v_expected_count
  from unnest(p_function_ids) x;

  select count(*)
    into v_valid_count
  from public.functions f
  where f.id = any(p_function_ids)
    and f.is_active = true;

  if v_valid_count <> v_expected_count then
    raise exception 'Uma ou mais funções são inválidas, inativas ou duplicadas.'
      using errcode = '23514';
  end if;

  select exists (
    select 1
    from public.functions f
    where f.id = any(p_function_ids)
      and f.is_active = true
      and f.is_operational = true
  )
  into v_operational;

  if v_operational and p_platoon is null then
    raise exception 'A Ala é obrigatória para militares operacionais.'
      using errcode = '23514';
  end if;

  if not v_operational and p_platoon is not null then
    raise exception 'A Ala somente pode ser informada para militares operacionais.'
      using errcode = '23514';
  end if;

  -- Primeiro remove as associações atuais. Os triggers sincronizam estado.
  delete from public.military_functions
  where military_id = p_military_id;

  -- Define a Ala antes de inserir função operacional.
  update public.military_personnel
  set platoon = p_platoon
  where id = p_military_id;

  insert into public.military_functions (military_id, function_id)
  select p_military_id, x
  from unnest(p_function_ids) x;

  -- Garante a classificação final mesmo se todos os gatilhos já a tiverem
  -- sincronizado.
  perform private.sync_military_classification(p_military_id);

  select *
    into v_result
  from public.military_personnel
  where id = p_military_id;

  return v_result;
end;
$$;

revoke all on function public.set_military_functions(uuid, uuid[], public.platoon_code) from public;
grant execute on function public.set_military_functions(uuid, uuid[], public.platoon_code)
  to authenticated;

-- ----------------------------------------------------------------------------
-- 7. BUSCA TEXTUAL
-- ----------------------------------------------------------------------------

create index if not exists military_full_name_trgm_idx
  on public.military_personnel
  using gin (lower(full_name) extensions.gin_trgm_ops);

create index if not exists military_war_name_trgm_idx
  on public.military_personnel
  using gin (lower(war_name) extensions.gin_trgm_ops);

create index if not exists military_rg_trgm_idx
  on public.military_personnel
  using gin (lower(rg) extensions.gin_trgm_ops);

-- Pesquisa para autocomplete/quick search.
-- CPF é normalizado na consulta, permitindo buscar com ou sem pontuação.

create or replace function public.search_military(
  p_query text,
  p_unit_id uuid default null,
  p_limit integer default 20
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
      p_query is null
      or btrim(p_query) = ''
      or lower(d.full_name) OPERATOR(extensions.%) lower(btrim(p_query))
      or lower(d.war_name) OPERATOR(extensions.%) lower(btrim(p_query))
      or lower(d.rg) like '%' || lower(btrim(p_query)) || '%'
      or d.cpf like '%' || regexp_replace(p_query, '\D', '', 'g') || '%'
      or lower(d.full_name) like '%' || lower(btrim(p_query)) || '%'
      or lower(d.war_name) like '%' || lower(btrim(p_query)) || '%'
    )
  order by d.rank_order, d.war_name, d.full_name
  limit least(greatest(coalesce(p_limit, 20), 1), 100);
$$;

revoke all on function public.search_military(text, uuid, integer) from public;
grant execute on function public.search_military(text, uuid, integer) to authenticated;

-- ----------------------------------------------------------------------------
-- 8. DASHBOARD
-- ----------------------------------------------------------------------------
-- Uma única chamada fornece os números básicos. Os dados detalhados podem
-- continuar sendo consultados pelas views/tabelas.
--
-- Todos os usuários autenticados ativos podem escolher qualquer unidade,
-- pois a regra do sistema permite leitura global.

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
    where p_unit_id is null or d.unit_id = p_unit_id
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
      'total', (select count(*) from vehicle),
      'active', (select count(*) from vehicle where status = 'ativo'),
      'withdrawn', (select count(*) from vehicle where status = 'baixado'),
      'loaned', (select count(*) from vehicle where status = 'cautelado'),
      'poor', (select count(*) from vehicle where conservation_state = 'ruim'),
      'unserviceable', (select count(*) from vehicle where conservation_state = 'inservivel')
    ),
    'equipment', jsonb_build_object(
      'records', (select count(*) from equip),
      'totalQuantity', (select coalesce(sum(quantity), 0) from equip),
      'poorQuantity', (
        select coalesce(sum(quantity), 0)
        from equip where conservation_state = 'ruim'
      ),
      'unserviceableQuantity', (
        select coalesce(sum(quantity), 0)
        from equip where conservation_state = 'inservivel'
      )
    )
  );
$$;

revoke all on function public.dashboard_summary(uuid) from public;
grant execute on function public.dashboard_summary(uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 9. FUNÇÃO DE DETALHE DAS FUNÇÕES DO MILITAR
-- ----------------------------------------------------------------------------

create or replace view public.v_military_functions
with (security_invoker = true)
as
select
  mf.military_id,
  f.id as function_id,
  f.name as function_name,
  f.is_operational,
  f.is_active
from public.military_functions mf
join public.functions f on f.id = mf.function_id;

grant select on public.v_military_functions to authenticated;

-- ----------------------------------------------------------------------------
-- 10. HARDENING DE EXECUTE
-- ----------------------------------------------------------------------------
-- Por padrão, funções PostgreSQL podem receber EXECUTE de PUBLIC.
-- Revogamos explicitamente das funções de negócio sensíveis e concedemos
-- somente aos papéis esperados.

revoke all on function private.validate_military_final_state() from public;
revoke all on function private.compute_military_classification(uuid) from public;
revoke all on function private.sync_military_classification(uuid) from public;
revoke all on function private.validate_operational_function_assignment() from public;
revoke all on function private.after_military_function_change() from public;

commit;

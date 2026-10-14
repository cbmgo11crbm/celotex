begin;

-- 0040_military_user_sync_and_editor_user_admin.sql
-- Sincroniza a unidade do perfil de usuário com a unidade do militar
-- e cria RPC para que editores administrem perfis não-master da sua unidade.

-- Trigger: quando a unidade do militar mudar, atualiza unit_id em profiles
create or replace function private.sync_profile_unit_from_military()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' and new.unit_id is distinct from old.unit_id then
    update public.profiles p
    set unit_id = new.unit_id,
        updated_at = now()
    where lower(p.email::text) = lower(new.email::text)
      and p.is_active = true;
  end if;

  return new;
end;
$$;

create trigger trg_sync_profile_unit_from_military
after update of unit_id, email on public.military_personnel
for each row
when (old.unit_id is distinct from new.unit_id or old.email is distinct from new.email)
execute function private.sync_profile_unit_from_military();

-- RPC: permite que editores administrem perfis não-master da própria unidade.
-- Masters continuam podendo tudo via admin_configure_user.

create or replace function public.editor_configure_user(
  p_user_id uuid,
  p_full_name text,
  p_role public.app_role,
  p_is_active boolean default true
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
  v_current_role public.app_role;
  v_current_unit uuid;
  v_self_profile public.profiles;
begin
  -- Apenas editores podem usar esta função.
  if not (select private.current_user_role() = 'editor'::public.app_role) then
    raise exception 'Apenas usuários Editor podem usar esta operação.'
      using errcode = '42501';
  end if;

  select * into v_self_profile
  from public.profiles
  where id = (select auth.uid());

  if v_self_profile.id is null or v_self_profile.unit_id is null then
    raise exception 'Editor sem unidade associada.'
      using errcode = '23514';
  end if;

  -- Não permite que editor altere perfis Master
  select role, unit_id into v_current_role, v_current_unit
  from public.profiles
  where id = p_user_id;

  if v_current_role is null then
    raise exception 'Perfil não encontrado.'
      using errcode = 'P0002';
  end if;

  if v_current_role = 'master'::public.app_role then
    raise exception 'Editores não podem alterar perfis Master.'
      using errcode = '42501';
  end if;

  -- Editor só pode alterar perfis da sua própria unidade
  if v_current_unit is distinct from v_self_profile.unit_id then
    raise exception 'Editor só pode administrar usuários da sua própria unidade.'
      using errcode = '42501';
  end if;

  if p_full_name is null or btrim(p_full_name) = '' then
    raise exception 'Nome completo é obrigatório.'
      using errcode = '23514';
  end if;

  -- Editor não pode promover ninguém a Master
  if p_role = 'master'::public.app_role then
    raise exception 'Editores não podem atribuir perfil Master.'
      using errcode = '42501';
  end if;

  update public.profiles
  set
    full_name = btrim(p_full_name),
    role = p_role,
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

revoke all on function public.editor_configure_user(uuid, text, public.app_role, boolean) from public;
grant execute on function public.editor_configure_user(uuid, text, public.app_role, boolean)
  to authenticated;

-- Ajustes de RLS em profiles para permitir que editores administrem
-- perfis não-master da própria unidade.

drop policy if exists "profiles_master_or_self_read" on public.profiles;
drop policy if exists "profiles_master_update" on public.profiles;

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

-- Editor pode ler perfis não-master de sua unidade.
create policy "profiles_editor_read_same_unit_non_master"
on public.profiles for select
to authenticated
using (
  (select private.current_user_is_active())
  and (select private.current_user_role()) = 'editor'::public.app_role
  and role <> 'master'::public.app_role
  and unit_id = (select private.current_user_unit_id())
);

-- Somente Master pode alterar perfil/role/unidade/estado de usuários via UPDATE direto.
create policy "profiles_master_update"
on public.profiles for update
to authenticated
using ((select private.is_master()))
with check ((select private.is_master()));

-- Editor pode atualizar perfis não-master de sua unidade.
create policy "profiles_editor_update_same_unit_non_master"
on public.profiles for update
to authenticated
using (
  (select private.current_user_role()) = 'editor'::public.app_role
  and role <> 'master'::public.app_role
  and unit_id = (select private.current_user_unit_id())
)
with check (
  (select private.current_user_role()) = 'editor'::public.app_role
  and role <> 'master'::public.app_role
  and unit_id = (select private.current_user_unit_id())
);

commit;

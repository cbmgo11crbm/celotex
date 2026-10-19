begin;

-- 0059_admin_user_crud.sql
-- RPCs para que usuários Master criem e removam usuários diretamente
-- no Authentication (auth.users/auth.identities), além do perfil.

create or replace function public.admin_create_user(
  p_email text,
  p_password text,
  p_full_name text,
  p_role public.app_role default 'viewer',
  p_unit_id uuid default null
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid;
  v_email text;
  v_profile public.profiles;
begin
  if not (select private.is_master()) then
    raise exception 'Apenas usuários Master podem criar usuários.'
      using errcode = '42501';
  end if;

  if p_email is null or btrim(p_email) = '' then
    raise exception 'E-mail é obrigatório.'
      using errcode = '23514';
  end if;

  v_email := lower(btrim(p_email));

  if p_password is null or length(p_password) < 6 then
    raise exception 'A senha deve ter pelo menos 6 caracteres.'
      using errcode = '23514';
  end if;

  if p_full_name is null or btrim(p_full_name) = '' then
    raise exception 'Nome completo é obrigatório.'
      using errcode = '23514';
  end if;

  if p_role <> 'master'::public.app_role and p_unit_id is null then
    raise exception 'Editor e Viewer devem possuir uma unidade.'
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

  if exists (select 1 from auth.users u where lower(u.email::text) = lower(v_email::text)) then
    raise exception 'Já existe um usuário com este e-mail.'
      using errcode = '23505';
  end if;

  v_user_id := gen_random_uuid();

  insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  )
  values (
    '00000000-0000-0000-0000-000000000000',
    v_user_id,
    'authenticated',
    'authenticated',
    v_email::text,
    public.crypt(p_password, public.gen_salt('bf')),
    now(),
    now(),
    '',
    '',
    '',
    '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', btrim(p_full_name)),
    now(),
    now()
  );

  insert into auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  )
  values (
    gen_random_uuid(),
    v_user_id,
    v_email::text,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email::text),
    'email',
    now(),
    now(),
    now()
  );

  insert into public.profiles (id, full_name, email, role, unit_id, is_active)
  values (
    v_user_id,
    btrim(p_full_name),
    v_email::public.citext,
    p_role,
    case when p_role = 'master' then null else p_unit_id end,
    true
  )
  on conflict (id) do update
    set full_name = excluded.full_name,
        role = excluded.role,
        unit_id = excluded.unit_id,
        is_active = excluded.is_active,
        updated_at = now()
  returning * into v_profile;

  return v_profile;
end;
$$;

revoke all on function public.admin_create_user(text, text, text, public.app_role, uuid) from public;
grant execute on function public.admin_create_user(text, text, text, public.app_role, uuid)
  to authenticated;

create or replace function public.admin_delete_user(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not (select private.is_master()) then
    raise exception 'Apenas usuários Master podem excluir usuários.'
      using errcode = '42501';
  end if;

  if p_user_id = (select auth.uid()) then
    raise exception 'Você não pode excluir o próprio usuário.'
      using errcode = '42501';
  end if;

  if not exists (select 1 from auth.users u where u.id = p_user_id) then
    raise exception 'Usuário não encontrado.'
      using errcode = 'P0002';
  end if;

  delete from auth.users where id = p_user_id;
end;
$$;

revoke all on function public.admin_delete_user(uuid) from public;
grant execute on function public.admin_delete_user(uuid) to authenticated;

commit;

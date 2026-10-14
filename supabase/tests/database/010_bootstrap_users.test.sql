begin;

create extension if not exists pgtap with schema extensions;

select plan(9);

insert into public.units (id, acronym, name)
values ('13000000-0000-4000-8000-000000000001', 'USR-A', 'Unidade Usuários A')
on conflict (id) do nothing;

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  (
    '23000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'first.master@test.local', '',
    now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '23000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'new.editor@test.local', '',
    now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  )
on conflict (id) do nothing;

select is(
  (select is_active from public.profiles where id = '23000000-0000-4000-8000-000000000001'),
  false,
  'Novo auth.user nasce inativo'
);

select is(
  (select role::text from public.profiles where id = '23000000-0000-4000-8000-000000000001'),
  'viewer',
  'Novo auth.user nasce como viewer'
);

select is(
  (select unit_id::text from public.profiles where id = '23000000-0000-4000-8000-000000000001'),
  null,
  'Novo auth.user pode aguardar unidade enquanto inativo'
);

-- Executado como owner/superuser no teste para validar lógica de bootstrap.
select lives_ok(
  $$select public.bootstrap_first_master('23000000-0000-4000-8000-000000000001')$$,
  'Primeiro Master pode ser inicializado'
);

select is(
  (select role::text from public.profiles where id = '23000000-0000-4000-8000-000000000001'),
  'master',
  'Bootstrap define role Master'
);

select ok(
  (select is_active from public.profiles where id = '23000000-0000-4000-8000-000000000001'),
  'Bootstrap ativa primeiro Master'
);

select throws_ok(
  $$select public.bootstrap_first_master('23000000-0000-4000-8000-000000000002')$$,
  '42501',
  'Já existe um usuário Master ativo.',
  'Segundo bootstrap é rejeitado'
);

-- Simula Master autenticado e configura o segundo usuário como Editor.
set local role authenticated;
select set_config('request.jwt.claim.sub', '23000000-0000-4000-8000-000000000001', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"23000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select lives_ok(
  $$select public.admin_configure_user(
      '23000000-0000-4000-8000-000000000002',
      'Novo Editor',
      'editor'::public.app_role,
      '13000000-0000-4000-8000-000000000001',
      true
    )$$,
  'Master configura usuário por RPC'
);

select is(
  (select role::text || ':' || is_active::text
   from public.profiles
   where id = '23000000-0000-4000-8000-000000000002'),
  'editor:true',
  'Novo usuário fica Editor ativo'
);

reset role;

select * from finish();
rollback;

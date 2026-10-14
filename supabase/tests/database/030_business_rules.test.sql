begin;

create extension if not exists pgtap with schema extensions;

select plan(17);

-- ---------------------------------------------------------------------------
-- FIXTURES BÁSICAS
-- ---------------------------------------------------------------------------

insert into public.units (id, acronym, name)
values ('11000000-0000-4000-8000-000000000001', 'BUS-A', 'Unidade Business A')
on conflict (id) do nothing;

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values (
  '21000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'editor.business@test.local', '',
  now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
  now(), now()
)
on conflict (id) do nothing;

update public.profiles
set full_name = 'Editor Business', role = 'editor',
    unit_id = '11000000-0000-4000-8000-000000000001', is_active = true
where id = '21000000-0000-4000-8000-000000000001';

insert into public.ranks (id, code, name, sort_order)
values ('31000000-0000-4000-8000-000000000001', 'BIZ', 'Graduação Business', 98)
on conflict (id) do nothing;

insert into public.functions (id, name, is_operational)
values
  ('51000000-0000-4000-8000-000000000001', 'Função Administrativa Teste', false),
  ('51000000-0000-4000-8000-000000000002', 'Função Operacional Teste', true)
on conflict (id) do nothing;

insert into public.leave_types (id, name, requires_detail, sort_order)
values
  ('61000000-0000-4000-8000-000000000001', 'Curso Teste', true, 991),
  ('61000000-0000-4000-8000-000000000002', 'Férias Teste', false, 992)
on conflict (id) do nothing;

insert into public.military_personnel (
  id, unit_id, rank_id, rg, full_name, war_name, birth_date,
  phone, cpf, driver_license_category
)
values (
  '41000000-0000-4000-8000-000000000001',
  '11000000-0000-4000-8000-000000000001',
  '31000000-0000-4000-8000-000000000001',
  'RG-BIZ', 'Militar Regras', 'Regras', '1990-01-01',
  '62999990003', '12345678909', 'AB'
);

-- CPF acima é válido? O teste abaixo confirma pela função.
select ok(
  private.is_valid_cpf('52998224725'),
  'CPF válido é reconhecido'
);

select ok(
  not private.is_valid_cpf('11111111111'),
  'CPF repetido inválido é rejeitado'
);

select ok(
  not private.is_valid_cpf('12345678900'),
  'CPF com dígito verificador incorreto é rejeitado'
);

-- A fixture usou 12345678909; confirme validade para não mascarar erro.
select ok(
  private.is_valid_cpf('12345678909'),
  'CPF da fixture é matematicamente válido'
);

-- Autentica Editor.
set local role authenticated;
select set_config('request.jwt.claim.sub', '21000000-0000-4000-8000-000000000001', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"21000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

-- Somente função administrativa.
select lives_ok(
  $$select public.set_military_functions(
      '41000000-0000-4000-8000-000000000001',
      array['51000000-0000-4000-8000-000000000001']::uuid[],
      null
    )$$,
  'RPC aceita função administrativa sem Ala'
);

select is(
  (select classification::text from public.military_personnel
   where id = '41000000-0000-4000-8000-000000000001'),
  'administrativo',
  'Função administrativa gera classificação administrativo'
);

select is(
  (select platoon::text from public.military_personnel
   where id = '41000000-0000-4000-8000-000000000001'),
  null,
  'Administrativo permanece sem Ala'
);

-- Operacional sem Ala.
select throws_ok(
  $$select public.set_military_functions(
      '41000000-0000-4000-8000-000000000001',
      array['51000000-0000-4000-8000-000000000002']::uuid[],
      null
    )$$,
  '23514',
  'A Ala é obrigatória para militares operacionais.',
  'RPC rejeita função operacional sem Ala'
);

-- Operacional com Ala C.
select lives_ok(
  $$select public.set_military_functions(
      '41000000-0000-4000-8000-000000000001',
      array[
        '51000000-0000-4000-8000-000000000001',
        '51000000-0000-4000-8000-000000000002'
      ]::uuid[],
      'C'::public.platoon_code
    )$$,
  'RPC aceita função operacional com Ala'
);

select is(
  (select classification::text from public.military_personnel
   where id = '41000000-0000-4000-8000-000000000001'),
  'operacional',
  'Presença de função operacional gera classificação operacional'
);

select is(
  (select platoon::text from public.military_personnel
   where id = '41000000-0000-4000-8000-000000000001'),
  'C',
  'Ala C foi persistida'
);

-- Volta para administrativo e a Ala precisa ser limpa.
select lives_ok(
  $$select public.set_military_functions(
      '41000000-0000-4000-8000-000000000001',
      array['51000000-0000-4000-8000-000000000001']::uuid[],
      null
    )$$,
  'RPC permite retornar a administrativo'
);

select is(
  (select platoon::text from public.military_personnel
   where id = '41000000-0000-4000-8000-000000000001'),
  null,
  'Ao retornar a administrativo a Ala fica nula'
);

-- Afastamento Curso exige detalhe.
select throws_ok(
  $$insert into public.leaves (
      military_id, leave_type_id, start_date, end_date, is_indefinite
    ) values (
      '41000000-0000-4000-8000-000000000001',
      '61000000-0000-4000-8000-000000000001',
      current_date, current_date + 10, false
    )$$,
  '23514',
  'Este tipo de afastamento exige detalhamento.',
  'Afastamento Curso exige nome/detalhe'
);

select lives_ok(
  $$insert into public.leaves (
      military_id, leave_type_id, start_date, end_date, is_indefinite, detail
    ) values (
      '41000000-0000-4000-8000-000000000001',
      '61000000-0000-4000-8000-000000000001',
      current_date, current_date + 10, false, 'Curso Operacional Teste'
    )$$,
  'Afastamento Curso com detalhe é aceito'
);

select is(
  (select activity_status from public.v_military_status
   where military_id = '41000000-0000-4000-8000-000000000001'),
  'afastado',
  'Militar com afastamento vigente aparece como afastado'
);

-- Período inválido.
select throws_ok(
  $$insert into public.leaves (
      military_id, leave_type_id, start_date, end_date, is_indefinite
    ) values (
      '41000000-0000-4000-8000-000000000001',
      '61000000-0000-4000-8000-000000000002',
      current_date + 10, current_date, false
    )$$,
  '23514',
  null,
  'Data final anterior à inicial é rejeitada'
);

reset role;

select * from finish();
rollback;

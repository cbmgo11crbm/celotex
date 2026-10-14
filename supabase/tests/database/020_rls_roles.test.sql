begin;

create extension if not exists pgtap with schema extensions;

select plan(19);

insert into public.units (id, acronym, name, municipality)
values
  ('10000000-0000-4000-8000-000000000001', 'TEST-A', 'Unidade Teste A', 'Goiânia'),
  ('10000000-0000-4000-8000-000000000002', 'TEST-B', 'Unidade Teste B', 'Goiânia')
on conflict (id) do nothing;

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  ('20000000-0000-4000-8000-000000000001','00000000-0000-0000-0000-000000000000','authenticated','authenticated','master@test.local','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()),
  ('20000000-0000-4000-8000-000000000002','00000000-0000-0000-0000-000000000000','authenticated','authenticated','editor.a@test.local','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()),
  ('20000000-0000-4000-8000-000000000003','00000000-0000-0000-0000-000000000000','authenticated','authenticated','editor.b@test.local','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now()),
  ('20000000-0000-4000-8000-000000000004','00000000-0000-0000-0000-000000000000','authenticated','authenticated','viewer@test.local','',now(),'{"provider":"email","providers":["email"]}'::jsonb,'{}'::jsonb,now(),now())
on conflict (id) do nothing;

update public.profiles set full_name='Master Teste', role='master', unit_id=null, is_active=true
where id='20000000-0000-4000-8000-000000000001';
update public.profiles set full_name='Editor A', role='editor', unit_id='10000000-0000-4000-8000-000000000001', is_active=true
where id='20000000-0000-4000-8000-000000000002';
update public.profiles set full_name='Editor B', role='editor', unit_id='10000000-0000-4000-8000-000000000002', is_active=true
where id='20000000-0000-4000-8000-000000000003';
update public.profiles set full_name='Viewer', role='viewer', unit_id='10000000-0000-4000-8000-000000000001', is_active=true
where id='20000000-0000-4000-8000-000000000004';

insert into public.ranks (id, code, name, sort_order)
values ('30000000-0000-4000-8000-000000000001', 'TST', 'Posto Teste', 99)
on conflict (id) do nothing;

insert into public.military_personnel (
  id, unit_id, rank_id, rg, full_name, war_name, birth_date,
  phone, cpf, driver_license_category
)
values
  ('40000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000001','RG-A','Militar Unidade A','Militar A','1990-01-01','62999990001','52998224725','B'),
  ('40000000-0000-4000-8000-000000000002','10000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000001','RG-B','Militar Unidade B','Militar B','1991-01-01','62999990002','11144477735','D');

-- MASTER
set local role authenticated;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000001',true);
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000001","role":"authenticated"}',true);

select is((select count(*)::integer from public.military_personnel),2,'Master visualiza militares das duas unidades');
select lives_ok($$update public.military_personnel set war_name='A editado Master' where id='40000000-0000-4000-8000-000000000001'$$,'Master edita Unidade A');
select lives_ok($$update public.military_personnel set war_name='B editado Master' where id='40000000-0000-4000-8000-000000000002'$$,'Master edita Unidade B');
reset role;

-- EDITOR A
set local role authenticated;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000002',true);
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000002","role":"authenticated"}',true);

select is((select count(*)::integer from public.military_personnel),2,'Editor A visualiza militares de todas as unidades');
select lives_ok($$update public.military_personnel set war_name='Editor A permitido' where id='40000000-0000-4000-8000-000000000001'$$,'Editor A consegue executar UPDATE na própria unidade');
select is((select war_name from public.military_personnel where id='40000000-0000-4000-8000-000000000001'),'Editor A permitido','Editor A altera efetivamente registro da própria unidade');
select lives_ok($$update public.military_personnel set war_name='Editor A proibido' where id='40000000-0000-4000-8000-000000000002'$$,'UPDATE fora da unidade não gera erro, mas RLS filtra a linha');
select is((select war_name from public.military_personnel where id='40000000-0000-4000-8000-000000000002'),'B editado Master','Editor A não altera registro da Unidade B');
select throws_ok(
  $$insert into public.vehicles (unit_id,vtr,brand,model,year,conservation_state,status,location)
    values ('10000000-0000-4000-8000-000000000002','VTR-PROIBIDA','Marca','Modelo',2026,'bom','ativo','Teste')$$,
  '42501', null, 'Editor A não insere viatura na Unidade B'
);
reset role;

-- EDITOR B
set local role authenticated;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000003',true);
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000003","role":"authenticated"}',true);

select lives_ok($$update public.military_personnel set war_name='Editor B proibido' where id='40000000-0000-4000-8000-000000000001'$$,'UPDATE de Editor B sobre Unidade A é filtrado por RLS');
select is((select war_name from public.military_personnel where id='40000000-0000-4000-8000-000000000001'),'Editor A permitido','Editor B não altera registro da Unidade A');
select lives_ok($$update public.military_personnel set war_name='Editor B permitido' where id='40000000-0000-4000-8000-000000000002'$$,'Editor B consegue editar registro da própria unidade');
select is((select war_name from public.military_personnel where id='40000000-0000-4000-8000-000000000002'),'Editor B permitido','Editor B altera efetivamente registro da própria unidade');
reset role;

-- VIEWER
set local role authenticated;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000004',true);
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000004","role":"authenticated"}',true);

select is((select count(*)::integer from public.military_personnel),2,'Viewer visualiza militares das duas unidades');
select lives_ok($$update public.military_personnel set war_name='Viewer proibido' where id='40000000-0000-4000-8000-000000000001'$$,'UPDATE do Viewer é filtrado por RLS');
select is((select war_name from public.military_personnel where id='40000000-0000-4000-8000-000000000001'),'Editor A permitido','Viewer não altera militar');
select throws_ok(
  $$insert into public.equipment (unit_id,item,quantity,conservation_state)
    values ('10000000-0000-4000-8000-000000000001','Equipamento proibido',1,'bom')$$,
  '42501', null, 'Viewer não cadastra equipamento'
);
reset role;

-- INATIVO
update public.profiles set is_active=false where id='20000000-0000-4000-8000-000000000004';

set local role authenticated;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000004',true);
select set_config('request.jwt.claims','{"sub":"20000000-0000-4000-8000-000000000004","role":"authenticated"}',true);

select is((select count(*)::integer from public.military_personnel),0,'Usuário inativo não visualiza militares');
select is((select count(*)::integer from public.units),0,'Usuário inativo não visualiza unidades');

reset role;

select * from finish();
rollback;

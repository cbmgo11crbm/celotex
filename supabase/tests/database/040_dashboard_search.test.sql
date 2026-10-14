begin;

create extension if not exists pgtap with schema extensions;

select plan(12);

insert into public.units (id, acronym, name)
values
  ('12000000-0000-4000-8000-000000000001', 'DASH-A', 'Unidade Dashboard A'),
  ('12000000-0000-4000-8000-000000000002', 'DASH-B', 'Unidade Dashboard B')
on conflict (id) do nothing;

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values (
  '22000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'viewer.dashboard@test.local', '',
  now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
  now(), now()
)
on conflict (id) do nothing;

update public.profiles
set full_name='Viewer Dashboard', role='viewer',
    unit_id='12000000-0000-4000-8000-000000000001', is_active=true
where id='22000000-0000-4000-8000-000000000001';

insert into public.ranks (id, code, name, sort_order)
values ('32000000-0000-4000-8000-000000000001', 'DSH', 'Graduação Dashboard', 97)
on conflict (id) do nothing;

insert into public.military_personnel (
  id, unit_id, rank_id, rg, full_name, war_name, birth_date,
  phone, cpf, driver_license_category, driver_license_expiration
)
values
  ('42000000-0000-4000-8000-000000000001','12000000-0000-4000-8000-000000000001','32000000-0000-4000-8000-000000000001','DASH-RG-1','João da Silva Dashboard','Silva','1990-01-01','62999991001','52998224725','D',current_date+15),
  ('42000000-0000-4000-8000-000000000002','12000000-0000-4000-8000-000000000002','32000000-0000-4000-8000-000000000001','DASH-RG-2','Maria Oliveira Dashboard','Oliveira','1991-01-01','62999991002','11144477735','B',current_date-5);

insert into public.vehicles (unit_id,vtr,brand,model,year,conservation_state,status,location)
values
  ('12000000-0000-4000-8000-000000000001','DASH-VTR-A','Marca A','Modelo A',2025,'bom','ativo','Garagem A'),
  ('12000000-0000-4000-8000-000000000002','DASH-VTR-B','Marca B','Modelo B',2024,'ruim','baixado','Garagem B');

insert into public.equipment (unit_id,item,model_brand,quantity,conservation_state)
values
  ('12000000-0000-4000-8000-000000000001','Mangueira Dashboard','Teste',5,'bom'),
  ('12000000-0000-4000-8000-000000000002','EPR Dashboard','Teste',3,'inservivel');

set local role authenticated;
select set_config('request.jwt.claim.sub','22000000-0000-4000-8000-000000000001',true);
select set_config('request.jwt.claims','{"sub":"22000000-0000-4000-8000-000000000001","role":"authenticated"}',true);

select is(((public.dashboard_summary(null)->'military'->>'total')::integer),2,'Dashboard global conta dois militares');
select is(((public.dashboard_summary('12000000-0000-4000-8000-000000000001')->'military'->>'total')::integer),1,'Dashboard filtrado conta um militar da Unidade A');
select is(((public.dashboard_summary(null)->'vehicles'->>'total')::integer),2,'Dashboard global conta duas viaturas');
select is(((public.dashboard_summary(null)->'vehicles'->>'poor')::integer),1,'Dashboard detecta uma viatura ruim');
select is(((public.dashboard_summary(null)->'equipment'->>'totalQuantity')::integer),8,'Dashboard soma quantidade de equipamentos');
select is(((public.dashboard_summary(null)->'equipment'->>'unserviceableQuantity')::integer),3,'Dashboard soma equipamentos inservíveis');
select is(((public.dashboard_summary(null)->'military'->>'expiredDriverLicenses')::integer),1,'Dashboard identifica uma CNH vencida');
select is(((public.dashboard_summary(null)->'military'->>'driverLicensesExpiring30Days')::integer),1,'Dashboard identifica uma CNH vencendo em 30 dias');

select ok(
  exists (
    select 1 from public.search_military('Silva', null, 20) s
    where s.id='42000000-0000-4000-8000-000000000001'
  ),
  'Busca por nome de guerra inclui o militar correto'
);

select ok(
  exists (
    select 1 from public.search_military('João da Silva', null, 20) s
    where s.id='42000000-0000-4000-8000-000000000001'
  ),
  'Busca por nome completo inclui o militar correto'
);

select is(
  (select count(*)::integer
   from public.search_military('529.982.247-25', null, 20)
   where id='42000000-0000-4000-8000-000000000001'),
  1,
  'Busca encontra militar correto por CPF com máscara'
);

select is(
  (select count(*)::integer
   from public.search_military('Dashboard','12000000-0000-4000-8000-000000000001',20)),
  1,
  'Busca respeita filtro de unidade'
);

reset role;

select * from finish();
rollback;

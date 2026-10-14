begin;

create extension if not exists pgtap with schema extensions;

select plan(18);

select has_table('public', 'profiles', 'profiles existe');
select has_table('public', 'military_personnel', 'military_personnel existe');
select has_table('public', 'vehicles', 'vehicles existe');
select has_table('public', 'equipment', 'equipment existe');
select has_table('public', 'audit_logs', 'audit_logs existe');

select has_view('public', 'v_military_directory', 'v_military_directory existe');
select has_view('public', 'v_current_leaves', 'v_current_leaves existe');
select has_view('public', 'v_military_functions', 'v_military_functions existe');

select has_function('public', 'bootstrap_first_master', array['uuid'], 'bootstrap_first_master existe');
select has_function(
  'public',
  'admin_configure_user',
  array['uuid','text','app_role','uuid','boolean'],
  'admin_configure_user existe'
);
select has_function(
  'public',
  'set_military_functions',
  array['uuid','uuid[]','platoon_code'],
  'set_military_functions existe'
);
select has_function(
  'public',
  'search_military',
  array['text','uuid','integer'],
  'search_military existe'
);
select has_function('public', 'dashboard_summary', array['uuid'], 'dashboard_summary existe');

select has_index('public', 'military_personnel', 'military_cpf_unique', 'CPF possui índice unique');
select has_index('public', 'military_personnel', 'military_full_name_trgm_idx', 'Nome possui índice trigram');
select has_index('public', 'military_personnel', 'military_war_name_trgm_idx', 'Nome de guerra possui índice trigram');

select col_is_pk('public', 'profiles', 'id', 'profiles.id é PK');
select col_is_fk('public', 'profiles', 'unit_id', 'profiles.unit_id é FK');

select * from finish();
rollback;

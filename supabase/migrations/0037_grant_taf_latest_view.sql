begin;

-- 0037_grant_taf_latest_view.sql
-- Ajusta permissões da view v_military_taf_latest para uso em buscas e dashboard.

-- Garante que apenas usuários autenticados possam consultar a view
-- utilizada pelo search_military e pelo taf_latest_overview.
revoke all on public.v_military_taf_latest from public;
grant select on public.v_military_taf_latest to authenticated;

commit;

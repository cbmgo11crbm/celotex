begin;

-- 0063_editor_write_any_unit.sql
-- Libera editores ativos para escrever em registros de qualquer unidade
-- (militares, relações, viaturas, equipamentos, storage), e não apenas
-- na própria unidade.

create or replace function private.can_write_unit(target_unit_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    coalesce((select private.is_master()), false)
    or (select private.current_user_role()) = 'editor'::public.app_role;
$$;

revoke all on function private.can_write_unit(uuid) from public;
grant execute on function private.can_write_unit(uuid) to authenticated;

commit;

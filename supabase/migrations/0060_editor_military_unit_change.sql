begin;

-- 0060_editor_military_unit_change.sql
-- Permite que editores alterem a unidade de militares para qualquer unidade.
-- A cláusula USING continua exigindo que o registro pertença à unidade do
-- editor; apenas o WITH CHECK passa a aceitar qualquer unidade de destino.

drop policy if exists "military_master_editor_update" on public.military_personnel;

create policy "military_master_editor_update"
on public.military_personnel for update
to authenticated
using (
  (select private.can_write_unit(unit_id))
)
with check (
  (select private.is_master())
  or (select private.current_user_role()) = 'editor'::public.app_role
);

commit;

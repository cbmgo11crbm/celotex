begin;

-- Concede privilégios explícitos para catálogos opcionais de viaturas e equipamentos.
-- Necessário além das policies de RLS para que o papel "authenticated" possa
-- efetivamente ler/escrever quando private.is_master() = true.

grant select, insert, update, delete
  on public.vehicle_functions
  to authenticated;

grant select, insert, update, delete
  on public.vehicle_vehicle_functions
  to authenticated;

grant select, insert, update, delete
  on public.equipment_categories
  to authenticated;

commit;

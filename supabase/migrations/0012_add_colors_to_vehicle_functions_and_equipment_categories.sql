begin;

-- Adiciona colunas de cor para funções de viaturas e categorias de equipamentos.
-- O formato será texto livre, recomendado como HEX (#RRGGBB).

alter table public.vehicle_functions
  add column if not exists color_hex text;

alter table public.equipment_categories
  add column if not exists color_hex text;

commit;

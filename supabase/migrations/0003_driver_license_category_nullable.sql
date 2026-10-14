-- Permite militares sem categoria de CNH cadastrada.
-- A constraint/enum existente continua validando os valores quando informados.

alter table public.military_personnel
  alter column driver_license_category drop not null;
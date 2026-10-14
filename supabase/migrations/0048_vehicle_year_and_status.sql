begin;

-- Adiciona novos valores ao enum de status de viatura.
alter type public.vehicle_status add value if not exists 'cautelado_outra_obm';
alter type public.vehicle_status add value if not exists 'em_baixa_patrimonial';

-- Adiciona colunas de ano de fabricação e ano modelo.
alter table public.vehicles add column if not exists manufacture_year smallint;
alter table public.vehicles add column if not exists model_year smallint;

-- Preenche ano de fabricação com o ano existente.
update public.vehicles set manufacture_year = coalesce(manufacture_year, year) where year is not null;

commit;

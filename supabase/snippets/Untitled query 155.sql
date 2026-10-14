begin;

alter table public.military_personnel
  add column address_street text,
  add column address_number text,
  add column address_block text,
  add column address_lot text,
  add column address_complement text,
  add column address_district text,
  add column address_city text,
  add column address_state text,
  add column address_zipcode text;

comment on column public.military_personnel.address_street is 'Rua (logradouro) do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_number is 'Número do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_block is 'Quadra (Qd) do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_lot is 'Lote (Lt) do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_complement is 'Complemento do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_district is 'Bairro do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_city is 'Cidade do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_state is 'Estado (UF) do endereço residencial do militar. Opcional.';
comment on column public.military_personnel.address_zipcode is 'CEP do endereço residencial do militar. Opcional. Máscara pertence à camada de UI.';

commit;
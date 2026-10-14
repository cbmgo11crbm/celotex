begin;

create table public.vehicle_functions (
  id uuid primary key default gen_random_uuid(),
  name citext not null,
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint vehicle_functions_name_not_blank check (btrim(name::text) <> '')
);

create unique index vehicle_functions_name_unique on public.vehicle_functions (lower(name::text));

create table public.vehicle_vehicle_functions (
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  function_id uuid not null references public.vehicle_functions(id) on delete restrict,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  primary key (vehicle_id, function_id)
);

alter table public.vehicle_functions enable row level security;
alter table public.vehicle_vehicle_functions enable row level security;

create policy "vehicle_functions_master_write"
  on public.vehicle_functions for all
  to authenticated
  using ((select private.is_master()))
  with check ((select private.is_master()));

create policy "vehicle_vehicle_functions_write"
  on public.vehicle_vehicle_functions for all
  to authenticated
  using (
    (select private.can_write_unit(
       (select v.unit_id from public.vehicles v where v.id = vehicle_id)
    ))
  )
  with check (
    (select private.can_write_unit(
       (select v.unit_id from public.vehicles v where v.id = vehicle_id)
    ))
  );

insert into public.vehicle_functions (name, is_active) values
  ('Resgate', true),
  ('Salvamento', true),
  ('Náutica', true),
  ('Incêndio Urbano', true),
  ('Incêndio Florestal', true),
  ('Administrativo', true),
  ('Transporte de Cargas', true),
  ('Transporte de Pessoas', true),
  ('Vistorias', true);

commit;

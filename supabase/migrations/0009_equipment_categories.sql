begin;

create table public.equipment_categories (
  id uuid primary key default gen_random_uuid(),
  name citext not null,
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint equipment_categories_name_not_blank check (btrim(name::text) <> '')
);

create unique index equipment_categories_name_unique
  on public.equipment_categories (lower(name::text));

alter table public.equipment
  add column category_id uuid references public.equipment_categories(id);

alter table public.equipment
  add constraint equipment_category_required check (category_id is not null);

alter table public.equipment_categories enable row level security;

create policy "equipment_categories_master_write"
  on public.equipment_categories for all
  to authenticated
  using ((select private.is_master()))
  with check ((select private.is_master()));

insert into public.equipment_categories (name, is_active) values
  ('Resgate', true),
  ('Aquático', true),
  ('Terrestre', true),
  ('Altura', true),
  ('Incêndio Florestal', true),
  ('Incêndio Urbano', true),
  ('Comunicação', true),
  ('Transporte', true);

commit;

begin;

-- Tabela de relacionamento many-to-many para múltiplas categorias de equipamento.
create table if not exists public.equipment_category_relations (
  id uuid primary key default gen_random_uuid(),
  equipment_id uuid not null references public.equipment(id) on delete cascade,
  category_id uuid not null references public.equipment_categories(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint equipment_category_relation_unique unique (equipment_id, category_id)
);

alter table public.equipment_category_relations enable row level security;

create policy "equipment_category_relations_master_write"
  on public.equipment_category_relations for all
  to authenticated
  using ((select private.is_master()))
  with check ((select private.is_master()));

create policy "equipment_category_relations_select_all"
  on public.equipment_category_relations for select
  to authenticated
  using (true);

-- View auxiliar para listar categorias por equipamento.
create or replace view public.v_equipment_categories as
select
  ecr.equipment_id,
  ecr.category_id,
  ec.name as category_name
from public.equipment_category_relations ecr
join public.equipment_categories ec on ec.id = ecr.category_id;

commit;

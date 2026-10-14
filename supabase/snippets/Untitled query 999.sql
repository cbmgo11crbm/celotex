begin;

-- 0032_vehicle_state_status_triggers.sql
-- Garante que as colunas de FK ( *_id ) de estado/situação sejam sempre
-- preenchidas a partir dos enums existentes, evitando falhas em inserts/updates
-- do frontend enquanto ele ainda usa conservation_state e status.

create or replace function public.set_vehicle_state_status_ids()
returns trigger
language plpgsql
as $$
begin
  if new.conservation_state is not null then
    select id into new.conservation_state_id
    from public.vehicle_conservation_states
    where code = new.conservation_state::text
    limit 1;
  end if;

  if new.status is not null then
    select id into new.status_id
    from public.vehicle_statuses
    where code = new.status::text
    limit 1;
  end if;

  return new;
end;
$$;

create or replace function public.set_equipment_state_ids()
returns trigger
language plpgsql
as $$
begin
  if new.conservation_state is not null then
    select id into new.conservation_state_id
    from public.vehicle_conservation_states
    where code = new.conservation_state::text
    limit 1;
  end if;

  return new;
end;
$$;

-- Aplica os gatilhos às tabelas existentes

create trigger trg_vehicles_set_state_status_ids
before insert or update on public.vehicles
for each row
execute function public.set_vehicle_state_status_ids();

create trigger trg_equipment_set_state_ids
before insert or update on public.equipment
for each row
execute function public.set_equipment_state_ids();

commit;

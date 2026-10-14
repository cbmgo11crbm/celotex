begin;

-- 0034_military_boards_fk_personnel.sql
-- Adiciona coluna de FK para quadros em military_personnel e cria trigger
-- para manter board_id sincronizado com o enum existente public.military_board.

-- Nova coluna de FK em military_personnel, mantendo a coluna enum "quadro" existente
alter table public.military_personnel
  add column board_id uuid references public.military_boards(id);

-- Backfill a partir do enum existente
update public.military_personnel mp
set board_id = b.id
from public.military_boards b
where b.code = mp.quadro::text;

-- Função e trigger para manter board_id em sincronia com quadro (enum)
create or replace function public.set_military_board_id()
returns trigger
language plpgsql
as $$
begin
  if new.quadro is not null then
    select id into new.board_id
    from public.military_boards
    where code = new.quadro::text
    limit 1;
  end if;

  return new;
end;
$$;

create trigger trg_military_personnel_set_board_id
before insert or update on public.military_personnel
for each row
execute function public.set_military_board_id();

commit;

begin;

-- Inicializa a coluna intra_rank_order para todos os militares já existentes,
-- atribuindo uma ordem sequencial dentro de cada posto/graduação.
-- Isso é necessário porque a coluna foi criada com default 0, então, sem este
-- ajuste, todas as linhas ficam com o mesmo valor e trocar valores não tem
-- efeito prático na ordenação.

with ranked as (
  select
    mp.id,
    mp.rank_id,
    row_number() over (
      partition by mp.rank_id
      order by d.rank_order, d.war_name, d.full_name, mp.id
    ) as new_intra_rank_order
  from public.military_personnel mp
  join public.v_military_directory d
    on d.id = mp.id
  where d.is_inactive = false
)
update public.military_personnel mp
set intra_rank_order = r.new_intra_rank_order
from ranked r
where mp.id = r.id;

commit;
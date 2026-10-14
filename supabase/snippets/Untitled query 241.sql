-- Ordem real que a função está retornando (o que o frontend usa)
select
  row_number() over () as posicao,
  id,
  full_name,
  war_name,
  rank_code,
  rank_order,
  intra_rank_order
from public.search_military(null, null, 10000, false);
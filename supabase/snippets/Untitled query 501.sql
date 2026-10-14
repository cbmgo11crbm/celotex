select
  id,
  full_name,
  war_name,
  rank_code,
  rank_order,
  intra_rank_order
from public.search_military(null, null, 10000, false)
order by
  rank_order,
  intra_rank_order,
  war_name,
  full_name;
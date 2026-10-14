BEGIN;

-- Recalcula intra_rank_order para todos os militares ativos,
-- mantendo a ordem relativa atual e preenchendo NULLs.
WITH ranked AS (
  SELECT
    mp.id,
    mp.rank_id,
    row_number() OVER (
      PARTITION BY mp.rank_id
      ORDER BY d.rank_order, COALESCE(mp.intra_rank_order, 999999), d.war_name, d.full_name, mp.id
    ) AS new_intra_rank_order
  FROM public.military_personnel mp
  JOIN public.v_military_directory d ON d.id = mp.id
  WHERE d.is_inactive = false
)
UPDATE public.military_personnel mp
SET intra_rank_order = r.new_intra_rank_order
FROM ranked r
WHERE mp.id = r.id;

COMMIT;

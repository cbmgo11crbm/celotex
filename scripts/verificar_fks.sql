-- Verificar quais rank_id e unit_id do CSV não existem no banco
-- Substitua os valores pelos presentes no CSV (exemplo com os UUIDs encontrados)

WITH rank_ids AS (
  SELECT unnest(ARRAY[
    'ee14ced8-f383-4584-bf15-32d3a4a99af5',
    '0a909f3e-2d85-4599-8d60-9ec10f6ca416',
    '31607be0-58a4-463b-aaed-9b191bede08b',
    'c71382c2-9f67-4b21-8f5f-adbe5201a960',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a3',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a4',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a5',
    '4ffffa07-a1d6-47f7-8743-aad276cd83a6',
    '334d0773-22e5-4bd9-bec8-2e0fd36bb95f',
    '609bbc24-7f0a-41c0-98d3-c75c028b978e',
    '8dfb3b10-19e0-44da-95f3-e4f58dbdf25a',
    'b851e263-f878-41b8-89b0-0c41bc5e86ce',
    'c88b285f-ec1d-43c7-8473-23910b8839e2',
    'ab40a8db-24af-475e-ac2f-db020638332d',
    '3649efe3-88ef-468a-ab98-1a6c20b1a17a'
  ]::uuid[]) AS rank_id
),
unit_ids AS (
  SELECT unnest(ARRAY[
    'ccb57a03-138b-4fad-b81a-e1cecee690f1',
    '51dc74eb-9a4f-496a-8173-f9654362a2b9',
    'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc'
  ]::uuid[]) AS unit_id
)
SELECT 'rank' AS tipo, r.rank_id::text AS id, NULL AS code, NULL AS name
FROM rank_ids r
LEFT JOIN public.ranks rk ON rk.id = r.rank_id
WHERE rk.id IS NULL
UNION ALL
SELECT 'unit' AS tipo, u.unit_id::text AS id, NULL AS code, NULL AS name
FROM unit_ids u
LEFT JOIN public.units un ON un.id = u.unit_id
WHERE un.id IS NULL;

-- Liste todos os ranks e unidades existentes para mapear manualmente
SELECT 'rank' AS tipo, id::text, code, name
FROM public.ranks
ORDER BY sort_order;

SELECT 'unit' AS tipo, id::text, acronym AS code, name
FROM public.units
ORDER BY acronym;

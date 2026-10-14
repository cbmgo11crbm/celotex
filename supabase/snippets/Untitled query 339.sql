BEGIN;

-- 1. Confirme a quantidade
SELECT COUNT(*) FROM public.military_personnel;

-- 2. (Opcional) Ver quem será removido
-- SELECT id, war_name, full_name FROM public.military_personnel;

-- 3. Remover todos os militares
DELETE FROM public.military_personnel;

-- 4. Se a contagem estiver correta e tudo certo, finalize
COMMIT;

-- 5. Se algo deu errado, desfaça com:
-- ROLLBACK;
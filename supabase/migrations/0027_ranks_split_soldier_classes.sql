begin;

-- 0027_ranks_split_soldier_classes.sql
-- Cria SD 2 / SD 1 e migra todos os soldados atuais para SD 2.

-- 1) Atualizar o posto existente "Sd" para "Sd 2" (mantendo o mesmo id)
--    Isso garante que todos os militares que hoje são "Sd" passem a ser "Sd 2".
update public.ranks
set
  code = 'Sd 2',
  name = 'Soldado 2ª Classe',
  sort_order = 14
where lower(code::text) = lower('Sd');

-- 2) Criar o novo posto "Sd 1" mais antigo que "Sd 2"
insert into public.ranks (code, name, sort_order, is_active)
values ('Sd 1', 'Soldado 1ª Classe', 13, true)
on conflict do nothing;

commit;

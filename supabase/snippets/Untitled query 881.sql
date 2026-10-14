begin;

-- Permitir que usuários autenticados (incluindo Master) possam executar
-- INSERT/UPDATE/DELETE em public.ranks, com controle de RLS restringindo
-- escrita apenas a perfis Master.

grant insert, update, delete on public.ranks to authenticated;

create policy "ranks_master_write"
  on public.ranks
  for all
  to authenticated
  using ((select private.is_master()))
  with check ((select private.is_master()));

commit;

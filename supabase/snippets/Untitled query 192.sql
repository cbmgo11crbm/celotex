begin;

-- Administração adicional de catálogos: funções de militares, seções, cursos, tipos de afastamento
-- Nesta fase não criamos novas tabelas, apenas reforçamos que o Master já
-- possui políticas de escrita sobre estes catálogos, conforme 0001_initial_schema.
--
-- Tabelas envolvidas:
--   public.courses          (já possui policy courses_master_write)
--   public.sections         (já possui policy sections_master_write)
--   public.functions        (já possui policy functions_master_write)
--   public.leave_types      (somente leitura na versão atual)
--
-- Como leave_types foi definido como "catálogo de sistema" nesta versão, não
-- abrimos CRUD ainda. Se no futuro quiser permitir que Master altere
-- leave_types, criar uma nova migration específica com policies semelhantes a
-- courses_master_write/sections_master_write.

comment on schema public is
  '[0010] Catálogos administráveis confirmados para Master: cursos, seções, funções. Tipos de afastamento seguem somente leitura.';

commit;
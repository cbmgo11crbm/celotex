-- ============================================================================
-- Sistema de Gestão do Comando Regional
-- Seed de catálogos e dados de demonstração SEM usuários de Auth.
-- Arquivo: supabase/seed.sql
-- ============================================================================
-- Observação:
-- Usuários de autenticação devem ser criados via Supabase Auth/Admin API.
-- Não é recomendado depender de INSERT manual em auth.users para produção.
-- ============================================================================

-- Postos e graduações
insert into public.ranks (code, name, sort_order, is_active) values
  ('Cel',     'Coronel',               1, true),
  ('TC',      'Tenente-Coronel',       2, true),
  ('Maj',     'Major',                 3, true),
  ('Cap',     'Capitão',               4, true),
  ('1º Ten',  'Primeiro-Tenente',      5, true),
  ('2º Ten',  'Segundo-Tenente',       6, true),
  ('Asp Of',  'Aspirante a Oficial',   7, true),
  ('ST',      'Subtenente',             8, true),
  ('1º Sgt',  'Primeiro-Sargento',     9, true),
  ('2º Sgt',  'Segundo-Sargento',     10, true),
  ('3º Sgt',  'Terceiro-Sargento',    11, true),
  ('Cb',      'Cabo',                  12, true),
  ('Sd',      'Soldado',               13, true)
on conflict do nothing;

-- Seções
insert into public.sections (acronym, name, is_active) values
  ('DEOP', 'DEOP', true),
  ('SCEV', 'SCEV', true),
  ('SAD', 'SAD', true),
  ('SEC', 'SEC', true),
  ('DC', 'DC', true),
  ('SAT', 'SAT', true),
  ('SOP', 'SOP', true),
  ('SIQ', 'SIQ', true),
  ('SGP', 'SGP', true),
  ('SECH', 'SECH', true),
  ('DBM', 'DBM', true),
  ('SIQ-Bombeiro Mirim', 'SIQ - Bombeiro Mirim', true),
  ('SGP-SMT', 'SGP - SMT', true),
  ('SGP-Almoxarifado', 'SGP - Almoxarifado', true)
on conflict do nothing;

-- Funções
insert into public.functions (name, description, is_operational, is_active) values
  ('Comandante', null, false, true),
  ('Subcomandante', null, false, true),
  ('Chefe', null, false, true),
  ('Auxiliar', null, false, true),
  ('Analista de Projetos', null, false, true),
  ('Vistoriador', null, false, true),
  ('Assessor', null, false, true),
  ('Auxiliar de Seção', null, false, true),
  ('Auxiliar de Protocolo', null, false, true),
  ('Auxiliar de Gabinete', null, false, true),
  ('Gestor(a) de Fundo Rotativo', null, false, true),
  ('Auxiliar de Fundo Rotativo', null, false, true),

  ('Componente de Guarnição', null, true, true),
  ('Chefe de Ala', null, true, true),
  ('Telefonista/Recepcionista', null, true, true),
  ('Videofonista', null, true, true),
  ('Despachante', null, true, true),

  ('BM/5 Local', null, false, true)
on conflict do nothing;

-- Tipos de afastamento
insert into public.leave_types (name, requires_detail, sort_order, is_active) values
  ('Férias', false, 10, true),
  ('Licença Especial', false, 20, true),
  ('Licença para Tratar de Interesse Particular', false, 30, true),
  ('Licença para Tratamento de Saúde de Pessoas da Família', false, 40, true),
  ('Licença para Tratamento de Saúde Própria', false, 50, true),
  ('Licença Maternidade', false, 60, true),
  ('Licença para Adoção', false, 70, true),
  ('Dispensa Núpcias', false, 80, true),
  ('Dispensa Luto', false, 90, true),
  ('Dispensa Recompensa', false, 100, true),
  ('Dispensa para Trânsito', false, 110, true),
  ('Dispensa para Instalação', false, 120, true),
  ('Dispensa Desconto em Férias', false, 130, true),
  ('Curso', true, 140, true)
on conflict do nothing;

-- Catálogo de cursos:
-- Começar vazio é aceitável; o Master cadastrará os cursos reais.
-- Alguns exemplos genéricos para desenvolvimento:
insert into public.courses (name, description, is_active) values
  ('Atendimento Pré-Hospitalar', 'Curso de demonstração para ambiente local.', true),
  ('Combate a Incêndio', 'Curso de demonstração para ambiente local.', true),
  ('Salvamento Terrestre', 'Curso de demonstração para ambiente local.', true)
on conflict do nothing;

-- Unidades fictícias de desenvolvimento
insert into public.units (acronym, name, municipality, is_active)
values
  ('CRBM-DEMO', 'Comando Regional de Demonstração', 'Goiânia', true),
  ('UBM-A', 'Unidade Bombeiro Militar A', 'Goiânia', true),
  ('UBM-B', 'Unidade Bombeiro Militar B', 'Goiânia', true)
on conflict do nothing;

-- Demais dados demonstrativos (militares/viaturas/equipamentos) devem ser
-- inseridos por um seed complementar após a criação dos usuários de Auth,
-- ou por script usando service_role exclusivamente em ambiente local.

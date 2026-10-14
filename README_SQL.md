# Modelo SQL — Sistema de Gestão do Comando Regional

Esta pasta contém a primeira versão do modelo PostgreSQL/Supabase.

## Arquivos

- `supabase/migrations/0001_initial_schema.sql`
  - tipos;
  - tabelas;
  - índices;
  - constraints;
  - helpers de autorização;
  - triggers;
  - auditoria;
  - views;
  - Row Level Security;
  - buckets e policies de Storage.

- `supabase/seed.sql`
  - postos/graduações;
  - seções;
  - funções;
  - tipos de afastamento;
  - cursos de demonstração;
  - unidades fictícias.

## Regras centrais

### Perfis

- `master`: leitura/escrita global.
- `editor`: leitura global, escrita somente na própria unidade.
- `viewer`: leitura global, nenhuma escrita.

### Segurança

As permissões são aplicadas no PostgreSQL com RLS. A UI deve esconder ações
não permitidas, mas isso é apenas UX; a segurança real está no banco.

### Usuários

A criação de `auth.users` NÃO deve ser feita pelo frontend com service_role.

Fluxo recomendado:

1. Master solicita criação pela UI.
2. Uma função server-side/Edge Function/Vercel Function usa Supabase Admin API.
3. O trigger cria `public.profiles` como `viewer` e `is_active=false`.
4. A rotina server-side ou operação subsequente do Master define role, unidade e ativa o perfil.

A `service_role` nunca pode chegar ao navegador.

### Fotos

Paths obrigatórios:

```text
military-photos/{unit_id}/{military_id}/profile.webp
vehicle-photos/{unit_id}/{vehicle_id}/vehicle.webp
```

O primeiro segmento é usado pela RLS do Storage para validar a unidade.

### CPF e telefone

Persistir normalizados:

- CPF: apenas 11 dígitos.
- telefone: apenas 10 ou 11 dígitos.

Máscaras são responsabilidade do frontend.

### Classificação operacional

O campo `classification` existe para consultas eficientes, mas não deve ser
editado diretamente pelo cliente. Ele é sincronizado a partir das funções
associadas.

Se qualquer função tiver `is_operational=true`, o militar é operacional e
precisa ter Ala A/B/C/D. A classificação enviada pelo frontend não é confiada:
o banco a recalcula a partir das funções associadas.

### Afastamento

O status Ativo/Afastado não é persistido; é calculado pela view
`v_military_status`.

## Execução local

Depois de inicializar o Supabase CLI no projeto:

```bash
npx supabase start
npx supabase db reset
```

O `db reset` reaplica migrations e depois o `seed.sql`.

## Próximas migrations recomendadas

- `0002_admin_user_api.sql`: apenas se houver RPCs adicionais seguras.
- `0003_dashboard_functions.sql`: funções/RPCs agregadas para dashboard, se necessário.
- `0004_search.sql`: trigram/full-text search se o volume justificar.
- `0005_business_rules.sql`: novas regras após validação com usuários reais.

## Observação importante

Este modelo deliberadamente não coloca `role` em `raw_user_meta_data`. Dados
de autorização devem vir de fonte que o usuário final não possa manipular.

Antes de usar em produção, executar testes RLS com os três perfis e confirmar
Storage policies com uploads, updates e deletes de unidades diferentes.

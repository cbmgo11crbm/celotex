# Etapa 2 — Migration, RPCs e Testes

Copie o conteúdo desta pasta para a raiz do projeto:

```text
/home/gleusmar/Documentos/dev/11crbm
```

A estrutura final deverá ficar aproximadamente:

```text
11crbm/
└── supabase/
    ├── migrations/
    │   ├── 0001_initial_schema.sql
    │   └── 0002_security_rpcs_search_dashboard.sql
    ├── seed.sql
    └── tests/
        └── database/
            ├── 001_schema.test.sql
            ├── 010_bootstrap_users.test.sql
            ├── 020_rls_roles.test.sql
            ├── 030_business_rules.test.sql
            └── 040_dashboard_search.test.sql
```

## O que a 0002 corrige

### 1. Perfis pendentes

A `0001` criava novos `auth.users` como:

- viewer;
- inativo;
- sem unidade.

Mas a constraint original exigia unidade para Viewer. A `0002` corrige a regra:

- Master pode ficar sem unidade;
- usuário inativo pode aguardar provisionamento sem unidade;
- Editor/Viewer ativos precisam possuir unidade.

### 2. Operacional + Ala

A constraint original impedia uma transição limpa de Administrativo para
Operacional, porque a Ala e a função operacional dependiam uma da outra.

Agora a consistência final é verificada por constraint trigger
`DEFERRABLE INITIALLY DEFERRED`.

A aplicação deve preferencialmente chamar:

```sql
select public.set_military_functions(
  '<military-id>',
  array['<function-id-1>', '<function-id-2>']::uuid[],
  'A'::public.platoon_code
);
```

Essa RPC salva funções e Ala de forma atômica.

## Bootstrap do primeiro Master

A criação do primeiro usuário de Auth deve ocorrer via Supabase Auth/Admin API.

Depois, em ambiente server-side usando `service_role`, execute:

```sql
select public.bootstrap_first_master('<uuid-do-auth-user>');
```

A função recusa o bootstrap se já existir Master ativo.

**Nunca coloque a service role key no frontend.**

## Cadastro de usuários

Fluxo recomendado:

1. Master preenche modal "Novo usuário".
2. Vercel Function / Supabase Edge Function cria o `auth.users` via Admin API.
3. Trigger cria `public.profiles` como viewer/inativo.
4. A função server-side retorna o novo UUID.
5. O Master chama/servidor chama:

```sql
select public.admin_configure_user(
  '<user-id>',
  'Nome Completo',
  'editor',
  '<unit-id>',
  true
);
```

## Busca

RPC:

```sql
select * from public.search_military('Romeiro', null, 20);
```

Busca por:

- nome;
- nome de guerra;
- RG;
- CPF com ou sem máscara.

Pode filtrar por unidade.

## Dashboard

RPC:

```sql
select public.dashboard_summary(null);
```

Ou:

```sql
select public.dashboard_summary('<unit-id>');
```

Retorna JSON com:

- efetivo total;
- ativos;
- afastados;
- operacionais;
- administrativos;
- CNHs vencidas;
- CNHs vencendo em 30 dias;
- situação das viaturas;
- quantidades de equipamentos.

## Executar tudo localmente

Na raiz do projeto:

```bash
npx supabase start
npx supabase db reset
npx supabase test db
```

O `db reset` reaplica as migrations e depois executa o `seed.sql`.

O Supabase CLI executa os testes SQL/pgTAP existentes em `supabase/tests`.

## Testes incluídos

### 001_schema.test.sql

Confere estrutura crítica, funções, views e índices.

### 010_bootstrap_users.test.sql

Confere:

- novo usuário nasce inativo;
- novo usuário nasce Viewer;
- pode aguardar unidade enquanto inativo;
- primeiro Master pode ser bootstrapado;
- segundo bootstrap é bloqueado;
- Master configura Editor.

### 020_rls_roles.test.sql

Confere:

- Master lê e altera qualquer unidade;
- Editor A lê tudo;
- Editor A escreve somente Unidade A;
- Editor B escreve somente Unidade B;
- Viewer lê tudo e não escreve;
- usuário inativo não lê dados;
- proteção também vale para viaturas/equipamentos/catálogos.

### 030_business_rules.test.sql

Confere:

- validação matemática de CPF;
- função administrativa => Administrativo;
- função operacional => Operacional;
- Ala obrigatória;
- retorno a Administrativo limpa Ala;
- Curso exige detalhe;
- afastamento vigente => Afastado;
- período inválido é rejeitado.

### 040_dashboard_search.test.sql

Confere:

- agregações globais;
- filtro por unidade;
- viaturas;
- equipamentos;
- alertas de CNH;
- busca por nome;
- busca por nome de guerra;
- busca por CPF mascarado.

## Se algum teste falhar

Execute individualmente:

```bash
npx supabase test db supabase/tests/database/020_rls_roles.test.sql
```

e use:

```bash
npx supabase db lint
```

para checar problemas de banco.

Não avance para o frontend enquanto houver falhas de RLS ou regras de negócio.

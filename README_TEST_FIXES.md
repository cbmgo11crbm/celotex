# Correção dos testes da Etapa 2

Substitua:

- `supabase/tests/database/020_rls_roles.test.sql`
- `supabase/tests/database/040_dashboard_search.test.sql`

Depois execute:

```bash
cd /home/gleusmar/Documentos/dev/11crbm
npx supabase test db
```

Não é necessário `db reset`, pois apenas os testes mudaram.

## Motivo do 020

O teste usava um data-modifying CTE (`WITH ... UPDATE`) aninhado dentro de
`pgtap.is()`. PostgreSQL exige esse tipo de CTE no nível superior.

A versão corrigida executa o UPDATE com `lives_ok()` e depois verifica o valor
persistido. Isso também reflete corretamente o comportamento de RLS: um UPDATE
bloqueado pela policy `USING` pode simplesmente afetar zero linhas.

O plano foi corrigido de 18 para 17 assertions.

## Motivo do 040

`search_military()` é fuzzy por causa do `pg_trgm` e do operador `%`.
Logo, uma consulta pode retornar candidatos adicionais semelhantes.

O teste correto deve garantir que o militar esperado está entre os resultados,
não que ele seja necessariamente o único resultado.

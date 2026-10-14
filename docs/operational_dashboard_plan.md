# Plano enxuto para o novo Painel de Poder Operacional

## 2. Plano enxuto para o novo Painel de Poder Operacional

### 2.1. Arquitetura de dados

**Passo 1 – Mapear exatamente o payload de `dashboard_summary`**

Ler totalmente a função `0005_military_inactive_flag.sql` (já vimos o começo) para saber:

- Quais campos de `military`, `vehicles`, `equipment` já vêm prontos.
- Se já existe algo sobre:
  - Ala (A/B/C/D),
  - tipos de afastamento,
  - CNH por categoria,
  - estados da frota.

**Passo 2 – Identificar lacunas**

O que o painel precisa e hoje **não** vem no JSON:

- Distribuição por Ala (A/B/C/D) com disponíveis/afastados.
- Situação do efetivo por tipo de afastamento.
- CNH por categoria (A/B/AB/C/...).
- Efetivo por posto/graduação (respeitando `rank_order`).
- Quadro detalhado de afastamentos (tipo, início, retorno).
- Matriz unidade × disponibilidade (pessoal e frota).
- Viaturas por tipo (`vehicle_type` ou equivalente).

**Passo 3 – Propor novas RPCs/migrations**

Criar uma nova migration (por ex. `000X_operational_dashboard.sql`) com RPCs específicas, em vez de entupir `dashboard_summary`:

- `dashboard_personnel_operational_summary(p_unit_id uuid, p_now date)`
  - Retorna exatamente as métricas de militar descritas (efetivo, disponíveis, por Ala, por tipo de afastamento, CNH, por posto/graduação, por seção, próximos retornos, aniversariantes etc.), *dentro do que o schema atual permitir*.

- `dashboard_vehicle_operational_summary(p_unit_id uuid)`
  - Retorna métricas de frota (total, por status, por conservação, por tipo, por unidade).

Se não existir `vehicle_type` estruturado:

- Documentar a lacuna e propor:
  - tabela `vehicle_types`,
  - coluna `vehicle_type_id` em `vehicles`,
  - e uma migration específica para isso (sem alterar migrations antigas).

---

### 2.2. Arquitetura de frontend

**Passo 4 – Hooks de dashboard novos**

Em `src/features/dashboard/hooks.js`:

- `useOperationalDashboardPersonnel({ unitId })`
  - Chama RPC `dashboard_personnel_operational_summary`.

- `useOperationalDashboardVehicles({ unitId })`
  - Chama RPC `dashboard_vehicle_operational_summary`.

Cada hook retorna um objeto de métricas tipado e estável, por exemplo:

```ts
{
  totals: { total, available, operational, administrative, away, inCourse },
  availability: { rate, available, total },
  byAla: [ { ala: 'A', total, available, away, rate }, ... ],
  byRank: [ { rank_code, rank_name, order, total, available }, ... ],
  cnH: { byCategory: [...], expired, expiring30Days, driversAvailable },
  leavesByType: [...],
  upcomingReturns: [...],
  upcomingBirthdays: [...],
  // etc., conforme o que o banco conseguir entregar
}
```

**Passo 5 – Novo layout do dashboard**

Em `src/features/dashboard/DashboardPage.jsx`:

- Header “Poder Operacional”:
  - Título: `Poder Operacional`.
  - Subtítulo: `Visão consolidada de efetivo, disponibilidade operacional e capacidade da frota.`
  - Filtros globais:
    - `Unidade`: Todas | unidade específica (reaproveitar `useUnits`).
    - `Referência`: por ora apenas “Situação atual” (UI preparada para futuro histórico).
  - Botões:
    - `Atualizar` (refetch),
    - `Limpar filtros`.
  - Indicador: `Atualizado há Xs` (usando `dataUpdatedAt` do React Query).

- Abas principais:
  - `MILITARES` | `VIATURAS`
  - Provavelmente usar `useState('militares' | 'viaturas')` e classes Tailwind para abas.

---

### 2.3. Conteúdo da aba MILITARES

**Bloco 1 – KPIs principais**

Cards em grid (Nível 1):

- Efetivo total.
- Disponíveis (número + % do efetivo).
- Operacionais.
- Administrativos.
- Afastados (número + %).
- Em Curso.

Um card especial para **“Disponibilidade do Efetivo”** com:

- % grande (e.g. `84,4%`).
- Texto: `157 de 186 militares disponíveis`.
- Barra horizontal (progress bar).
- Ícone `ⓘ`/tooltip com definição.

**Bloco 2 – Composição do efetivo**

- Gráfico **Operacional × Administrativo**:
  - Donut ou barra 100%.
  - Mostra quantidade + %.

- Gráfico **Situação do Efetivo**:
  - Barra horizontal empilhada (disponíveis vs férias / licenças / curso / outros afastamentos).
  - Tooltips com contagem e %.

**Bloco 3 – Poder operacional por Ala**

- Cards para A, B, C, D:
  - `X / Y disponíveis` + `%`.
  - Barra preenchida.
  - Destaque discreto para a menor %.

- Gráfico “Disponibilidade por Ala”:
  - Barras comparando disponíveis vs afastados por Ala.

- Drill-down:
  - Clique em Ala → filtrar listagem de militares ou abrir modal com lista.

**Bloco 4 – Capacidade de condução / CNH**

Quadro/tabulação:

- Linhas por categoria de CNH.
- Colunas: Habilitados, Disponíveis, Afastados, Vencendo (30d), Vencidas.
- Ordenável por qualquer coluna.
- Alertas suaves (cores em Vencendo/Vencidas).

KPI **“Condutores disponíveis”**:

- `driversAvailable` + contagem de CNH vencidas / vencendo 30d.

**Bloco 5 – Efetivo por posto/graduação**

- Gráfico de barras horizontais:
  - Ordem pelo `rank_order` do banco, não alfabética.
  - Switch: “Total | Disponíveis”.

**Bloco 6 – Afastamentos**

- Gráfico “Afastamentos por Tipo”:
  - Barras horizontais (tipo vs quantidade / %).

- “Afastamentos em andamento”:
  - Tabela compacta com: Militar, Posto, Unidade, Tipo, Início, Retorno, Dias restantes.
  - Ordenado pelo retorno mais próximo.
  - Clique no militar → abre detalhes/ficha.

- “Próximos retornos ao efetivo”:
  - Lista com blocos por data (“Hoje”, “Próximos 7/15/30 dias”).

**Bloco 7 – Próximos aniversariantes**

- Grid/lista:
  - Avatar/foto (se existir), posto, nome de guerra, data, dias até.
  - Seções: Hoje, 7 dias, 30 dias.

**Bloco 8 – Distribuição por seção & matriz unidade × disponibilidade**

- “Distribuição do efetivo por seção”:
  - Barras horizontais com aviso em tooltip: “Um militar pode ser contabilizado em mais de uma seção.”

- Quando `Unidade = Todas`:
  - Tabela “Poder humano por unidade”:
    - Colunas: Unidade, Efetivo, Disponíveis, Operacionais, Administrativos, Afastados, % disponibilidade.
    - Ordenação por qualquer coluna.

**Bloco 9 – Atenção operacional (militares)**

- Lista de insights gerados por regras objetivas, por exemplo:
  - “5 CNHs vencem nos próximos 30 dias.”
  - “Ala C possui o menor percentual de disponibilidade: 71%.”
  - “8 militares retornam de afastamento nos próximos 7 dias.”

- Cada linha é clicável → leva para o quadro correspondente (CNH, Ala, afastamentos).

---

### 2.4. Conteúdo da aba VIATURAS

**Bloco 1 – KPIs**

- Frota total, Ativas, Baixadas, Cauteladas, “Disponibilidade da frota” (% com barra, tooltip com fórmula).

**Bloco 2 – Estado da frota**

- Gráfico de estados (Novo, Bom, Regular, Ruim, Inservível) com ênfase em Ruim/Inservível.

**Bloco 3 – Frota por tipo e disponibilidade por tipo**

- Gráfico/tabela para:
  - Total por tipo.
  - Ativas, Baixadas, Cauteladas, % disponibilidade.

- Se não houver `vehicle_type` estruturado:
  - Documentar e propor migration (`vehicle_types`, chave estrangeira etc.) antes de implementar este bloco.

**Bloco 4 – Frota por unidade**

- Tabela comparativa “Poder de frota por unidade” quando `Unidade = Todas`.

**Bloco 5 – Matriz tipo × unidade**

- Heatmap/tabela: linhas = unidade, colunas = tipo, célula = “ativas/total”.

**Bloco 6 – Viaturas que exigem atenção**

- Lista/tabela com:
  - VTR, Tipo, Unidade, Marca/Modelo, Status, Conservação, Local, Observações.
- Foco em: Baixadas, Ruim, Inservíveis.

**Bloco 7 – Condutores × frota**

- Métrica agregada (do resumo de pessoal + veículos):
  - “Condutores disponíveis com CNH válida” vs “Viaturas ativas”.
- Sem inferir compatibilidade jurídica CNH × tipo de viatura (isso fica para evolução futura quando existir regra formal).

**Bloco 8 – Atenção operacional (viaturas)**

- Regras simples:
  - “3 viaturas estão em estado Ruim.”
  - “2 viaturas estão Inservíveis.”
  - “Unidade X tem menor disponibilidade de frota: 68%.”

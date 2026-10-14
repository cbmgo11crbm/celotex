import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useOperationalDashboardPersonnel, useOperationalDashboardVehicles, useUnits } from './hooks.js';
import Input from '../../components/ui/Input.jsx';
import EChartBase from '../../components/charts/EChartBase.jsx';
import { useAuth } from '../../providers/AuthProvider.jsx';
import { supabase } from '../../lib/supabaseClient.js';

function formatNumber(value) {
  if (value == null) return '-';
  return new Intl.NumberFormat('pt-BR').format(Number(value));
}

function AvailabilityCard({ availability, isLoading }) {
  const percentage = availability?.percentage ?? 0;
  const available = availability?.available ?? 0;
  const total = availability?.total ?? 0;

  return (
    <div className="rounded-lg border bg-background p-4 md:col-span-3">
      <div className="mb-2 flex items-center justify-between">
        <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          Disponibilidade do efetivo
        </div>
        <span className="text-[10px] text-muted-foreground">available / total</span>
      </div>
      {isLoading ? (
        <div className="h-8 animate-pulse rounded-md bg-muted" />
      ) : (
        <div className="space-y-2 text-sm">
          <div className="flex items-baseline justify-between gap-2">
            <span className="text-2xl font-semibold">
              {percentage.toLocaleString('pt-BR', { maximumFractionDigits: 1 })}%
            </span>
            <span className="text-xs text-muted-foreground">
              {available} de {total} militares disponíveis
            </span>
          </div>
          <div className="h-2 w-full overflow-hidden rounded-full bg-muted">
            <div
              className="h-full rounded-full bg-emerald-500"
              style={{ width: `${Math.max(0, Math.min(100, percentage))}%` }}
            />
          </div>
        </div>
      )}
    </div>
  );
}

function HealthOverviewSection({ overview, isLoading }) {
  const total = overview?.total_military ?? 0;
  const withoutExam = overview?.without_exam ?? 0;
  const unfit = overview?.count_unfit ?? 0;
  const expired = overview?.count_expired ?? 0;
  const expiredList = Array.isArray(overview?.expired_list) ? overview.expired_list : [];

  const hasData = total > 0;

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Avaliação periódica de saúde
      </div>
      {isLoading ? (
        <div className="h-24 animate-pulse rounded-md bg-muted" />
      ) : !hasData ? (
        <p className="text-xs text-muted-foreground">Nenhum militar encontrado para o filtro atual.</p>
      ) : (
        <div className="space-y-3 text-xs">
          <div className="grid gap-2 sm:grid-cols-3">
            <div className="space-y-1 rounded-md bg-muted/40 p-2">
              <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                Sem avaliação registrada
              </div>
              <div className="text-lg font-semibold">{formatNumber(withoutExam)}</div>
              <div className="text-[10px] text-muted-foreground">
                De {formatNumber(total)} militares considerados.
              </div>
            </div>
            <div className="space-y-1 rounded-md bg-amber-50 p-2 dark:bg-neutral-500/30">
              <div className="text-[10px] font-medium uppercase tracking-wide text-amber-800 dark:text-orange-400">
                Periódico vencido
              </div>
              <div className="text-lg font-semibold text-amber-800 dark:text-orange-400">{formatNumber(expired)}</div>
            </div>
            <div className="space-y-1 rounded-md bg-red-50 p-2 dark:bg-neutral-500/30">
              <div className="text-[10px] font-medium uppercase tracking-wide text-red-800 dark:text-red-500">
                Inaptos
              </div>
              <div className="text-lg font-semibold text-red-800 dark:text-red-500">{formatNumber(unfit)}</div>
            </div>  
          </div>

          {expiredList.length > 0 && (
            <div className="space-y-1">
              <div className="text-[10px]  font-medium uppercase tracking-wide text-red-800 dark:text-muted-foreground">
                Militares com periódico vencido
              </div>
              <ul className="max-h-32 space-y-1 overflow-auto rounded-md bg-red-50 p-2 text-[11px] text-red-900 dark:bg-red-500/30 dark:text-neutral-50">
                {expiredList.map((item) => (
                  <li key={item.military_id ?? `${item.rank_code}-${item.war_name}-${item.validity_date}`}>
                    <span className="font-medium">
                      {item.rank_code ? `${String(item.rank_code).toUpperCase()} ` : ''}
                      {item.war_name}
                    </span>{' '}
                    <span className="text-[10px]">
                      • {item.unit_acronym} • validade {item.validity_date}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function ServiceTimeSection({ overview, isLoading }) {
  const avgYears = overview?.avg_years ?? null;

  const buckets = [
    { key: '0_5', label: '0-5 anos', value: overview?.bucket_0_5 ?? 0 },
    { key: '6_10', label: '6-10 anos', value: overview?.bucket_6_10 ?? 0 },
    { key: '11_15', label: '11-15 anos', value: overview?.bucket_11_15 ?? 0 },
    { key: '16_20', label: '16-20 anos', value: overview?.bucket_16_20 ?? 0 },
    { key: '21_25', label: '21-25 anos', value: overview?.bucket_21_25 ?? 0 },
    { key: '26_30', label: '26-30 anos', value: overview?.bucket_26_30 ?? 0 },
    { key: '30_plus', label: '30+ anos', value: overview?.bucket_30_plus ?? 0 },
  ];

  const total = buckets.reduce((sum, b) => sum + (b.value || 0), 0);
  const hasData = total > 0;

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 flex items-center justify-between text-xs font-medium uppercase tracking-wide text-muted-foreground">
        <span>Tempo de serviço</span>
        {avgYears != null && (
          <span className="text-[11px] font-normal text-muted-foreground">
            Média: <span className="font-semibold text-foreground">{avgYears.toFixed(1)} anos</span>
          </span>
        )}
      </div>
      {isLoading ? (
        <div className="h-24 animate-pulse rounded-md bg-muted" />
      ) : !hasData ? (
        <p className="text-xs text-muted-foreground">Nenhum militar com data de inclusão informada.</p>
      ) : (
        <div className="space-y-3 text-xs">
          <EChartBase
            height={180}
            option={{
              grid: { left: '4%', right: '4%', top: 10, bottom: 30, containLabel: true },
              tooltip: {
                trigger: 'axis',
                axisPointer: { type: 'shadow' },
                formatter: (params) => {
                  const p = params[0];
                  const d = p.data || {};
                  return [`Faixa: ${d.label}`, `${formatNumber(d.value)} militares`].join('<br/>');
                },
              },
              xAxis: {
                type: 'category',
                data: buckets.map((b) => b.label),
                axisLabel: { fontSize: 10, rotate: 30, interval: 0 },
              },
              yAxis: {
                type: 'value',
                splitLine: { lineStyle: { type: 'dashed' } },
              },
              series: [
                {
                  type: 'bar',
                  data: buckets.map((b, index) => ({
                    value: b.value,
                    label: b.label,
                    index,
                  })),
                  itemStyle: {
                    color: (params) => {
                      const palette = ['#E3F2FD', '#BBDEFB', '#90CAF9', '#64B5F6', '#42A5F5', '#1E88E5', '#1565C0'];
                      const idx = params.data.index ?? 0;
                      return palette[idx % palette.length];
                    },
                  },
                },
              ],
            }}
          />
          <p className="text-[10px] text-muted-foreground">
            * Não conta averbações ou afastamentos sem contagem de tempo.
          </p>
        </div>
      )}
    </div>
  );
}

function PersonnelAgeSection({ ageDistribution, isLoading }) {
  const buckets = Array.isArray(ageDistribution) ? ageDistribution : [];

  if (!buckets.length && !isLoading) {
    return null;
  }

  const bucketOrder = [
    '18-25',
    '26-29',
    '30-34',
    '35-39',
    '40-45',
    '46-50',
    '51-55',
    '56+',
    'sem_info',
  ];

  const bucketMap = new Map(
    buckets.map((b) => [b.bucket, { bucket: b.bucket, total: b.total ?? 0, active: b.active ?? 0 }]),
  );

  const normalizedBuckets = bucketOrder.map((key, index) => {
    const existing = bucketMap.get(key);
    const label = key === 'sem_info' ? 'Sem info' : key;
    return {
      key,
      bucketLabel: label,
      total: existing?.total ?? 0,
      active: existing?.active ?? 0,
      index,
    };
  });

  const palette = [
    '#E0F7FA',
    '#B2EBF2',
    '#80DEEA',
    '#4DD0E1',
    '#26C6DA',
    '#00BCD4',
    '#00ACC1',
    '#00838F',
    '#006064',
    '#004D40',
  ];

  const totalAge = normalizedBuckets.reduce((sum, b) => sum + (b.total ?? 0), 0);

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Idade do efetivo
      </div>
      {isLoading ? (
        <div className="h-[360px] animate-pulse rounded-md bg-muted" />
      ) : normalizedBuckets.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhum militar encontrado para o filtro atual.</p>
      ) : (
        <div className="space-y-4">
          <EChartBase
            height={180}
            option={{
              grid: { left: '6%', right: '4%', top: 20, bottom: 50, containLabel: true },
              tooltip: {
                trigger: 'axis',
                axisPointer: { type: 'shadow' },
                formatter: (params) => {
                  const p = params[0];
                  const d = p.data || {};
                  return [
                    `Faixa etária: ${d.bucketLabel}`,
                    `${formatNumber(d.total)} militares`,
                    `${formatNumber(d.active)} em atividade`,
                  ].join('<br/>');
                },
              },
              xAxis: {
                type: 'category',
                data: normalizedBuckets.map((b) => b.bucketLabel),
                axisLabel: { fontSize: 10, rotate: 45, interval: 0 },
              },
              yAxis: {
                type: 'value',
                splitLine: { lineStyle: { type: 'dashed' } },
              },
              series: [
                {
                  type: 'bar',
                  data: normalizedBuckets.map((b) => ({
                    value: b.total ?? 0,
                    bucketLabel: b.bucketLabel,
                    total: b.total ?? 0,
                    active: b.active ?? 0,
                    index: b.index,
                  })),
                  itemStyle: {
                    color: (params) => {
                      const idx = params.data.index ?? 0;
                      return palette[idx % palette.length];
                    },
                  },
                  barWidth: 26,
                  label: {
                    show: true,
                    formatter: (p) => `${p.value ?? 0}`,
                    position: 'top',
                    fontSize: 10,
                    fontWeight: 'bolder',
                    color: '#000000',
                  },
                },
              ],
            }}
          />
          <EChartBase
            height={160}
            option={{
              tooltip: {
                trigger: 'item',
                formatter: (params) => {
                  const pct = params.percent?.toFixed(1) ?? '0.0';
                  return `${params.name}<br/>${formatNumber(params.value)} militares (${pct}%)`;
                },
              },
              legend: {
                type: 'scroll',
                bottom: 0,
                textStyle: { fontSize: 9 },
              },
              series: [
                {
                  type: 'pie',
                  radius: ['40%', '70%'],
                  center: ['50%', '45%'],
                  avoidLabelOverlap: true,
                  itemStyle: {
                    borderRadius: 6,
                    borderColor: '#fff',
                    borderWidth: 2,
                  },
                  label: {
                    show: true,
                    formatter: '{d}%',
                    fontSize: 10,
                  },
                  emphasis: {
                    label: { show: true, fontSize: 12, fontWeight: 'bold' },
                  },
                  data: normalizedBuckets
                    .filter((b) => (b.total ?? 0) > 0)
                    .map((b) => ({
                      value: b.total ?? 0,
                      name: b.bucketLabel,
                      itemStyle: { color: palette[b.index % palette.length] },
                    })),
                },
              ],
            }}
          />
        </div>
      )}
    </div>
  );
}

function AlaCards({ byAla, isLoading }) {
  const items = Array.isArray(byAla) ? byAla : [];
  const maxTotal =
    items.length > 0 ? Math.max(...items.map((a) => a.total ?? 0)) : 0;

  return (
    <div className="space-y-2">
      <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Efetivo por Ala
      </div>
      {isLoading ? (
        <div className="space-y-3">
          <div className="h-20 animate-pulse rounded-md bg-muted" />
          <div className="h-20 animate-pulse rounded-md bg-muted" />
        </div>
      ) : items.length === 0 ? (
        <p className="text-xs text-muted-foreground">
          Nenhuma Ala encontrado para o filtro atual.
        </p>
      ) : (
        <div className="space-y-3">
          {items.map((a) => {
            const total = a.total ?? 0;
            const ratio = maxTotal > 0 ? total / maxTotal : 0;

            return (
              <div
                key={a.ala}
                className="space-y-1 rounded-lg border bg-background p-2.5 text-xs shadow-sm"
              >
                <div className="flex items-center justify-between">
                  <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Ala {a.ala}
                  </span>
                  <span className="text-sm font-semibold">{total}</span>
                </div>
                <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
                  <div
                    className="h-full rounded-full bg-emerald-500"
                    style={{
                      width: `${Math.max(0, Math.min(100, ratio * 100))}%`,
                    }}
                  />
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function FleetAgeSection({ ageDistribution, isLoading }) {
  const buckets = Array.isArray(ageDistribution) ? ageDistribution : [];

  if (!buckets.length && !isLoading) {
    return null;
  }

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Idade da frota
      </div>
      {isLoading ? (
        <div className="h-[220px] animate-pulse rounded-md bg-muted" />
      ) : buckets.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhuma viatura encontrada para o filtro atual.</p>
      ) : (
        <EChartBase
          height={220}
          option={{
            grid: { left: '6%', right: '4%', top: 20, bottom: 40, containLabel: true },
            tooltip: {
              trigger: 'axis',
              axisPointer: { type: 'shadow' },
              formatter: (params) => {
                const p = params[0];
                const d = p.data || {};
                return [
                  `Faixa etária: ${d.bucketLabel}`,
                  `${formatNumber(d.total)} viaturas`,
                ].join('<br/>');
              },
            },
            xAxis: {
              type: 'category',
              data: buckets.map((b) => b.bucketLabel ?? b.bucket),
              axisLabel: { fontSize: 10, rotate: 30, interval: 0 },
            },
            yAxis: {
              type: 'value',
              splitLine: { lineStyle: { type: 'dashed' } },
            },
            series: [
              {
                type: 'bar',
                data: buckets.map((b) => ({
                  value: b.total ?? 0,
                  bucketLabel: b.bucket,
                  total: b.total ?? 0,
                })),
                itemStyle: { color: '#0ea5e9' },
                barWidth: 20,
              },
            ],
          }}
        />
      )}
    </div>
  );
}

function FleetByTypeSection({ byType, isLoading }) {
  const items = Array.isArray(byType) ? byType : [];

  if (!items.length && !isLoading) {
    return null;
  }

  const total = items.reduce((sum, t) => sum + (t.total ?? 0), 0);

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Frota por tipo
      </div>
      {isLoading ? (
        <div className="h-[220px] animate-pulse rounded-md bg-muted" />
      ) : items.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhuma viatura encontrada para o filtro atual.</p>
      ) : (
        <EChartBase
          height={220}
          option={{
            grid: { left: '6%', right: '4%', top: 20, bottom: 40, containLabel: true },
            tooltip: {
              trigger: 'axis',
              axisPointer: { type: 'shadow' },
              formatter: (params) => {
                const p = params[0];
                const d = p.data || {};
                const value = d.total ?? 0;
                const pct = total > 0 ? (value * 100) / total : 0;
                return [
                  `${d.typeCode} — ${d.typeName || ''}`.trim(),
                  `${formatNumber(value)} viaturas`,
                  `${pct.toFixed(1).replace('.', ',')}% da frota`,
                ].join('<br/>');
              },
            },
            xAxis: {
              type: 'category',
              data: items.map((t) => t.typeCode),
              axisLabel: { fontSize: 10, rotate: 25, interval: 0 },
            },
            yAxis: {
              type: 'value',
              splitLine: { lineStyle: { type: 'dashed' } },
            },
            series: [
              {
                type: 'bar',
                data: items.map((t) => ({
                  value: t.total ?? 0,
                  total: t.total ?? 0,
                  typeCode: t.typeCode,
                  typeName: t.typeName,
                })),
                itemStyle: { color: '#0ea5e9' },
                barWidth: 20,
              },
            ],
          }}
        />
      )}
    </div>
  );
}

function FleetActivitySection({ byType, isLoading }) {
  const items = Array.isArray(byType) ? byType : [];

  const mapTypeToActivity = (typeCode) => {
    switch (typeCode) {
      case 'ABT':
      case 'ABR':
      case 'AT':
        return 'Combate a incêndio';
      case 'AR':
      case 'UR':
        return 'Resgate / Salvamento';
      case 'ASA':
      case 'APA':
        return 'Apoio / Abastecimento';
      default:
        return 'Outros';
    }
  };

  const activityMap = new Map();
  for (const t of items) {
    const typeCode = t.typeCode ?? 'OUTROS';
    const activity = mapTypeToActivity(typeCode);
    if (!activityMap.has(activity)) {
      activityMap.set(activity, { name: activity, total: 0, active: 0 });
    }
    const agg = activityMap.get(activity);
    agg.total += t.total ?? 0;
    agg.active += t.active ?? 0;
  }

  const activities = Array.from(activityMap.values());

  if (!activities.length && !isLoading) {
    return null;
  }

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Viaturas por atividade
      </div>
      {isLoading ? (
        <div className="h-[220px] animate-pulse rounded-md bg-muted" />
      ) : activities.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhuma viatura encontrada para o filtro atual.</p>
      ) : (
        <EChartBase
          height={220}
          option={{
            grid: { left: '6%', right: '4%', top: 20, bottom: 40, containLabel: true },
            tooltip: {
              trigger: 'axis',
              axisPointer: { type: 'shadow' },
              formatter: (params) => {
                const p = params[0];
                const d = p.data || {};
                const active = d.active ?? 0;
                const total = d.total ?? 0;
                const pct = total > 0 ? (active * 100) / total : 0;
                return [
                  d.activity,
                  `${formatNumber(total)} viaturas`,
                  `${formatNumber(active)} ativas`,
                  `${pct.toFixed(1)}% da atividade ativas`,
                ].join('<br/>');
              },
            },
            xAxis: {
              type: 'category',
              data: activities.map((a) => a.name),
              axisLabel: { fontSize: 10 },
            },
            yAxis: {
              type: 'value',
              splitLine: { lineStyle: { type: 'dashed' } },
            },
            series: [
              {
                type: 'bar',
                data: activities.map((a) => ({
                  value: a.total,
                  activity: a.name,
                  total: a.total,
                  active: a.active,
                })),
                itemStyle: { color: '#22c55e' },
                barWidth: 18,
              },
            ],
          }}
        />
      )}
    </div>
  );
}

function FleetMatrixTypeByUnitSection({ matrixTypeByUnit, isLoading }) {
  const units = matrixTypeByUnit?.units ?? [];
  const types = matrixTypeByUnit?.types ?? [];
  const cells = matrixTypeByUnit?.cells ?? [];

  if ((!units.length || !types.length || !cells.length) && !isLoading) {
    return null;
  }

  const unitIndexById = new Map(units.map((u, idx) => [u.unitId, idx]));

  const data = cells
    .map((c) => {
      const x = types.indexOf(c.typeCode);
      const y = unitIndexById.get(c.unitId);
      if (x === -1 || y == null) return null;
      return [x, y, c.availabilityPercentage ?? 0];
    })
    .filter(Boolean);

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 flex items-center justify-between">
        <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          Matriz tipo × unidade (frota)
        </div>
        <span className="text-[10px] text-muted-foreground">
          Cor = % de viaturas ativas sobre o total do tipo na unidade
        </span>
      </div>
      {isLoading ? (
        <div className="h-48 animate-pulse rounded-md bg-muted" />
      ) : (
        <EChartBase
          height={320}
          option={{
            tooltip: {
              position: 'top',
              formatter: (params) => {
                const [x, y, value] = params.data || [];
                const unit = units[y];
                const typeCode = types[x];
                const cell = cells.find(
                  (c) => c.unitId === unit.unitId && c.typeCode === typeCode,
                );
                if (!cell) return '';
                return [
                  `${unit.unitAcronym} — ${typeCode}`,
                  `${cell.active ?? 0} / ${cell.total ?? 0} ativas`,
                  `${(cell.availabilityPercentage ?? 0).toFixed(1)}%`,
                ].join('<br/>');
              },
            },
            grid: { left: 60, right: 10, top: 20, bottom: 40 },
            xAxis: {
              type: 'category',
              data: types,
              axisLabel: { rotate: 45, fontSize: 10 },
            },
            yAxis: {
              type: 'category',
              data: units.map((u) => u.unitAcronym),
              axisLabel: { fontSize: 10 },
            },
            visualMap: {
              min: 0,
              max: 100,
              calculable: false,
              orient: 'horizontal',
              left: 'center',
              bottom: 0,
              inRange: {
                color: ['#fefce8', '#facc15', '#22c55e'],
              },
              text: ['100%', '0%'],
            },
            series: [
              {
                name: 'Disponibilidade',
                type: 'heatmap',
                data,
                label: {
                  show: false,
                },
                emphasis: {
                  itemStyle: {
                    borderColor: '#0f172a',
                    borderWidth: 1,
                  },
                },
              },
            ],
          }}
        />
      )}
    </div>
  );
}

function FleetConservationSection({ conservation, isLoading }) {
  const items = Array.isArray(conservation?.byState) ? conservation.byState : [];

  if (!items.length && !isLoading) {
    return null;
  }

  const total = items.reduce((sum, s) => sum + (s.total ?? 0), 0);

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Estado de conservação da frota
      </div>
      {isLoading ? (
        <div className="h-[220px] animate-pulse rounded-md bg-muted" />
      ) : items.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhuma viatura encontrada para o filtro atual.</p>
      ) : (
        <EChartBase
          height={220}
          option={{
            grid: { left: '3%', right: '4%', top: 20, bottom: 40, containLabel: true },
            tooltip: {
              trigger: 'axis',
              axisPointer: { type: 'shadow' },
              formatter: (params) => {
                const p = params[0];
                const d = p.data || {};
                const value = d.total ?? 0;
                const pct = total > 0 ? (value * 100) / total : 0;
                return [
                  d.label,
                  `${formatNumber(value)} viaturas`,
                  `${pct.toFixed(1).replace('.', ',')}% da frota`,
                ].join('<br/>');
              },
            },
            xAxis: {
              type: 'category',
              data: items.map((s) => s.stateName),
              axisLabel: { fontSize: 10, rotate: 25, interval: 0 },
            },
            yAxis: {
              type: 'value',
              splitLine: { lineStyle: { type: 'dashed' } },
            },
            series: [
              {
                type: 'bar',
                data: items.map((s) => ({
                  value: s.total ?? 0,
                  total: s.total ?? 0,
                  label: s.stateName,
                })),
                itemStyle: { color: '#0ea5e9' },
                barWidth: 20,
              },
            ],
          }}
        />
      )}
    </div>
  );
}

function FleetByUnitSection({ byUnit, isLoading }) {
  const items = Array.isArray(byUnit) ? byUnit : [];

  if (!items.length && !isLoading) {
    return null;
  }

  const total = items.reduce((sum, u) => sum + (u.total ?? 0), 0);

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 flex items-center justify-between">
        <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          Frota por unidade
        </div>
        <span className="text-[10px] text-muted-foreground">
          Cor = % de viaturas ativas sobre o total na unidade
        </span>
      </div>
      {isLoading ? (
        <div className="h-[220px] animate-pulse rounded-md bg-muted" />
      ) : items.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhuma viatura encontrada para o filtro atual.</p>
      ) : (
        <EChartBase
          height={230}
          option={{
            grid: { left: '6%', right: '4%', top: 20, bottom: 40, containLabel: true },
            tooltip: {
              trigger: 'axis',
              axisPointer: { type: 'shadow' },
              formatter: (params) => {
                const p = params[0];
                const d = p.data || {};
                const totalUnit = d.total ?? 0;
                const active = d.active ?? 0;
                const pct = totalUnit > 0 ? (active * 100) / totalUnit : 0;
                return [
                  d.unitAcronym,
                  `${formatNumber(totalUnit)} viaturas`,
                  `${formatNumber(active)} ativas`,
                  `${pct.toFixed(1).replace('.', ',')}% da frota da unidade`,
                ].join('<br/>');
              },
            },
            xAxis: {
              type: 'category',
              data: items.map((u) => u.unitAcronym),
              axisLabel: { fontSize: 10, rotate: 25, interval: 0 },
            },
            yAxis: {
              type: 'value',
              splitLine: { lineStyle: { type: 'dashed' } },
            },
            series: [
              {
                type: 'bar',
                data: items.map((u) => ({
                  value: u.total ?? 0,
                  total: u.total ?? 0,
                  active: u.active ?? 0,
                  unitAcronym: u.unitAcronym,
                })),
                itemStyle: {
                  color: (params) => {
                    const d = params.data || {};
                    const totalUnit = d.total ?? 0;
                    const active = d.active ?? 0;
                    const pct = totalUnit > 0 ? (active * 100) / totalUnit : 0;
                    if (pct >= 80) return '#22c55e';
                    if (pct >= 60) return '#eab308';
                    return '#ef4444';
                  },
                },
                barWidth: 20,
              },
            ],
          }}
        />
      )}
    </div>
  );
}

function ClassificationSection({ classification, isLoading }) {
  const data = classification ?? {};
  const operational = data.operational?.count ?? 0;
  const administrative = data.administrative?.count ?? 0;
  const total = operational + administrative;

  if (!total && !isLoading) return null;

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Composição do efetivo
      </div>
      {isLoading ? (
        <div className="h-[230px] animate-pulse rounded-md bg-muted" />
      ) : (
        <EChartBase
          height={230}
          option={{
            tooltip: {
              trigger: 'item',
              formatter: '{b}: {c} ({d}%)',
              backgroundColor: '#F6F8FC',
              borderColor: '#8C8D8E',
              borderWidth: 1,
              borderRadius: 4,
            },
            legend: {
              show: false,
            },
            series: [
              {
                name: 'Composição do efetivo',
                type: 'pie',
                radius: ['75%', '5%'],
                label: {
                  show: true,
                  formatter: (p) => {
                    const name = p.name ?? '';
                    const value = p.value ?? 0;
                    const pct = typeof p.percent === 'number' ? p.percent : 0;
                    const pctStr = pct.toFixed(1).replace('.', ',');
                    return `{b|${name}:} {v|${value}}  {per|${pctStr}%}`;
                  },
                  backgroundColor: '#F6F8FC',
                  borderColor: '#8C8D8E',
                  borderWidth: 1,
                  borderRadius: 4,
                  padding: 4,
                  rich: {
                    b: {
                      color: '#4C5058',
                      fontSize: 11,
                    },
                    v: {
                      color: '#4C5058',
                      fontSize: 11,
                      fontWeight: 'bold',
                    },
                    per: {
                      color: '#fff',
                      backgroundColor: '#4C5058',
                      padding: [3, 4],
                      borderRadius: 4,
                      fontSize: 10,
                    },
                  },
                },
                labelLine: {
                  length: 8,
                  length2: 6,
                },
                data: [
                  { name: 'Operacionais', value: operational },
                  { name: 'Adm', value: administrative },
                ],
              },
            ],
            color: ['#f2055e', '#0ea5e9'],
          }}
        />
      )}
    </div>
  );
}

function BirthdaysSection({ birthdays, isLoading }) {
  const today = birthdays?.today ?? [];
  const next7 = birthdays?.next7Days ?? [];
  const next30 = birthdays?.next30Days ?? [];

  if (!today.length && !next7.length && !next30.length && !isLoading) {
    return null;
  }

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Próximos aniversários
      </div>
      {isLoading ? (
        <div className="h-24 animate-pulse rounded-md bg-muted" />
      ) : (
        <div className="grid gap-4 md:grid-cols-3 text-xs">
          <div>
            <div className="mb-1 text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
              Hoje
            </div>
            {today.length === 0 ? (
              <p className="text-[11px] text-muted-foreground">Nenhum aniversário hoje.</p>
            ) : (
              <div className="space-y-1">
                {today.map((b, idx) => (
                  <div key={idx} className="rounded-md bg-muted/40 px-2 py-1.5">
                    <div className="text-[11px] font-medium">
                      {b.rankCode} {b.warName}
                    </div>
                    <div className="text-[10px] text-muted-foreground">{b.unitAcronym}</div>
                  </div>
                ))}
              </div>
            )}
          </div>
          <div>
            <div className="mb-1 text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
              Próximos 7 dias
            </div>
            {next7.length === 0 ? (
              <p className="text-[11px] text-muted-foreground">Nenhum aniversário nos próximos 7 dias.</p>
            ) : (
              <div className="space-y-1">
                {next7.map((b, idx) => (
                  <div key={idx} className="rounded-md bg-muted/40 px-2 py-1.5">
                    <div className="text-[11px] font-medium">
                      {b.rankCode} {b.warName}
                    </div>
                    <div className="text-[10px] text-muted-foreground">
                      {b.unitAcronym} • {new Date(b.birthDate).toLocaleDateString('pt-BR')} ({b.daysUntil}d)
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
          <div>
            <div className="mb-1 text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
              Próximos 30 dias
            </div>
            {next30.length === 0 ? (
              <p className="text-[11px] text-muted-foreground">Nenhum aniversário nos próximos 30 dias.</p>
            ) : (
              <div className="space-y-1">
                {next30.map((b, idx) => (
                  <div key={idx} className="rounded-md bg-muted/40 px-2 py-1.5">
                    <div className="text-[11px] font-medium">
                      {b.rankCode} {b.warName}
                    </div>
                    <div className="text-[10px] text-muted-foreground">
                      {b.unitAcronym} • {new Date(b.birthDate).toLocaleDateString('pt-BR')} ({b.daysUntil}d)
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function LastUpdatesSection({ updates, units, isLoading }) {
  const unitById = new Map((units ?? []).map((u) => [u.id, u]));
  const sortedUpdates = Array.isArray(updates)
    ? [...updates].sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at))
    : [];

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Últimas atualizações por unidade
      </div>
      {isLoading ? (
        <div className="h-24 animate-pulse rounded-md bg-muted" />
      ) : sortedUpdates.length === 0 ? (
        <p className="text-[11px] text-muted-foreground">Nenhuma atualização registrada.</p>
      ) : (
        <div className="space-y-1 text-xs">
          {sortedUpdates.map((update) => {
            const unit = unitById.get(update.unit_id);
            const userName = update.userName || 'Usuário desconhecido';
            const updatedAt = new Date(update.updated_at || 0);
            const createdAt = new Date(update.created_at || 0);
            const latest = createdAt > updatedAt ? createdAt : updatedAt;
            const date = update.created_at || update.updated_at
              ? latest.toLocaleDateString('pt-BR')
              : '-';

            return (
              <div key={update.unit_id} className="rounded-md bg-muted/40 px-2 py-1.5">
                <span className="text-[11px] font-medium">{unit?.acronym || 'Unidade'}</span>
                <span className="text-[10px] text-muted-foreground">
                  {' '}— em {date} por "{userName}"
                </span>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function PersonnelKpiRow({ totals, availability, isLoading }) {
  const total = totals?.total ?? 0;
  const available = totals?.available ?? 0;
  const operational = totals?.operational ?? 0;
  const administrative = totals?.administrative ?? 0;
  const away = totals?.away ?? 0;
  const inCourse = totals?.inCourse ?? 0;

  const availablePct = total > 0 ? (available * 100) / total : 0;
  const awayPct = total > 0 ? (away * 100) / total : 0;

  return (
    <div className="grid gap-4 lg:grid-cols-8">
      <AvailabilityCard availability={availability} isLoading={isLoading} />

      <div className="grid gap-3 md:grid-cols-3 lg:col-span-5">
        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Efetivo total
          </div>
          {isLoading ? (
            <div className="h-5 w-16 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(total)}</div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Disponíveis
          </div>
          {isLoading ? (
            <div className="h-5 w-24 animate-pulse rounded bg-muted" />
          ) : (
            <div className="space-y-0.5 text-sm">
              <div className="text-lg font-semibold">{formatNumber(available)}</div>
              <div className="text-[11px] text-muted-foreground">
                {total > 0 ? `${availablePct.toFixed(1).replace('.', ',')}% do efetivo` : '—'}
              </div>
            </div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Operacionais
          </div>
          {isLoading ? (
            <div className="h-5 w-16 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(operational)}</div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Administrativos
          </div>
          {isLoading ? (
            <div className="h-5 w-20 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(administrative)}</div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Afastados
          </div>
          {isLoading ? (
            <div className="h-5 w-24 animate-pulse rounded bg-muted" />
          ) : (
            <div className="space-y-0.5 text-sm">
              <div className="text-lg font-semibold">{formatNumber(away)}</div>
              <div className="text-[11px] text-muted-foreground">
                {total > 0 ? `${awayPct.toFixed(1).replace('.', ',')}% do efetivo` : '—'}
              </div>
            </div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Em curso
          </div>
          {isLoading ? (
            <div className="h-5 w-16 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(inCourse)}</div>
          )}
        </div>
      </div>
    </div>
  );
}

function RankDistributionSection({ byRank, isLoading }) {
  const items = Array.isArray(byRank) ? byRank : [];
  const hasData = items.length > 0;

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Efetivo por posto/graduação
      </div>
      {isLoading ? (
        <div className="h-[260px] animate-pulse rounded-md bg-muted" />
      ) : !hasData ? (
        <p className="text-xs text-muted-foreground">Nenhum militar encontrado para o filtro atual.</p>
      ) : (
        <EChartBase
          height={260}
          option={{
            grid: { left: '3%', right: '4%', top: 10, bottom: 10, containLabel: true },
            tooltip: {
              trigger: 'axis',
              axisPointer: { type: 'shadow' },
              formatter: (params) => {
                const p = params[0];
                const d = p.data || {};
                const total = d.total ?? 0;
                const available = d.available ?? 0;
                const pct = total > 0 ? (available * 100) / total : 0;
                return [
                  `${d.rankCode} - ${d.rankName || ''}`.trim(),
                  `${available} / ${total} disponíveis`,
                  `${pct.toFixed(1)}%`,
                ].join('<br/>');
              },
            },
            xAxis: {
              type: 'category',
              data: items.map((r) => r.rankCode),
              axisLabel: { fontSize: 10, interval: 0, rotate: 30 },
            },
            yAxis: {
              type: 'value',
              splitLine: { lineStyle: { type: 'dashed' } },
            },
            series: [
              {
                type: 'bar',
                data: items.map((r, idx) => ({
                  value: r.available ?? 0,
                  rankCode: r.rankCode,
                  rankName: r.rankName,
                  total: r.total ?? 0,
                  available: r.available ?? 0,
                  index: idx,
                })),
                itemStyle: {
                  color: (params) => {
                    const palette = [
                      '#520000',
                      '#610707',
                      '#700E0E',
                      '#7F1515',
                      '#8F1C1C',
                      '#9E2323',
                      '#AD2A2A',
                      '#BC3131',
                      '#CC3838',
                      '#DB3F3F',
                      '#EA4646',
                      '#F94D4D',
                      '#FF5050',
                    ];
                    return palette[params.data.index % palette.length];
                  },
                },
                barWidth: 28,
                label: {
                  show: true,
                  formatter: (p) => `${p.value ?? 0}`,
                  position: 'top',
                  fontStyle: 'oblique',
                  fontWeight: 'bolder',
                  color: '#000000',
                },
              },
            ],
          }}
        />
      )}
    </div>
  );
}

function PersonnelStatusSection({ statusBreakdown, totals, leaves, isLoading }) {
  const total = totals?.total ?? 0;
  const availableCount =
    totals?.available ?? statusBreakdown?.available?.count ?? 0;

  const leavesByType = Array.isArray(leaves?.byType) ? leaves.byType : [];

  const slices = [];
  if (availableCount > 0) {
    slices.push({ name: 'Ativos', value: availableCount });
  }

  for (const lt of leavesByType) {
    const value = lt.current ?? lt.total ?? 0;
    if (value > 0) {
      slices.push({ name: lt.leaveTypeName, value });
    }
  }

  const hasData = slices.some((s) => s.value > 0);

  return (
    <div className="flex h-full flex-col rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Situação do efetivo
      </div>
      {isLoading ? (
        <div className="h-[230px] animate-pulse rounded-md bg-muted" />
      ) : !hasData ? (
        <p className="text-xs text-muted-foreground">Nenhum militar encontrado para o filtro atual.</p>
      ) : (
        <div className="space-y-3 text-xs">
          <EChartBase
            height={230}
            option={{
              tooltip: {
                trigger: 'item',
                formatter: '{b}: {c} ({d}%)',
                backgroundColor: '#F6F8FC',
                borderColor: '#8C8D8E',
                borderWidth: 1,
                borderRadius: 4,
              },
              legend: {
                show: false,
              },
              series: [
                {
                  name: 'Situação do efetivo',
                  type: 'pie',
                  radius: ['50%', '75%'],
                  avoidLabelOverlap: false,
                  label: {
                    show: true,
                    formatter: (p) => {
                      const name = p.name ?? '';
                      const value = p.value ?? 0;
                      const pct = typeof p.percent === 'number' ? p.percent : 0;
                      const pctStr = pct.toFixed(1).replace('.', ',');
                      return `{b|${name}:} {v|${value}}  {per|${pctStr}%}`;
                    },
                    backgroundColor: '#F6F8FC',
                    borderColor: '#8C8D8E',
                    borderWidth: 1,
                    borderRadius: 4,
                    padding: 4,
                    rich: {
                      b: {
                        color: '#4C5058',
                        fontSize: 11,
                      },
                      v: {
                        color: '#4C5058',
                        fontSize: 11,
                        fontWeight: 'bold',
                      },
                      per: {
                        color: '#fff',
                        backgroundColor: '#fC5058',
                        padding: [3, 4],
                        borderRadius: 4,
                        fontSize: 10,
                      },
                    },
                  },
                  labelLine: {
                    length: 8,
                    length2: 6,
                  },
                  data: slices,
                },
              ],
              color: ['#22c55e', '#f97316', '#eab308', '#0ea5e9', '#6366f1'],
            }}
          />
        </div>
      )}
    </div>
  );
}

function LeavesSection({ leaves, isLoading }) {
  const byType = Array.isArray(leaves?.byType) ? leaves.byType : [];
  const currentLeaves = Array.isArray(leaves?.currentLeaves)
    ? leaves.currentLeaves
    : [];
  const upcomingReturns = Array.isArray(leaves?.upcomingReturns)
    ? leaves.upcomingReturns
    : [];

  const totalCurrent = byType.reduce(
    (sum, t) => sum + (t.current ?? 0),
    0,
  );

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 flex items-center justify-between">
        <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          Afastamentos
        </div>
      </div>
      {isLoading ? (
        <div className="h-32 animate-pulse rounded-md bg-muted" />
      ) : byType.length === 0 && currentLeaves.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhum afastamento registrado para o filtro atual.</p>
      ) : (
        <div className="grid gap-4 md:grid-cols-[minmax(0,1.4fr)_minmax(0,1.6fr)] text-xs">
          <div className="space-y-2">
            <div className="grid gap-2 md:grid-cols-2">
              <div className="space-y-1 rounded-md bg-muted/40 p-2">
                <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                  Em afastamento hoje
                </div>
                <div className="text-lg font-semibold">
                  {formatNumber(totalCurrent)}
                </div>
              </div>
              <div className="space-y-1 rounded-md bg-muted/40 p-2">
                <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                  Retornos nos próximos 30 dias
                </div>
                <div className="text-lg font-semibold">
                  {formatNumber(upcomingReturns.length)}
                </div>
              </div>
            </div>

            <EChartBase
              height={220}
              option={{
                grid: { left: '3%', right: '4%', top: 30, bottom: 10, containLabel: true },
                tooltip: {
                  trigger: 'axis',
                  axisPointer: { type: 'shadow' },
                },
                xAxis: {
                  type: 'category',
                  data: byType.map((t) => t.leaveTypeName),
                },
                yAxis: {
                  type: 'value',
                  splitLine: { lineStyle: { type: 'dashed' } },
                },
                series: [
                  {
                    name: 'Ativos em afastamento',
                    type: 'bar',
                    data: byType.map((t) => t.current ?? 0),
                    itemStyle: { color: '#eab308' },
                    barWidth: 14,
                  },
                ],
              }}
            />
          </div>

          <div className="space-y-3">
            <div>
              <div className="mb-1 text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Em afastamento
              </div>
              {currentLeaves.length === 0 ? (
                <p className="text-[11px] text-muted-foreground">Nenhum militar afastado hoje.</p>
              ) : (
                <div className="space-y-1">
                  {currentLeaves.map((l) => (
                    <div
                      key={l.id}
                      className="flex items-center justify-between rounded-md bg-muted/40 px-2 py-1.5"
                    >
                      <div className="flex flex-col">
                        <span className="text-[11px] font-medium">
                          {l.rankCode} {l.warName}
                        </span>
                        <span className="text-[10px] text-muted-foreground">
                          {l.unitAcronym} • {l.leaveTypeName}
                        </span>
                      </div>
                      <div className="text-right text-[10px] text-muted-foreground">
                        <div>
                          Início: {new Date(l.startDate).toLocaleDateString('pt-BR')}
                        </div>
                        {l.isIndefinite ? (
                          <div>Indeterminado</div>
                        ) : l.endDate ? (
                          <div>
                            Até: {new Date(l.endDate).toLocaleDateString('pt-BR')}
                          </div>
                        ) : null}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div>
              <div className="mb-1 text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Próximos retornos (30 dias)
              </div>
              {upcomingReturns.length === 0 ? (
                <p className="text-[11px] text-muted-foreground">Nenhum retorno previsto nos próximos 30 dias.</p>
              ) : (
                <div className="space-y-1">
                  {upcomingReturns.map((l) => (
                    <div
                      key={l.id}
                      className="flex items-center justify-between rounded-md bg-muted/40 px-2 py-1.5"
                    >
                      <div className="flex flex-col">
                        <span className="text-[11px] font-medium">
                          {l.rankCode} {l.warName}
                        </span>
                        <span className="text-[10px] text-muted-foreground">
                          {l.unitAcronym} • {l.leaveTypeName}
                        </span>
                      </div>
                      <div className="text-right text-[10px] text-muted-foreground">
                        <div>
                          Retorno: {new Date(l.endDate).toLocaleDateString('pt-BR')}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function TafOverviewSection({ overview, isLoading }) {
  const total = overview?.total_military ?? 0;

  const items = [
    {
      key: 'excellent',
      label: 'E',
      count: overview?.count_excellent ?? 0,
      light: 'bg-emerald-100 text-emerald-800',
      dark: 'dark:bg-emerald-950/40 dark:text-emerald-200',
    },
    {
      key: 'very_good',
      label: 'MB',
      count: overview?.count_very_good ?? 0,
      light: 'bg-emerald-50 text-emerald-700',
      dark: 'dark:bg-emerald-950/30 dark:text-emerald-200',
    },
    {
      key: 'good',
      label: 'B',
      count: overview?.count_good ?? 0,
      light: 'bg-lime-100 text-lime-800',
      dark: 'dark:bg-lime-950/30 dark:text-lime-200',
    },
    {
      key: 'regular',
      label: 'R',
      count: overview?.count_regular ?? 0,
      light: 'bg-amber-100 text-amber-800',
      dark: 'dark:bg-amber-950/30 dark:text-amber-200',
    },
    {
      key: 'insufficient',
      label: 'I',
      count: overview?.count_insufficient ?? 0,
      light: 'bg-red-100 text-red-800',
      dark: 'dark:bg-red-950/30 dark:text-red-200',
    },
    {
      key: 'without_taf',
      label: 'Não fez',
      count: overview?.without_taf ?? 0,
      light: 'bg-muted/40 text-muted-foreground',
      dark: 'dark:bg-neutral-700/40 dark:text-neutral-200',
    },
  ];

  const hasData = total > 0;

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        TAF mais recente da tropa
      </div>
      {isLoading ? (
        <div className="h-20 animate-pulse rounded-md bg-muted" />
      ) : !hasData ? (
        <p className="text-xs text-muted-foreground">
          Nenhum militar encontrado para o filtro atual.
        </p>
      ) : (
        <div className="grid grid-cols-2 gap-2 text-xs sm:grid-cols-3 md:grid-cols-6">
          {items.map((item) => {
            const pct = total > 0 ? ((item.count * 100) / total).toFixed(1).replace('.', ',') : '0,0';
            return (
              <div
                key={item.key}
                className={`space-y-1 rounded-md p-2 ${item.light} ${item.dark}`}
              >
                <div className="text-[10px] font-medium uppercase tracking-wide">
                  {item.label}
                </div>
                <div className="flex items-baseline justify-between gap-1">
                  <div className="text-lg font-semibold">
                    {formatNumber(item.count)}
                  </div>
                  <div className="text-[10px] opacity-80">
                    {pct}%
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function InsightsSection({ insights, isLoading }) {
  const items = Array.isArray(insights) ? insights : [];

  if (!items.length && !isLoading) {
    return null;
  }

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Insights operacionais
      </div>
      {isLoading ? (
        <div className="h-16 animate-pulse rounded-md bg-muted" />
      ) : items.length === 0 ? (
        <p className="text-xs text-muted-foreground">Nenhum insight gerado para o filtro atual.</p>
      ) : (
        <ul className="space-y-1 text-xs">
          {items.map((i) => (
            <li
              key={i.code}
              className={
                i.severity === 'error'
                  ? 'rounded-md bg-red-50 px-2 py-1 text-red-700 dark:bg-red-950/30 dark:text-red-200'
                  : i.severity === 'warning'
                    ? 'rounded-md bg-amber-50 px-2 py-1 text-amber-700 dark:bg-amber-950/30 dark:text-amber-200'
                    : 'rounded-md bg-muted/40 px-2 py-1 text-muted-foreground'
              }
            >
              {i.message}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

function DriverLicenseCapacitySection({ driverLicenses, isLoading }) {
  const summary = driverLicenses?.summary ?? {};
  const rows = Array.isArray(driverLicenses?.byCategory)
    ? driverLicenses.byCategory
    : [];

  return (
    <div className="rounded-lg border bg-background p-4">
      <div className="mb-2 flex items-center justify-between">
        <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          Capacidade de condução / CNH
        </div>
      </div>
      {isLoading ? (
        <div className="h-24 animate-pulse rounded-md bg-muted" />
      ) : rows.length === 0 ? (
        <p className="text-xs text-muted-foreground">
          Nenhuma CNH cadastrada para o filtro atual.
        </p>
      ) : (
        <div className="space-y-3 text-xs">
          <div className="grid gap-3 md:grid-cols-3">
            <div className="space-y-1 rounded-md bg-muted/40 p-2">
              <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                Condutores disponíveis
              </div>
              <div className="text-lg font-semibold">
                {formatNumber(summary.driversAvailable)}
              </div>
            </div>
            <div className="space-y-1 rounded-md bg-muted/40 p-2">
              <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                CNHs vencidas
              </div>
              <div className="text-lg font-semibold text-red-600">
                {formatNumber(summary.expired)}
              </div>
            </div>
            <div className="space-y-1 rounded-md bg-muted/40 p-2">
              <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                Vencendo em 30 dias
              </div>
              <div className="text-lg font-semibold text-amber-600">
                {formatNumber(summary.expiringIn30Days)}
              </div>
            </div>
          </div>

          <EChartBase
            height={260}
            option={{
              grid: { left: '3%', right: '4%', top: 30, bottom: 10, containLabel: true },
              tooltip: {
                trigger: 'axis',
                axisPointer: { type: 'shadow' },
              },
              legend: {
                top: 0,
                textStyle: { fontSize: 10 },
              },
              xAxis: {
                type: 'category',
                data: rows.map((r) => r.category),
              },
              yAxis: {
                type: 'value',
                splitLine: { lineStyle: { type: 'dashed' } },
              },
              series: [
                {
                  name: 'Condutores disponíveis',
                  type: 'bar',
                  data: rows.map((r) => r.driversAvailable ?? 0),
                  itemStyle: { color: '#22c55e' },
                  barWidth: 16,
                },
                {
                  name: 'CNHs vencidas',
                  type: 'bar',
                  data: rows.map((r) => r.expired ?? 0),
                  itemStyle: { color: '#ef4444' },
                  barWidth: 16,
                },
                {
                  name: 'Vencendo em 30 dias',
                  type: 'bar',
                  data: rows.map((r) => r.expiringIn30Days ?? 0),
                  itemStyle: { color: '#eab308' },
                  barWidth: 16,
                },
              ],
            }}
          />
        </div>
      )}
    </div>
  );
}

function FleetKpiRow({ totals, availability, isLoading }) {
  const total = totals?.total ?? 0;
  const available = totals?.available ?? 0;
  const active = totals?.active ?? 0;
  const inactive = totals?.inactive ?? 0;
  const inMaintenance = totals?.inMaintenance ?? 0;

  const availabilityPct = availability?.percentage ?? (total > 0 ? (available * 100) / total : 0);

  return (
    <div className="grid gap-4 lg:grid-cols-8">
      <div className="rounded-lg border bg-background p-4 md:col-span-3">
        <div className="mb-2 flex items-center justify-between">
          <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
            Disponibilidade da frota
          </div>
          <span className="text-[10px] text-muted-foreground">ativas / total</span>
        </div>
        {isLoading ? (
          <div className="h-8 animate-pulse rounded-md bg-muted" />
        ) : (
          <div className="space-y-2 text-sm">
            <div className="flex items-baseline justify-between gap-2">
              <span className="text-2xl font-semibold">
                {availabilityPct.toLocaleString('pt-BR', { maximumFractionDigits: 1 })}%
              </span>
              <span className="text-xs text-muted-foreground">
                {formatNumber(available)} de {formatNumber(total)} viaturas ativas
              </span>
            </div>
            <div className="h-2 w-full overflow-hidden rounded-full bg-muted">
              <div
                className="h-full rounded-full bg-emerald-500"
                style={{ width: `${Math.max(0, Math.min(100, availabilityPct))}%` }}
              />
            </div>
          </div>
        )}
      </div>

      <div className="grid gap-3 md:grid-cols-3 lg:col-span-5">
        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Frota total
          </div>
          {isLoading ? (
            <div className="h-5 w-16 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(total)}</div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Ativas
          </div>
          {isLoading ? (
            <div className="h-5 w-16 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(active)}</div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Inativas
          </div>
          {isLoading ? (
            <div className="h-5 w-20 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(inactive)}</div>
          )}
        </div>

        <div className="space-y-1 rounded-lg border bg-background p-3">
          <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
            Em manutenção
          </div>
          {isLoading ? (
            <div className="h-5 w-24 animate-pulse rounded bg-muted" />
          ) : (
            <div className="text-lg font-semibold">{formatNumber(inMaintenance)}</div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function DashboardPage() {
  const [selectedUnitIds, setSelectedUnitIds] = useState([]);
  const [initializedUnitsFilter, setInitializedUnitsFilter] = useState(false);
  const [activeTab, setActiveTab] = useState('militares');

  const { unitId: userUnitId } = useAuth();

  const {
    data: units,
    isLoading: isLoadingUnits,
    error: unitsError,
  } = useUnits();

  const allUnitIds = units?.map((u) => u.id) ?? [];

  useEffect(() => {
    if (!units || units.length === 0 || initializedUnitsFilter) return;

    if (!userUnitId) {
      // Usuário regional: inicia com todas as unidades selecionadas
      setSelectedUnitIds(units.map((u) => u.id));
    } else {
      // Usuário lotado em unidade específica: inicia com sua unidade
      setSelectedUnitIds([userUnitId]);
    }
    setInitializedUnitsFilter(true);
  }, [units, userUnitId, initializedUnitsFilter]);

  const isAllSelected =
    selectedUnitIds.length === 0 ||
    (allUnitIds.length > 0 && selectedUnitIds.length === allUnitIds.length);

  const unitIdForTaf = !isAllSelected && selectedUnitIds.length === 1 ? selectedUnitIds[0] : null;

  const {
    data: personnelSummary,
    isLoading: isLoadingPersonnel,
    error: personnelError,
    refetch: refetchPersonnel,
    dataUpdatedAt: personnelUpdatedAt,
  } = useOperationalDashboardPersonnel({
    unitIds: isAllSelected ? null : selectedUnitIds,
  });

  const {
    data: vehicleSummary,
    isLoading: isLoadingVehicles,
    error: vehiclesError,
    refetch: refetchVehicles,
    dataUpdatedAt: vehiclesUpdatedAt,
  } = useOperationalDashboardVehicles({
    unitIds: isAllSelected ? null : selectedUnitIds,
  });

  const {
    data: lastUpdatesByUnit,
    isLoading: isLoadingLastUpdates,
  } = useQuery({
    queryKey: ['last-updates-by-unit'],
    queryFn: async () => {
      const columns = 'unit_id, created_at, updated_at, updated_by';

      const [personnel, vehicles, equipment] = await Promise.all([
        supabase.from('military_personnel').select(columns).not('unit_id', 'is', null),
        supabase.from('vehicles').select(columns).not('unit_id', 'is', null),
        supabase.from('equipment').select(columns).not('unit_id', 'is', null),
      ]);

      if (personnel.error) throw personnel.error;
      if (vehicles.error) throw vehicles.error;
      if (equipment.error) throw equipment.error;

      const byUnit = new Map();
      for (const row of [...(personnel.data ?? []), ...(vehicles.data ?? []), ...(equipment.data ?? [])]) {
        if (!row.unit_id) continue;

        const updatedAt = new Date(row.updated_at || 0);
        const createdAt = new Date(row.created_at || 0);
        const latest = createdAt > updatedAt ? createdAt : updatedAt;

        const existing = byUnit.get(row.unit_id);
        const existingLatest = existing
          ? Math.max(new Date(existing.created_at || 0), new Date(existing.updated_at || 0))
          : 0;

        if (!existing || latest.getTime() > existingLatest) {
          byUnit.set(row.unit_id, row);
        }
      }

      const userIds = Array.from(
        new Set(
          Array.from(byUnit.values())
            .map((row) => row.updated_by)
            .filter(Boolean),
        ),
      );

      const userNames = new Map();
      if (userIds.length > 0) {
        const { data: profiles, error: profilesError } = await supabase
          .from('profiles')
          .select('id, full_name')
          .in('id', userIds);

        if (profilesError) throw profilesError;

        for (const profile of profiles ?? []) {
          userNames.set(profile.id, profile.full_name || profile.email || 'Usuário');
        }
      }

      return Array.from(byUnit.values()).map((row) => ({
        ...row,
        userName: userNames.get(row.updated_by) || 'Usuário desconhecido',
      }));
    },
  });

  const {
    data: tafOverview,
    isLoading: isLoadingTafOverview,
  } = useQuery({
    queryKey: ['taf-overview', { unitId: unitIdForTaf ?? null }],
    queryFn: async () => {
      const payload = {
        p_unit_id: unitIdForTaf ?? null,
      };

      const { data, error } = await supabase.rpc('taf_latest_overview', payload);
      if (error) {
        throw error;
      }

      return Array.isArray(data) && data.length > 0 ? data[0] : null;
    },
  });

  const isLoading = isLoadingUnits || isLoadingPersonnel || isLoadingVehicles;

  const {
    data: healthOverview,
    isLoading: isLoadingHealthOverview,
  } = useQuery({
    queryKey: ['health-overview', { unitId: unitIdForTaf ?? null }],
    queryFn: async () => {
      const payload = {
        p_unit_id: unitIdForTaf ?? null,
      };

      const { data, error } = await supabase.rpc('health_latest_overview', payload);
      if (error) {
        throw error;
      }

      return Array.isArray(data) && data.length > 0 ? data[0] : null;
    },
  });

  const {
    data: serviceTimeOverview,
    isLoading: isLoadingServiceTime,
  } = useQuery({
    queryKey: ['service-time-overview', { unitId: unitIdForTaf ?? null }],
    queryFn: async () => {
      const payload = {
        p_unit_id: unitIdForTaf ?? null,
      };

      const { data, error } = await supabase.rpc('service_time_overview', payload);
      if (error) {
        throw error;
      }

      return Array.isArray(data) && data.length > 0 ? data[0] : null;
    },
  });

  const lastUpdated = Math.min(
    personnelUpdatedAt || Date.now(),
    vehiclesUpdatedAt || Date.now(),
  );

  const military = personnelSummary?.totals ?? {};
  const vehicles = vehicleSummary?.totals ?? {};
  const equipment = {}; // placeholder até termos resumo ampliado de equipamentos

  const birthdays = personnelSummary?.birthdays;
  const birthdaysTodayCount = birthdays?.today?.length ?? 0;
  const birthdaysNext7Count = birthdays?.next7Days?.length ?? 0;

  const baseInsights = Array.isArray(personnelSummary?.insights)
    ? personnelSummary.insights
    : [];

  const enrichedInsights = [...baseInsights];

  if (birthdaysNext7Count > 0) {
    enrichedInsights.unshift({
      code: 'birthdays_next7',
      severity: 'info',
      message: `${birthdaysNext7Count} aniversariante(s) nos próximos 7 dias.`,
    });
  }

  if (birthdaysTodayCount > 0) {
    enrichedInsights.unshift({
      code: 'birthdays_today',
      severity: 'info',
      message: `${birthdaysTodayCount} aniversariante(s) hoje.`,
    });
  }

  const handleRefresh = () => {
    refetchPersonnel();
    refetchVehicles();
  };

  const handleClearFilters = () => {
    if (!units || units.length === 0) return;

    if (!userUnitId) {
      setSelectedUnitIds(units.map((u) => u.id));
    } else {
      setSelectedUnitIds([userUnitId]);
    }
  };

  const handleToggleUnitChip = (unitId) => {
    if (!allUnitIds || allUnitIds.length === 0) return;

    setSelectedUnitIds((prev) => {
      const exists = prev.includes(unitId);
      if (exists) {
        const next = prev.filter((id) => id !== unitId);
        // Evita cenário sem nenhuma unidade: volta para "todas"
        if (next.length === 0) {
          return allUnitIds;
        }
        return next;
      }

      const next = [...prev, unitId];
      if (next.length > allUnitIds.length) return allUnitIds;
      return next;
    });
  };

  const handleSelectAllUnits = () => {
    if (!units || units.length === 0) return;
    setSelectedUnitIds(units.map((u) => u.id));
  };

  return (
    <div className="space-y-4">
      <div className="flex flex-col justify-between gap-3 md:flex-row md:items-end">
        <div>
          <h1 className="text-lg font-semibold tracking-tight">Poder Operacional</h1>
          <p className="text-sm text-muted-foreground">
            Visão consolidada de efetivo, disponibilidade operacional e capacidade da frota.
          </p>
        </div>
        <div className="flex flex-col gap-2 text-sm md:flex-row md:items-center">
          <div className="flex flex-col gap-1">
            <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Unidades</span>
            <div className="flex flex-wrap justify-center gap-2 md:justify-end">
              <button
                type="button"
                onClick={handleSelectAllUnits}
                disabled={isLoadingUnits}
                className={`h-8 rounded-full border px-4 text-xs font-medium transition-colors ${
                  isAllSelected
                    ? 'border-primary bg-primary/10 text-primary dark:bg-primary dark:text-white'
                    : 'border-muted bg-background text-muted-foreground hover:bg-muted'
                }`}
              >
                Todas
              </button>
              {units?.map((unit) => {
                const isActive = selectedUnitIds.includes(unit.id);
                return (
                  <button
                    key={unit.id}
                    type="button"
                    onClick={() => handleToggleUnitChip(unit.id)}
                    disabled={isLoadingUnits}
                    className={`h-8 rounded-full border px-4 text-xs transition-colors ${
                      isActive
                        ? 'border-primary bg-primary/10 text-primary dark:bg-primary dark:text-white'
                        : 'border-muted bg-background text-muted-foreground hover:bg-muted'
                    }`}
                  >
                    {unit.acronym}
                  </button>
                );
              })}
            </div>
          </div>
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <button
              type="button"
              onClick={handleRefresh}
              className="h-8 rounded-md border bg-background px-3 text-xs font-medium hover:bg-muted"
            >
              Atualizar
            </button>
            <button
              type="button"
              onClick={handleClearFilters}
              className="h-8 rounded-md border bg-background px-3 text-xs hover:bg-muted"
            >
              Limpar filtros
            </button>

          </div>
        </div>
      </div>

      {unitsError && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de unidades.
        </div>
      )}

      {(personnelError || vehiclesError) && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar os dados do painel operacional.
        </div>
      )}

      <InsightsSection
        insights={enrichedInsights}
        isLoading={isLoading}
      />

      <div className="flex gap-2 border-b text-sm">
        <button
          type="button"
          onClick={() => setActiveTab('militares')}
          className={`border-b-2 px-3 py-1 text-xs font-medium transition-colors ${
            activeTab === 'militares'
              ? 'border-primary text-primary'
              : 'border-transparent text-muted-foreground hover:text-foreground'
          }`}
        >
          Militares
        </button>
        <button
          type="button"
          onClick={() => setActiveTab('viaturas')}
          className={`border-b-2 px-3 py-1 text-xs font-medium transition-colors ${
            activeTab === 'viaturas'
              ? 'border-primary text-primary'
              : 'border-transparent text-muted-foreground hover:text-foreground'
          }`}
        >
          Viaturas
        </button>
      </div>

      {activeTab === 'militares' && (
        <div className="space-y-4">
          <PersonnelKpiRow
            totals={personnelSummary?.totals}
            availability={personnelSummary?.availability}
            isLoading={isLoading}
          />
          <div className="grid gap-4 lg:grid-cols-8">
            <div className="lg:col-span-2">
              <PersonnelStatusSection
                statusBreakdown={personnelSummary?.statusBreakdown}
                totals={personnelSummary?.totals}
                leaves={personnelSummary?.leaves}
                isLoading={isLoading}
              />
            </div>
            <div className="lg:col-span-2">
              <ClassificationSection
                classification={personnelSummary?.classification}
                isLoading={isLoading}
              />
            </div>
            <div className="lg:col-span-1 flex flex-col gap-4">
              <AlaCards byAla={personnelSummary?.byAla} isLoading={isLoading} />
            </div>
            <div className="lg:col-span-3">
              <RankDistributionSection
                byRank={personnelSummary?.byRank}
                isLoading={isLoading}
              />
            </div>
          </div>

          <div className="grid gap-4 lg:grid-cols-3">
            <div className="lg:col-span-1 space-y-4">
              <BirthdaysSection
                birthdays={personnelSummary?.birthdays}
                isLoading={isLoading}
              />
              <LastUpdatesSection
                updates={lastUpdatesByUnit}
                units={units}
                isLoading={isLoadingLastUpdates}
              />
            </div>
            <div className="lg:col-span-1 flex flex-col gap-4">
              <PersonnelAgeSection
                ageDistribution={personnelSummary?.ageDistribution}
                isLoading={isLoading}
              />
              <ServiceTimeSection
                overview={serviceTimeOverview}
                isLoading={isLoadingServiceTime}
              />
              <DriverLicenseCapacitySection
                driverLicenses={personnelSummary?.driverLicenses}
                isLoading={isLoading}
              />
            </div>
            <div className="lg:col-span-1 flex flex-col gap-4">
              <LeavesSection
                leaves={personnelSummary?.leaves}
                isLoading={isLoading}
              />
              <TafOverviewSection
                overview={tafOverview}
                isLoading={isLoadingTafOverview}
              />
              <HealthOverviewSection
                overview={healthOverview}
                isLoading={isLoadingHealthOverview}
              />
            </div>
          </div>
        </div>
      )}

      {activeTab === 'viaturas' && (
        <div className="space-y-4">
          <FleetKpiRow
            totals={vehicles}
            availability={vehicleSummary?.availability}
            isLoading={isLoading}
          />

          <div className="grid gap-4 lg:grid-cols-2">
            <FleetConservationSection
              conservation={vehicleSummary?.conservation}
              isLoading={isLoading}
            />
            <FleetByUnitSection
              byUnit={vehicleSummary?.byUnit}
              isLoading={isLoading}
            />
          </div>

          <div className="grid gap-4 lg:grid-cols-2">
            <FleetByTypeSection
              byType={vehicleSummary?.byType}
              isLoading={isLoading}
            />
            <FleetMatrixTypeByUnitSection
              matrixTypeByUnit={vehicleSummary?.matrixTypeByUnit}
              isLoading={isLoading}
            />
          </div>

          <div className="grid gap-4 lg:grid-cols-2">
            <FleetAgeSection
              ageDistribution={vehicleSummary?.ageDistribution}
              isLoading={isLoading}
            />
            <FleetActivitySection
              byType={vehicleSummary?.byType}
              isLoading={isLoading}
            />
          </div>
        </div>
      )}
    </div>
  );
}

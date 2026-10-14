import { useEffect, useMemo, useRef, useState } from 'react';
import OrgChart from 'balkan-orgchart-js-community';
import { useUnits } from '../dashboard/hooks.js';
import { useOrgChartByUnit } from './hooks.js';
import Input from '../../components/ui/Input.jsx';

function buildNodes(unit, directory, functions) {
  if (!unit) return [];

  const rootId = unit.id;

  const functionMap = new Map();
  const militaryMap = new Map();

  directory.forEach((m) => {
    militaryMap.set(m.id, m);
  });

  functions.forEach((f) => {
    const list = functionMap.get(f.function_id) ?? [];
    list.push(f.military_id);
    functionMap.set(f.function_id, list);
  });

  const nodes = [
    {
      id: rootId,
      name: unit.acronym,
      title: unit.name,
      tags: ['unit'],
    },
  ];

  functionMap.forEach((militaryIds, functionId) => {
    const sample = functions.find((f) => f.function_id === functionId);
    if (!sample) return;

    const members = militaryIds
      .map((id) => militaryMap.get(id))
      .filter(Boolean)
      .map((m) => `${m.rank_code ? m.rank_code.toUpperCase() : ''} ${m.war_name}`);

    nodes.push({
      id: `fn-${functionId}`,
      pid: rootId,
      name: sample.function_name,
      title: members.join('\n'),
      tags: ['function', sample.is_operational ? 'operational' : 'administrative'],
    });
  });

  return nodes;
}

export default function MilitaryOrgChart() {
  const [selectedUnitId, setSelectedUnitId] = useState('');
  const chartContainerRef = useRef(null);
  const chartRef = useRef(null);

  const {
    data: units,
    isLoading: isLoadingUnits,
  } = useUnits();

  useEffect(() => {
    if (!selectedUnitId && units && units.length > 0) {
      setSelectedUnitId(units[0].id);
    }
  }, [units, selectedUnitId]);

  const activeUnit = useMemo(
    () => units?.find((u) => u.id === selectedUnitId) ?? null,
    [units, selectedUnitId],
  );

  const {
    data,
    isLoading: isLoadingData,
  } = useOrgChartByUnit(selectedUnitId || null);

  useEffect(() => {
    if (!chartContainerRef.current || !activeUnit) return;

    const nodes = buildNodes(activeUnit, data?.directory ?? [], data?.functions ?? []);

    if (!chartRef.current) {
      chartRef.current = new OrgChart(chartContainerRef.current, {
        mouseScroll: OrgChart.action.scroll,
        nodeBinding: {
          field_0: 'name',
          field_1: 'title',
        },
        enableDragDrop: false,
        template: 'ula',
        tags: {
          unit: {
            template: 'ula',
          },
          function: {
            template: 'isla',
          },
          operational: {
            node: {
              borderColor: '#0284c7',
            },
          },
          administrative: {
            node: {
              borderColor: '#64748b',
            },
          },
        },
      });
    }

    chartRef.current.load(nodes);
  }, [activeUnit, data]);

  return (
    <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm">
      <div className="flex flex-col justify-between gap-2 md:flex-row md:items-center">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Organograma por funções
          </div>
          <p className="text-xs text-muted-foreground">
            Visualização das funções da unidade e dos militares vinculados a cada função.
          </p>
        </div>
        <div className="flex flex-col gap-2 md:flex-row md:items-center">
          <div className="space-y-1">
            <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
              Unidade
            </span>
            <select
              className="h-9 min-w-[220px] rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              value={selectedUnitId}
              onChange={(e) => setSelectedUnitId(e.target.value)}
              disabled={isLoadingUnits}
            >
              <option value="">Selecione uma unidade</option>
              {units?.map((unit) => (
                <option key={unit.id} value={unit.id}>
                  {unit.acronym} — {unit.name}
                </option>
              ))}
            </select>
          </div>
          {activeUnit && (
            <Input
              readOnly
              className="h-9 w-full max-w-xs text-xs text-muted-foreground"
              value={activeUnit.id}
            />
          )}
        </div>
      </div>

      {isLoadingData && (
        <div className="h-64 animate-pulse rounded-md bg-muted" />
      )}

      {!isLoadingData && (!data || (data.directory ?? []).length === 0) && (
        <div className="rounded-md border border-dashed border-muted bg-muted/40 px-3 py-4 text-xs text-muted-foreground">
          Nenhum militar com função cadastrada para esta unidade ainda.
        </div>
      )}

      <div
        ref={chartContainerRef}
        className="mt-2 h-[420px] w-full overflow-hidden rounded-md border bg-background"
      />
    </div>
  );
}

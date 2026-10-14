import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useMilitaryOrder() {
  return useQuery({
    queryKey: ['military-order-admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('v_military_order_admin')
        .select('id, full_name, war_name, rank_code, rank_name, intra_rank_order, rank_sort_order')
        .order('rank_sort_order', { ascending: true })
        .order('intra_rank_order', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function MilitaryOrderAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: rows = [], isLoading, error } = useMilitaryOrder();
  const [draggingId, setDraggingId] = useState(null);

  const byRank = useMemo(() => {
    const grouped = new Map();
    for (const row of rows) {
      const key = row.rank_code || 'SEM_POSTO';
      if (!grouped.has(key)) {
        grouped.set(key, []);
      }
      grouped.get(key).push(row);
    }
    return Array.from(grouped.entries());
  }, [rows]);

  const updateOrderMutation = useMutation({
    mutationFn: async ({ aId, bId }) => {
      const { error } = await supabase.rpc('swap_military_intra_rank_order', {
        p_military_id_a: aId,
        p_military_id_b: bId,
      });
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['military-order-admin'] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
    },
  });

  async function handleSwap(a, b) {
    if (!canEdit || !a || !b) return;
    try {
      await updateOrderMutation.mutateAsync({ aId: a.id, bId: b.id });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar a ordem dos militares.');
      } else {
        toast.error(err?.message || 'Não foi possível alterar a ordem dos militares.');
      }
    }
  }

  function handleDropAbove(target, dropped) {
    if (!target || !dropped || target.id === dropped.id) return;
    if (target.rank_code !== dropped.rank_code) {
      toast.error('Só é possível reordenar entre militares do mesmo posto/graduação.');
      return;
    }
    const targetIndex = target.intra_rank_order ?? 0;
    const droppedIndex = dropped.intra_rank_order ?? 0;
    if (droppedIndex === targetIndex - 1) return; // já está logo acima
    handleSwap(target, dropped);
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Ordem de militares por posto/graduação
          </div>
          <div className="text-xs text-muted-foreground">
            Arraste os militares dentro de cada posto para definir a ordem de apresentação na tela Militares.
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de militares para ordenação.
        </div>
      )}

      <div className="max-h-96 space-y-3 overflow-auto rounded-md bg-muted/40 p-2 text-xs">
        {isLoading && <div className="px-2 py-1 text-xs text-muted-foreground">Carregando...</div>}
        {!isLoading && rows.length === 0 && (
          <div className="px-2 py-1 text-xs text-muted-foreground">Nenhum militar encontrado.</div>
        )}

        {!isLoading && rows.length > 0 && (
          <div className="space-y-3">
            {byRank.map(([rankCode, list]) => (
              <div key={rankCode} className="rounded-md border bg-background">
                <div className="flex items-center justify-between border-b px-3 py-1.5">
                  <span className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                    {list[0]?.rank_name || rankCode || 'Sem posto definido'}
                  </span>
                  <span className="text-[11px] text-muted-foreground">{list.length} militar(es)</span>
                </div>
                <ul className="divide-y">
                  {list.map((row, index) => (
                    <li
                      key={row.id}
                      draggable={canEdit}
                      onDragStart={() => setDraggingId(row.id)}
                      onDragEnd={() => setDraggingId(null)}
                      onDragOver={(e) => {
                        if (!canEdit) return;
                        e.preventDefault();
                      }}
                      onDrop={(e) => {
                        if (!canEdit) return;
                        e.preventDefault();
                        const dropped = list.find((r) => r.id === draggingId);
                        if (!dropped) return;
                        handleDropAbove(row, dropped);
                      }}
                      className={`flex items-center justify-between px-3 py-1.5 text-xs ${
                        draggingId === row.id ? 'bg-emerald-50' : 'bg-transparent'
                      }`}
                    >
                      <div className="flex flex-col">
                        <span className="font-medium">{row.war_name || row.full_name}</span>
                        <span className="text-[11px] text-muted-foreground">{row.full_name}</span>
                      </div>
                      {canEdit && (
                        <div className="flex items-center gap-1">
                          <Button
                            type="button"
                            size="icon"
                            variant="ghost"
                            disabled={index === 0 || updateOrderMutation.isPending}
                            onClick={() => handleSwap(row, list[index - 1])}
                            className="h-6 w-6 px-0 text-[11px]"
                          >
                            ↑
                          </Button>
                          <Button
                            type="button"
                            size="icon"
                            variant="ghost"
                            disabled={index === list.length - 1 || updateOrderMutation.isPending}
                            onClick={() => handleSwap(row, list[index + 1])}
                            className="h-6 w-6 px-0 text-[11px]"
                          >
                            ↓
                          </Button>
                        </div>
                      )}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

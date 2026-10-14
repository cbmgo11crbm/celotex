import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useVehicleStatuses() {
  return useQuery({
    queryKey: ['vehicle-statuses', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('vehicle_statuses')
        .select('id, code, name, sort_order, is_active')
        .order('sort_order', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function VehicleStatusesAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: statuses = [], isLoading, error } = useVehicleStatuses();

  const [code, setCode] = useState('');
  const [name, setName] = useState('');
  const [sortOrder, setSortOrder] = useState('10');

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('vehicle_statuses').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-statuses'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-statuses', 'admin'] });
      toast.success('Situação de viatura criada com sucesso.');
      setCode('');
      setName('');
      setSortOrder('10');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('vehicle_statuses')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-statuses'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-statuses', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: delError } = await supabase
        .from('vehicle_statuses')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-statuses'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-statuses', 'admin'] });
      toast.success('Situação de viatura excluída com sucesso.');
    },
  });

  const isBusy = createMutation.isPending || toggleActiveMutation.isPending || deleteMutation.isPending;

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;

    if (!code.trim() || !name.trim()) {
      toast.error('Informe o código e o nome da situação da viatura.');
      return;
    }

    const so = Number.parseInt(sortOrder, 10) || 10;

    try {
      await createMutation.mutateAsync({
        code: code.trim().toLowerCase(),
        name: name.trim(),
        sort_order: so,
        is_active: true,
      });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as situações de viaturas.');
      } else {
        toast.error(err?.message || 'Erro ao criar situação de viatura.');
      }
    }
  }

  async function handleToggleActive(st) {
    if (!canEdit) return;
    try {
      await toggleActiveMutation.mutateAsync({ id: st.id, isActive: !st.is_active });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as situações de viaturas.');
      } else {
        toast.error(err?.message || 'Erro ao atualizar situação de viatura.');
      }
    }
  }

  async function handleDelete(st) {
    if (!canEdit) return;
    const ok = window.confirm(
      `Excluir a situação de viatura "${st.name}"? Esta ação não poderá ser desfeita e poderá impactar relatórios.`,
    );
    if (!ok) return;

    try {
      await deleteMutation.mutateAsync(st.id);
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para excluir situações de viaturas.');
      } else if (err?.code === '23503') {
        toast.error('Não é possível excluir: existem viaturas vinculadas a esta situação.');
      } else {
        toast.error(err?.message || 'Erro ao excluir situação de viatura.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Situação da viatura
          </div>
          <div className="text-xs text-muted-foreground">
            Situações operacionais da viatura (ativa, baixada, cautelada, etc.).
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar as situações de viaturas.
        </div>
      )}

      <div className="max-h-64 overflow-auto rounded-md border bg-muted/40">
        {isLoading && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Carregando...</div>
        )}
        {!isLoading && statuses.length === 0 && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Nenhuma situação cadastrada.</div>
        )}
        {!isLoading && statuses.length > 0 && (
          <table className="w-full text-xs">
            <thead className="bg-muted text-[11px] uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-2 py-1 text-left">Código</th>
                <th className="px-2 py-1 text-left">Nome</th>
                <th className="px-2 py-1 text-left">Ordem</th>
                <th className="px-2 py-1 text-right">Status</th>
                {canEdit && <th className="px-2 py-1 text-right">Ações</th>}
              </tr>
            </thead>
            <tbody className="divide-y">
              {statuses.map((st) => (
                <tr key={st.id} className="hover:bg-muted/60">
                  <td className="px-2 py-1 align-middle font-mono text-[11px]">{st.code}</td>
                  <td className="px-2 py-1 align-middle">{st.name}</td>
                  <td className="px-2 py-1 align-middle">{st.sort_order}</td>
                  <td className="px-2 py-1 align-middle text-right text-[11px] text-muted-foreground">
                    {st.is_active ? 'Ativo' : 'Inativo'}
                  </td>
                  {canEdit && (
                    <td className="px-2 py-1 align-middle text-right">
                      <button
                        type="button"
                        className="mr-2 text-[11px] text-emerald-700 hover:underline disabled:opacity-60"
                        disabled={isBusy}
                        onClick={() => handleToggleActive(st)}
                      >
                        {st.is_active ? 'Desativar' : 'Ativar'}
                      </button>
                      <button
                        type="button"
                        className="text-[11px] text-red-700 hover:underline disabled:opacity-60"
                        disabled={isBusy}
                        onClick={() => handleDelete(st)}
                      >
                        Excluir
                      </button>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {canEdit && (
        <form onSubmit={handleCreate} className="space-y-2 text-xs">
          <div className="grid grid-cols-[1fr_2fr_1fr] gap-2">
            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Código</span>
              <Input
                value={code}
                onChange={(e) => setCode(e.target.value)}
                placeholder="Ex: ativo, baixado, cautelado..."
              />
            </div>
            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Nome</span>
              <Input
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Ex: Ativo, Baixado, Cautelado..."
              />
            </div>
            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Ordem</span>
              <Input
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value)}
                placeholder="Ex: 10"
              />
            </div>
          </div>
          <div className="flex justify-end">
            <Button type="submit" size="sm" disabled={isBusy}>
              Adicionar situação
            </Button>
          </div>
        </form>
      )}
    </div>
  );
}

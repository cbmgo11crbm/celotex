import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useVehicleConservationStates() {
  return useQuery({
    queryKey: ['vehicle-conservation-states', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('vehicle_conservation_states')
        .select('id, code, name, sort_order, is_active')
        .order('sort_order', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function VehicleConservationStatesAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: states = [], isLoading, error } = useVehicleConservationStates();

  const [code, setCode] = useState('');
  const [name, setName] = useState('');
  const [sortOrder, setSortOrder] = useState('10');
  const [editingId, setEditingId] = useState(null);

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('vehicle_conservation_states').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states', 'admin'] });
      toast.success('Estado de conservação criado com sucesso.');
      setCode('');
      setName('');
      setSortOrder('10');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('vehicle_conservation_states')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states', 'admin'] });
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, values }) => {
      const { error: upError } = await supabase
        .from('vehicle_conservation_states')
        .update(values)
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states', 'admin'] });
      toast.success('Estado de conservação atualizado com sucesso.');
      setEditingId(null);
      setName('');
      setSortOrder('10');
      setCode('');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: delError } = await supabase
        .from('vehicle_conservation_states')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-conservation-states', 'admin'] });
      toast.success('Estado de conservação excluído com sucesso.');
    },
  });

  const isBusy =
    createMutation.isPending ||
    updateMutation.isPending ||
    toggleActiveMutation.isPending ||
    deleteMutation.isPending;

  async function handleSubmit(e) {
    e.preventDefault();
    if (!canEdit) return;

    if (!name.trim()) {
      toast.error('Informe o nome do estado de conservação.');
      return;
    }

    const so = Number.parseInt(sortOrder, 10) || 10;

    try {
      if (editingId) {
        await updateMutation.mutateAsync({
          id: editingId,
          values: { name: name.trim(), sort_order: so },
        });
      } else {
        if (!code.trim()) {
          toast.error('Informe o código do estado de conservação.');
          return;
        }
        await createMutation.mutateAsync({
          code: code.trim().toLowerCase(),
          name: name.trim(),
          sort_order: so,
          is_active: true,
        });
      }
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar os estados de conservação.');
      } else {
        toast.error(err?.message || 'Erro ao salvar estado de conservação.');
      }
    }
  }

  function handleEdit(st) {
    setEditingId(st.id);
    setCode(st.code);
    setName(st.name);
    setSortOrder(String(st.sort_order));
  }

  async function handleToggleActive(st) {
    if (!canEdit) return;
    try {
      await toggleActiveMutation.mutateAsync({ id: st.id, isActive: !st.is_active });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar os estados de conservação.');
      } else {
        toast.error(err?.message || 'Erro ao atualizar estado de conservação.');
      }
    }
  }

  async function handleDelete(st) {
    if (!canEdit) return;
    const ok = window.confirm(
      `Excluir o estado de conservação "${st.name}"? Esta ação não poderá ser desfeita e poderá impactar relatórios.`,
    );
    if (!ok) return;

    try {
      await deleteMutation.mutateAsync(st.id);
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para excluir estados de conservação.');
      } else if (err?.code === '23503') {
        toast.error('Não é possível excluir: existem viaturas ou equipamentos vinculados a este estado.');
      } else {
        toast.error(err?.message || 'Erro ao excluir estado de conservação.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Estado da viatura
          </div>
          <div className="text-xs text-muted-foreground">
            Tabela de estados de conservação da frota (novo, bom, regular, ...).
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar os estados de conservação.
        </div>
      )}

      <div className="max-h-64 overflow-auto rounded-md border bg-muted/40">
        {isLoading && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Carregando...</div>
        )}
        {!isLoading && states.length === 0 && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Nenhum estado cadastrado.</div>
        )}
        {!isLoading && states.length > 0 && (
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
              {states.map((st) => (
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
                        className="mr-2 text-[11px] text-blue-700 hover:underline disabled:opacity-60"
                        disabled={isBusy}
                        onClick={() => handleEdit(st)}
                      >
                        Editar
                      </button>
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
        <form onSubmit={handleSubmit} className="space-y-2 text-xs">
          <div className="grid grid-cols-[1fr_2fr_1fr] gap-2">
            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Código</span>
              <Input
                value={code}
                onChange={(e) => setCode(e.target.value)}
                placeholder="Ex: novo, bom, ruim..."
                disabled={editingId !== null}
              />
            </div>
            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Nome</span>
              <Input
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Ex: Novo, Bom, Ruim..."
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
          <div className="flex justify-end gap-2">
            {editingId && (
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => {
                  setEditingId(null);
                  setCode('');
                  setName('');
                  setSortOrder('10');
                }}
              >
                Cancelar
              </Button>
            )}
            <Button type="submit" size="sm" disabled={isBusy}>
              {editingId ? 'Salvar alterações' : 'Adicionar estado'}
            </Button>
          </div>
        </form>
      )}
    </div>
  );
}

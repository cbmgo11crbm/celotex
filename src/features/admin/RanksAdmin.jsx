import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useRanksAdmin() {
  return useQuery({
    queryKey: ['ranks', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('ranks')
        .select('id, code, name, sort_order, is_active')
        .order('sort_order', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function RanksAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: ranks = [], isLoading, error } = useRanksAdmin();

  const [code, setCode] = useState('');
  const [name, setName] = useState('');
  const [sortOrder, setSortOrder] = useState('');

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('ranks').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ranks'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'admin'] });
      toast.success('Posto/graduação criado com sucesso.');
      setCode('');
      setName('');
      setSortOrder('');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('ranks')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ranks'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: delError } = await supabase
        .from('ranks')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ranks'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'admin'] });
      toast.success('Posto/graduação excluído com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '23503') {
        toast.error('Existem militares vinculados a este posto/graduação. Não é possível excluir, apenas inativar.');
      } else if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir postos/graduações.');
      } else {
        toast.error(error?.message || 'Erro ao excluir posto/graduação.');
      }
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, code: newCode, name: newName, sort_order: newSort }) => {
      const payload = {
        code: newCode,
        name: newName,
        sort_order: newSort,
      };
      const { error: upError } = await supabase
        .from('ranks')
        .update(payload)
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ranks'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['ranks', 'admin'] });
      toast.success('Posto/graduação atualizado com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar postos/graduações.');
      } else {
        toast.error(error?.message || 'Erro ao atualizar posto/graduação.');
      }
    },
  });

  const isBusy =
    createMutation.isPending ||
    updateMutation.isPending ||
    toggleActiveMutation.isPending ||
    deleteMutation.isPending;

  async function handleEdit(rank) {
    if (!canEdit || isBusy) return;

    const newCode = window.prompt('Novo código do posto/graduação:', rank.code ?? '');
    if (newCode === null) return;
    const trimmedCode = newCode.trim();
    if (!trimmedCode) {
      toast.error('O código não pode ficar em branco.');
      return;
    }

    const newName = window.prompt('Novo nome do posto/graduação:', rank.name ?? '');
    if (newName === null) return;
    const trimmedName = newName.trim();
    if (!trimmedName) {
      toast.error('O nome não pode ficar em branco.');
      return;
    }

    const newSortStr = window.prompt('Nova ordem (número positivo):', String(rank.sort_order ?? ''));
    if (newSortStr === null) return;
    const newSort = Number(newSortStr);
    if (!Number.isFinite(newSort) || newSort <= 0) {
      toast.error('Informe uma ordem numérica positiva.');
      return;
    }

    if (
      trimmedCode === rank.code &&
      trimmedName === rank.name &&
      newSort === rank.sort_order
    ) {
      return; // nada mudou
    }

    try {
      await updateMutation.mutateAsync({
        id: rank.id,
        code: trimmedCode,
        name: trimmedName,
        sort_order: newSort,
      });
    } catch (err) {
      // erros tratados em onError
    }
  }

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;

    if (!code.trim() || !name.trim()) {
      toast.error('Informe o código e o nome do posto/graduação.');
      return;
    }

    const sort = sortOrder ? Number(sortOrder) : null;
    if (!sort || !Number.isFinite(sort) || sort <= 0) {
      toast.error('Informe uma ordem numérica positiva.');
      return;
    }

    try {
      await createMutation.mutateAsync({
        code: code.trim(),
        name: name.trim(),
        sort_order: sort,
        is_active: true,
      });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para criar postos/graduações.');
      } else {
        toast.error(err?.message || 'Erro ao criar posto/graduação.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Postos e graduações
          </div>
          <div className="text-xs text-muted-foreground">
            Catálogo de postos/graduações usados em militares e dashboards.
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar os postos/graduações.
        </div>
      )}

      {canEdit && (
        <form onSubmit={handleCreate} className="grid gap-2 md:grid-cols-[minmax(0,0.6fr)_minmax(0,1.4fr)_minmax(0,0.5fr)_auto] text-xs">
          <Input
            label="Código"
            value={code}
            onChange={(e) => setCode(e.target.value)}
            placeholder="Ex: Sd 2, Sd 1, Maj"
          />
          <Input
            label="Nome"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Nome completo"
          />
          <Input
            label="Ordem"
            type="number"
            value={sortOrder}
            onChange={(e) => setSortOrder(e.target.value)}
            placeholder="Ex: 14"
          />
          <div className="flex items-end">
            <Button type="submit" size="sm" disabled={isBusy} className="w-full md:w-auto">
              Adicionar
            </Button>
          </div>
        </form>
      )}

      <div className="max-h-80 space-y-1 overflow-auto rounded-md bg-muted/30 p-2 text-xs">
        {isLoading && <div className="px-2 py-1 text-xs text-muted-foreground">Carregando...</div>}
        {!isLoading && ranks.length === 0 && (
          <div className="px-2 py-1 text-xs text-muted-foreground">Nenhum posto/graduação cadastrado.</div>
        )}

        {!isLoading && ranks.length > 0 && (
          <table className="w-full border-collapse text-[11px]">
            <thead>
              <tr className="border-b bg-muted/60 text-left">
                <th className="px-2 py-1">Ordem</th>
                <th className="px-2 py-1">Código</th>
                <th className="px-2 py-1">Nome</th>
                <th className="px-2 py-1">Status</th>
                {canEdit && <th className="px-2 py-1 text-right">Ações</th>}
              </tr>
            </thead>
            <tbody>
              {ranks.map((rank) => (
                <tr key={rank.id} className="border-b last:border-0">
                  <td className="px-2 py-1">{rank.sort_order}</td>
                  <td className="px-2 py-1 font-medium">{rank.code}</td>
                  <td className="px-2 py-1">{rank.name}</td>
                  <td className="px-2 py-1">
                    {rank.is_active ? (
                      <span className="rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] text-emerald-700">
                        Ativo
                      </span>
                    ) : (
                      <span className="rounded-full bg-muted px-2 py-0.5 text-[10px] text-muted-foreground">
                        Inativo
                      </span>
                    )}
                  </td>
                  {canEdit && (
                    <td className="px-2 py-1 text-right">
                      <div className="flex items-center justify-end gap-1">
                        <Button
                          type="button"
                          size="xs"
                          variant="outline"
                          disabled={isBusy}
                          onClick={() => handleEdit(rank)}
                        >
                          Editar
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="outline"
                          disabled={isBusy}
                          onClick={() =>
                            toggleActiveMutation.mutate({
                              id: rank.id,
                              isActive: !rank.is_active,
                            })
                          }
                        >
                          {rank.is_active ? 'Inativar' : 'Ativar'}
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="ghost"
                          disabled={isBusy}
                          onClick={() => {
                            const confirmed = window.confirm(
                              'Excluir este posto/graduação? Se houver militares vinculados, a exclusão será bloqueada.',
                            );
                            if (!confirmed) return;
                            deleteMutation.mutate(rank.id);
                          }}
                          className="text-red-600 hover:text-red-700"
                        >
                          Excluir
                        </Button>
                      </div>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

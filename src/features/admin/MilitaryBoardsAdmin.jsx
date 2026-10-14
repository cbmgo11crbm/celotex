import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useMilitaryBoardsAdmin() {
  return useQuery({
    queryKey: ['military-boards', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('military_boards')
        .select('id, code, name, sort_order, is_active')
        .order('sort_order', { ascending: true })
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function MilitaryBoardsAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: boards = [], isLoading, error } = useMilitaryBoardsAdmin();

  const [code, setCode] = useState('');
  const [name, setName] = useState('');

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('military_boards').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['military-boards'] });
      queryClient.invalidateQueries({ queryKey: ['military-boards', 'admin'] });
      toast.success('Quadro criado com sucesso.');
      setCode('');
      setName('');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('military_boards')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['military-boards'] });
      queryClient.invalidateQueries({ queryKey: ['military-boards', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: delError } = await supabase
        .from('military_boards')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['military-boards'] });
      queryClient.invalidateQueries({ queryKey: ['military-boards', 'admin'] });
      toast.success('Quadro excluído com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '23503') {
        toast.error('Há militares vinculados a este quadro; não é possível excluir, apenas inativar.');
      } else if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir quadros.');
      } else {
        toast.error(error?.message || 'Erro ao excluir quadro.');
      }
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, code: newCode, name: newName }) => {
      const payload = {
        code: newCode,
        name: newName,
      };
      const { error: upError } = await supabase
        .from('military_boards')
        .update(payload)
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['military-boards'] });
      queryClient.invalidateQueries({ queryKey: ['military-boards', 'admin'] });
      toast.success('Quadro atualizado com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar quadros.');
      } else {
        toast.error(error?.message || 'Erro ao atualizar quadro.');
      }
    },
  });

  const isBusy =
    createMutation.isPending ||
    updateMutation.isPending ||
    toggleActiveMutation.isPending ||
    deleteMutation.isPending;

  async function handleEdit(board) {
    if (!canEdit || isBusy) return;

    const newCode = window.prompt('Novo código do quadro:', board.code ?? '');
    if (newCode === null) return;
    const trimmedCode = newCode.trim();
    if (!trimmedCode) {
      toast.error('O código do quadro não pode ficar em branco.');
      return;
    }

    const newName = window.prompt('Novo nome do quadro:', board.name ?? '');
    if (newName === null) return;
    const trimmedName = newName.trim();
    if (!trimmedName) {
      toast.error('O nome do quadro não pode ficar em branco.');
      return;
    }

    if (trimmedCode === board.code && trimmedName === board.name) return;

    try {
      await updateMutation.mutateAsync({ id: board.id, code: trimmedCode, name: trimmedName });
    } catch (err) {
      // erros tratados em onError
    }
  }

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;

    if (!code.trim() || !name.trim()) {
      toast.error('Informe o código e o nome do quadro.');
      return;
    }

    const sortOrder = (boards?.length || 0) + 1;

    try {
      await createMutation.mutateAsync({
        code: code.trim(),
        name: name.trim(),
        sort_order: sortOrder,
        is_active: true,
      });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para criar quadros.');
      } else if (err?.code === '23505') {
        toast.error('Já existe um quadro com este código.');
      } else {
        toast.error(err?.message || 'Erro ao criar quadro.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Quadros
          </div>
          <div className="text-xs text-muted-foreground">
            Cadastro de quadros (combatente, saúde, administração, etc.).
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de quadros.
        </div>
      )}

      {canEdit && (
        <form
          onSubmit={handleCreate}
          className="grid gap-2 md:grid-cols-[minmax(0,0.4fr)_minmax(0,1.2fr)_auto] text-xs"
        >
          <Input
            label="Código"
            value={code}
            onChange={(e) => setCode(e.target.value)}
            placeholder="Ex: QP/COMBATENTE"
          />
          <Input
            label="Nome"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Nome descritivo do quadro"
          />
          <div className="flex items-end">
            <Button
              type="submit"
              size="sm"
              disabled={isBusy}
              className="w-full md:w-auto"
            >
              Adicionar
            </Button>
          </div>
        </form>
      )}

      <div className="max-h-80 space-y-1 overflow-auto rounded-md bg-muted/30 p-2 text-xs">
        {isLoading && <div className="px-2 py-1 text-xs text-muted-foreground">Carregando...</div>}
        {!isLoading && boards.length === 0 && (
          <div className="px-2 py-1 text-xs text-muted-foreground">Nenhum quadro cadastrado.</div>
        )}

        {!isLoading && boards.length > 0 && (
          <table className="w-full border-collapse text-[11px]">
            <thead>
              <tr className="border-b bg-muted/60 text-left">
                <th className="px-2 py-1">Código</th>
                <th className="px-2 py-1">Nome</th>
                <th className="px-2 py-1">Status</th>
                {canEdit && <th className="px-2 py-1 text-right">Ações</th>}
              </tr>
            </thead>
            <tbody>
              {boards.map((board) => (
                <tr key={board.id} className="border-b last:border-0">
                  <td className="px-2 py-1 font-medium">{board.code}</td>
                  <td className="px-2 py-1">{board.name}</td>
                  <td className="px-2 py-1">
                    {board.is_active ? (
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
                          onClick={() => handleEdit(board)}
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
                              id: board.id,
                              isActive: !board.is_active,
                            })
                          }
                        >
                          {board.is_active ? 'Inativar' : 'Ativar'}
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="ghost"
                          disabled={isBusy}
                          onClick={() => {
                            const confirmed = window.confirm(
                              'Excluir este quadro? Se houver vínculos, a exclusão será bloqueada.',
                            );
                            if (!confirmed) return;
                            deleteMutation.mutate(board.id);
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

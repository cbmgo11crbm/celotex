import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useUnitsAdmin() {
  return useQuery({
    queryKey: ['units', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('units')
        .select('id, acronym, name, is_active')
        .order('acronym', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function UnitsAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: units = [], isLoading, error } = useUnitsAdmin();

  const [acronym, setAcronym] = useState('');
  const [name, setName] = useState('');

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('units').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['units'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'select-all-active'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'admin'] });
      toast.success('Unidade criada com sucesso.');
      setAcronym('');
      setName('');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('units')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['units'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'select-all-active'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: delError } = await supabase
        .from('units')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['units'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'select-all-active'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'admin'] });
      toast.success('Unidade excluída com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '23503') {
        toast.error('Há militares/viaturas/equipamentos vinculados; não é possível excluir, apenas inativar.');
      } else if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir unidades.');
      } else {
        toast.error(error?.message || 'Erro ao excluir unidade.');
      }
    },
  });
  const updateMutation = useMutation({
    mutationFn: async ({ id, acronym: newAcronym, name: newName }) => {
      const payload = {
        acronym: newAcronym,
        name: newName,
      };
      const { error: upError } = await supabase
        .from('units')
        .update(payload)
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['units'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'select-all-active'] });
      queryClient.invalidateQueries({ queryKey: ['units', 'admin'] });
      toast.success('Unidade atualizada com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar unidades.');
      } else {
        toast.error(error?.message || 'Erro ao atualizar unidade.');
      }
    },
  });

  const isBusy =
    createMutation.isPending ||
    updateMutation.isPending ||
    toggleActiveMutation.isPending ||
    deleteMutation.isPending;

  async function handleEdit(unit) {
    if (!canEdit || isBusy) return;

    const newAcr = window.prompt('Novo acrônimo da unidade:', unit.acronym ?? '');
    if (newAcr === null) return;
    const trimmedAcr = newAcr.trim();
    if (!trimmedAcr) {
      toast.error('O acrônimo não pode ficar em branco.');
      return;
    }

    const newName = window.prompt('Novo nome da unidade:', unit.name ?? '');
    if (newName === null) return;
    const trimmedName = newName.trim();
    if (!trimmedName) {
      toast.error('O nome da unidade não pode ficar em branco.');
      return;
    }

    if (trimmedAcr === unit.acronym && trimmedName === unit.name) return; // nada mudou

    try {
      await updateMutation.mutateAsync({ id: unit.id, acronym: trimmedAcr, name: trimmedName });
    } catch (err) {
      // erros já tratados em onError
    }
  }

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;

    if (!acronym.trim() || !name.trim()) {
      toast.error('Informe o acrônimo e o nome da unidade.');
      return;
    }

    try {
      await createMutation.mutateAsync({
        acronym: acronym.trim(),
        name: name.trim(),
        is_active: true,
      });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para criar unidades.');
      } else {
        toast.error(err?.message || 'Erro ao criar unidade.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Unidades
          </div>
          <div className="text-xs text-muted-foreground">
            Cadastro das unidades às quais militares, viaturas e equipamentos podem ser vinculados.
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de unidades.
        </div>
      )}

      {canEdit && (
        <form onSubmit={handleCreate} className="grid gap-2 md:grid-cols-[minmax(0,0.4fr)_minmax(0,1.2fr)_auto] text-xs">
          <Input
            label="Acrônimo"
            value={acronym}
            onChange={(e) => setAcronym(e.target.value)}
            placeholder="EX: 11º BBM"
          />
          <Input
            label="Nome"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Nome completo da unidade"
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
        {!isLoading && units.length === 0 && (
          <div className="px-2 py-1 text-xs text-muted-foreground">Nenhuma unidade cadastrada.</div>
        )}

        {!isLoading && units.length > 0 && (
          <table className="w-full border-collapse text-[11px]">
            <thead>
              <tr className="border-b bg-muted/60 text-left">
                <th className="px-2 py-1">Acrônimo</th>
                <th className="px-2 py-1">Nome</th>
                <th className="px-2 py-1">Status</th>
                {canEdit && <th className="px-2 py-1 text-right">Ações</th>}
              </tr>
            </thead>
            <tbody>
              {units.map((unit) => (
                <tr key={unit.id} className="border-b last:border-0">
                  <td className="px-2 py-1 font-medium">{unit.acronym}</td>
                  <td className="px-2 py-1">{unit.name}</td>
                  <td className="px-2 py-1">
                    {unit.is_active ? (
                      <span className="rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] text-emerald-700">
                        Ativa
                      </span>
                    ) : (
                      <span className="rounded-full bg-muted px-2 py-0.5 text-[10px] text-muted-foreground">
                        Inativa
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
                          onClick={() => handleEdit(unit)}
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
                              id: unit.id,
                              isActive: !unit.is_active,
                            })
                          }
                        >
                          {unit.is_active ? 'Inativar' : 'Ativar'}
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="ghost"
                          disabled={isBusy}
                          onClick={() => {
                            const confirmed = window.confirm(
                              'Excluir esta unidade? Se houver vínculos, a exclusão será bloqueada.',
                            );
                            if (!confirmed) return;
                            deleteMutation.mutate(unit.id);
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

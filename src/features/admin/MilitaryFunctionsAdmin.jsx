import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useFunctionsAdmin() {
  return useQuery({
    queryKey: ['functions', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('functions')
        .select('id, name, description, is_operational, is_active')
        .order('is_operational', { ascending: false })
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function MilitaryFunctionsAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: functions = [], isLoading, error } = useFunctionsAdmin();

  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [isOperational, setIsOperational] = useState(false);

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('functions').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['functions'] });
      queryClient.invalidateQueries({ queryKey: ['functions', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['functions', 'admin'] });
      toast.success('Função de militar criada com sucesso.');
      setName('');
      setDescription('');
      setIsOperational(false);
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('functions')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['functions'] });
      queryClient.invalidateQueries({ queryKey: ['functions', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['functions', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: relError } = await supabase
        .from('military_functions')
        .delete()
        .eq('function_id', id);
      if (relError) throw relError;

      const { error: delError } = await supabase
        .from('functions')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['functions'] });
      queryClient.invalidateQueries({ queryKey: ['functions', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['functions', 'admin'] });
      toast.success('Função de militar excluída com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir funções de militares.');
      } else {
        toast.error(error?.message || 'Erro ao excluir função de militar.');
      }
    },
  });

  const isBusy = createMutation.isPending || toggleActiveMutation.isPending || deleteMutation.isPending;

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;

    if (!name.trim()) {
      toast.error('Informe o nome da função.');
      return;
    }

    try {
      await createMutation.mutateAsync({
        name: name.trim(),
        description: description.trim() || null,
        is_operational: isOperational,
        is_active: true,
      });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para criar funções de militares.');
      } else {
        toast.error(err?.message || 'Erro ao criar função de militar.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Funções de militares
          </div>
          <div className="text-xs text-muted-foreground">
            Funções/cargos que podem ser vinculados aos militares.
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar as funções de militares.
        </div>
      )}

      {canEdit && (
        <form onSubmit={handleCreate} className="grid gap-2 md:grid-cols-[minmax(0,1.2fr)_minmax(0,1.8fr)_minmax(0,0.6fr)] text-xs">
          <Input
            label="Nome"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Ex: Comandante de Guarnição"
          />
          <Input
            label="Descrição (opcional)"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Detalhes da função"
          />
          <div className="flex flex-col justify-end gap-1">
            <label className="flex items-center gap-2 text-[11px] text-muted-foreground">
              <input
                type="checkbox"
                checked={isOperational}
                onChange={(e) => setIsOperational(e.target.checked)}
              />
              Operacional
            </label>
            <Button type="submit" size="sm" disabled={isBusy} className="w-full">
              Adicionar
            </Button>
          </div>
        </form>
      )}

      <div className="max-h-80 space-y-1 overflow-auto rounded-md bg-muted/30 p-2 text-xs">
        {isLoading && <div className="px-2 py-1 text-xs text-muted-foreground">Carregando...</div>}
        {!isLoading && functions.length === 0 && (
          <div className="px-2 py-1 text-xs text-muted-foreground">Nenhuma função cadastrada.</div>
        )}

        {!isLoading && functions.length > 0 && (
          <table className="w-full border-collapse text-[11px]">
            <thead>
              <tr className="border-b bg-muted/60 text-left">
                <th className="px-2 py-1">Nome</th>
                <th className="px-2 py-1">Descrição</th>
                <th className="px-2 py-1">Tipo</th>
                <th className="px-2 py-1">Status</th>
                {canEdit && <th className="px-2 py-1 text-right">Ações</th>}
              </tr>
            </thead>
            <tbody>
              {functions.map((fn) => (
                <tr key={fn.id} className="border-b last:border-0">
                  <td className="px-2 py-1 font-medium">{fn.name}</td>
                  <td className="px-2 py-1 text-[10px] text-muted-foreground">{fn.description}</td>
                  <td className="px-2 py-1 text-[10px]">{fn.is_operational ? 'Operacional' : 'Administrativa'}</td>
                  <td className="px-2 py-1">
                    {fn.is_active ? (
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
                          onClick={() =>
                            toggleActiveMutation.mutate({
                              id: fn.id,
                              isActive: !fn.is_active,
                            })
                          }
                        >
                          {fn.is_active ? 'Inativar' : 'Ativar'}
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="ghost"
                          disabled={isBusy}
                          onClick={() => {
                            const confirmed = window.confirm(
                              'Excluir esta função? Os vínculos com militares serão removidos.',
                            );
                            if (!confirmed) return;
                            deleteMutation.mutate(fn.id);
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

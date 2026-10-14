import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useVehicleFunctions() {
  return useQuery({
    queryKey: ['vehicle-functions', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('vehicle_functions')
        .select('id, name, is_active, color_hex')
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function VehicleFunctionsAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: functions = [], isLoading, error } = useVehicleFunctions();

  const [name, setName] = useState('');
  const [color, setColor] = useState('#059669');

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('vehicle_functions').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions', 'admin'] });
      toast.success('Função de viatura criada com sucesso.');
      setName('');
      setColor('#059669');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('vehicle_functions')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions', 'admin'] });
    },
  });

  const updateColorMutation = useMutation({
    mutationFn: async ({ id, colorHex }) => {
      const { error: upError } = await supabase
        .from('vehicle_functions')
        .update({ color_hex: colorHex })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: relError } = await supabase
        .from('vehicle_vehicle_functions')
        .delete()
        .eq('function_id', id);
      if (relError) throw relError;

      const { error: delError } = await supabase
        .from('vehicle_functions')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions', 'admin'] });
      toast.success('Função de viatura excluída com sucesso.');
    },
  });

  const isBusy =
    createMutation.isPending || toggleActiveMutation.isPending || updateColorMutation.isPending || deleteMutation.isPending;

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;
    if (!name.trim()) {
      toast.error('Informe o nome da função.');
      return;
    }

    try {
      await createMutation.mutateAsync({ name: name.trim(), is_active: true, color_hex: color || null });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as funções de viaturas.');
      } else {
        toast.error(err?.message || 'Erro ao criar função de viatura.');
      }
    }
  }

  async function handleChangeColor(fn, newColor) {
    if (!canEdit) return;
    try {
      await updateColorMutation.mutateAsync({ id: fn.id, colorHex: newColor });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as funções de viaturas.');
      } else {
        toast.error(err?.message || 'Erro ao atualizar a cor da função de viatura.');
      }
    }
  }

  async function handleDelete(fn) {
    if (!canEdit) return;
    const ok = window.confirm(
      `Remover a função "${fn.name}" de todas as viaturas? Esta ação não poderá ser desfeita.`,
    );
    if (!ok) return;

    try {
      await deleteMutation.mutateAsync(fn.id);
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para excluir as funções de viaturas.');
      } else {
        toast.error(err?.message || 'Erro ao excluir função de viatura.');
      }
    }
  }

  async function handleToggleActive(fn) {
    if (!canEdit) return;
    try {
      await toggleActiveMutation.mutateAsync({ id: fn.id, isActive: !fn.is_active });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as funções de viaturas.');
      } else {
        toast.error(err?.message || 'Erro ao atualizar função de viatura.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Funções de viaturas
          </div>
          <div className="text-xs text-muted-foreground">
            Controle das funções que podem ser vinculadas às viaturas.
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar as funções de viaturas.
        </div>
      )}

      <div className="max-h-64 overflow-auto rounded-md border bg-muted/40">
        {isLoading && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Carregando...</div>
        )}
        {!isLoading && functions.length === 0 && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Nenhuma função cadastrada.</div>
        )}
        {!isLoading && functions.length > 0 && (
          <ul className="divide-y text-xs">
            {functions.map((fn) => (
              <li key={fn.id} className="flex items-center justify-between px-3 py-1.5">
                <div className="flex items-center gap-2">
                  <span className={fn.is_active ? '' : 'text-muted-foreground line-through'}>{fn.name}</span>
                  <input
                    type="color"
                    value={fn.color_hex || '#059669'}
                    onChange={(e) => handleChangeColor(fn, e.target.value)}
                    disabled={!canEdit || isBusy}
                    className="h-5 w-8 cursor-pointer border border-muted bg-background p-0"
                  />
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[11px] text-muted-foreground">
                    {fn.is_active ? 'Ativa' : 'Inativa'}
                  </span>
                  {canEdit && (
                    <>
                      <button
                        type="button"
                        className="text-[11px] text-emerald-700 hover:underline disabled:opacity-60"
                        disabled={isBusy}
                        onClick={() => handleToggleActive(fn)}
                      >
                        {fn.is_active ? 'Desativar' : 'Ativar'}
                      </button>
                      <button
                        type="button"
                        className="text-[11px] text-red-700 hover:underline disabled:opacity-60"
                        disabled={isBusy}
                        onClick={() => handleDelete(fn)}
                      >
                        Excluir
                      </button>
                    </>
                  )}
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      {canEdit && (
        <form onSubmit={handleCreate} className="space-y-2 text-xs">
          <div className="space-y-1">
            <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Nova função</span>
            <Input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Ex: Resgate, Salvamento, Incêndio Urbano..."
            />
            <div className="flex items-center gap-2 pt-1">
              <span className="text-[11px] text-muted-foreground">Cor:</span>
              <input
                type="color"
                value={color}
                onChange={(e) => setColor(e.target.value)}
                className="h-6 w-10 cursor-pointer border border-muted bg-background p-0"
              />
            </div>
          </div>
          <div className="flex justify-end">
            <Button type="submit" size="sm" disabled={isBusy}>
              Adicionar função
            </Button>
          </div>
        </form>
      )}
    </div>
  );
}

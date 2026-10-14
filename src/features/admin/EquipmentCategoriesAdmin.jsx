import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useEquipmentCategoriesAdmin() {
  return useQuery({
    queryKey: ['equipment-categories', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('equipment_categories')
        .select('id, name, is_active, color_hex')
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function EquipmentCategoriesAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: categories = [], isLoading, error } = useEquipmentCategoriesAdmin();

  const [name, setName] = useState('');
  const [color, setColor] = useState('#0ea5e9');

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('equipment_categories').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['equipment-categories'] });
      queryClient.invalidateQueries({ queryKey: ['equipment-categories', 'admin'] });
      toast.success('Categoria de equipamento criada com sucesso.');
      setName('');
      setColor('#0ea5e9');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('equipment_categories')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['equipment-categories'] });
      queryClient.invalidateQueries({ queryKey: ['equipment-categories', 'admin'] });
    },
  });

  const updateColorMutation = useMutation({
    mutationFn: async ({ id, colorHex }) => {
      const { error: upError } = await supabase
        .from('equipment_categories')
        .update({ color_hex: colorHex })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['equipment-categories'] });
      queryClient.invalidateQueries({ queryKey: ['equipment-categories', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (catId) => {
      // Garante uma categoria fallback "Outros" para recategorização
      const fallbackName = 'Outros';

      const { data: existing, error: fetchError } = await supabase
        .from('equipment_categories')
        .select('id')
        .eq('name', fallbackName)
        .limit(1)
        .maybeSingle();

      if (fetchError) throw fetchError;

      let fallbackId = existing?.id;

      if (!fallbackId) {
        const { data: inserted, error: insertError } = await supabase
          .from('equipment_categories')
          .insert({ name: fallbackName, is_active: true })
          .select('id')
          .single();

        if (insertError) throw insertError;
        fallbackId = inserted.id;
      }

      const { error: updateError } = await supabase
        .from('equipment')
        .update({ category_id: fallbackId })
        .eq('category_id', catId);
      if (updateError) throw updateError;

      const { error: delError } = await supabase
        .from('equipment_categories')
        .delete()
        .eq('id', catId);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['equipment'] });
      queryClient.invalidateQueries({ queryKey: ['equipment-categories'] });
      queryClient.invalidateQueries({ queryKey: ['equipment-categories', 'admin'] });
      toast.success('Categoria de equipamento excluída com sucesso.');
    },
  });

  const isBusy =
    createMutation.isPending || toggleActiveMutation.isPending || updateColorMutation.isPending || deleteMutation.isPending;

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;
    if (!name.trim()) {
      toast.error('Informe o nome da categoria.');
      return;
    }

    try {
      await createMutation.mutateAsync({ name: name.trim(), is_active: true, color_hex: color || null });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as categorias de equipamentos.');
      } else {
        toast.error(err?.message || 'Erro ao criar categoria de equipamento.');
      }
    }
  }

  async function handleChangeColor(cat, newColor) {
    if (!canEdit) return;
    try {
      await updateColorMutation.mutateAsync({ id: cat.id, colorHex: newColor });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as categorias de equipamentos.');
      } else {
        toast.error(err?.message || 'Erro ao atualizar a cor da categoria de equipamento.');
      }
    }
  }

  async function handleDelete(cat) {
    if (!canEdit) return;
    const ok = window.confirm(
      `Remover a categoria "${cat.name}" e recategorizar os equipamentos para "Outros"? Esta ação não poderá ser desfeita.`,
    );
    if (!ok) return;

    try {
      await deleteMutation.mutateAsync(cat.id);
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para excluir as categorias de equipamentos.');
      } else {
        toast.error(err?.message || 'Erro ao excluir categoria de equipamento.');
      }
    }
  }

  async function handleToggleActive(cat) {
    if (!canEdit) return;
    try {
      await toggleActiveMutation.mutateAsync({ id: cat.id, isActive: !cat.is_active });
    } catch (err) {
      if (err?.code === '42501') {
        toast.error('Você não possui permissão para alterar as categorias de equipamentos.');
      } else {
        toast.error(err?.message || 'Erro ao atualizar categoria de equipamento.');
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Categorias de equipamentos
          </div>
          <div className="text-xs text-muted-foreground">
            Controle das categorias obrigatórias vinculadas aos equipamentos.
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar as categorias de equipamentos.
        </div>
      )}

      <div className="max-h-64 overflow-auto rounded-md border bg-muted/40">
        {isLoading && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Carregando...</div>
        )}
        {!isLoading && categories.length === 0 && (
          <div className="px-3 py-2 text-xs text-muted-foreground">Nenhuma categoria cadastrada.</div>
        )}
        {!isLoading && categories.length > 0 && (
          <ul className="divide-y text-xs">
            {categories.map((cat) => (
              <li key={cat.id} className="flex items-center justify-between px-3 py-1.5">
                <div className="flex items-center gap-2">
                  <span className={cat.is_active ? '' : 'text-muted-foreground line-through'}>{cat.name}</span>
                  <input
                    type="color"
                    value={cat.color_hex || '#0ea5e9'}
                    onChange={(e) => handleChangeColor(cat, e.target.value)}
                    disabled={!canEdit || isBusy}
                    className="h-5 w-8 cursor-pointer border border-muted bg-background p-0"
                  />
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[11px] text-muted-foreground">
                    {cat.is_active ? 'Ativa' : 'Inativa'}
                  </span>
                  {canEdit && (
                    <>
                      <button
                        type="button"
                        className="text-[11px] text-emerald-700 hover:underline disabled:opacity-60"
                        disabled={isBusy}
                        onClick={() => handleToggleActive(cat)}
                      >
                        {cat.is_active ? 'Desativar' : 'Ativar'}
                      </button>
                      <button
                        type="button"
                        className="text-[11px] text-red-700 hover:underline disabled:opacity-60"
                        disabled={isBusy}
                        onClick={() => handleDelete(cat)}
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
            <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">Nova categoria</span>
            <Input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Ex: Resgate, Incêndio Urbano, Comunicação..."
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
              Adicionar categoria
            </Button>
          </div>
        </form>
      )}
    </div>
  );
}

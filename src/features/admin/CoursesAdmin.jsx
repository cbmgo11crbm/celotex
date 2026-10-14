import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

function useCoursesAdmin() {
  return useQuery({
    queryKey: ['courses', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('courses')
        .select('id, name, description, is_active')
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function CoursesAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: courses = [], isLoading, error } = useCoursesAdmin();

  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [editingCourseId, setEditingCourseId] = useState(null);

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: insertError } = await supabase.from('courses').insert(values);
      if (insertError) throw insertError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['courses'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'admin'] });
      toast.success('Curso criado com sucesso.');
      setName('');
      setDescription('');
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, values }) => {
      const { error: upError } = await supabase
        .from('courses')
        .update(values)
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['courses'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'admin'] });
      toast.success('Curso atualizado com sucesso.');
      setEditingCourseId(null);
      setName('');
      setDescription('');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: async ({ id, isActive }) => {
      const { error: upError } = await supabase
        .from('courses')
        .update({ is_active: isActive })
        .eq('id', id);
      if (upError) throw upError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['courses'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'admin'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: relError } = await supabase
        .from('military_courses')
        .delete()
        .eq('course_id', id);
      if (relError) throw relError;

      const { error: delError } = await supabase
        .from('courses')
        .delete()
        .eq('id', id);
      if (delError) throw delError;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['courses'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'active'] });
      queryClient.invalidateQueries({ queryKey: ['courses', 'admin'] });
      toast.success('Curso excluído com sucesso.');
    },
    onError: (error) => {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir cursos.');
      } else if (error?.code === '23503') {
        toast.error('Não é possível excluir: existem militares vinculados a este curso.');
      } else {
        toast.error(error?.message || 'Erro ao excluir curso.');
      }
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
      toast.error('Informe o nome do curso.');
      return;
    }

    const values = {
      name: name.trim(),
      description: description.trim() || null,
    };

    try {
      if (editingCourseId) {
        await updateMutation.mutateAsync({ id: editingCourseId, values });
      } else {
        await createMutation.mutateAsync({
          ...values,
          is_active: true,
        });
      }
    } catch (err) {
      if (err?.code === '42501') {
        toast.error(
          editingCourseId
            ? 'Você não possui permissão para alterar cursos.'
            : 'Você não possui permissão para criar cursos.',
        );
      } else {
        toast.error(err?.message || (editingCourseId ? 'Erro ao atualizar curso.' : 'Erro ao criar curso.'));
      }
    }
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Cursos de militares
          </div>
          <div className="text-xs text-muted-foreground">
            Cadastro de cursos que podem ser vinculados aos militares.
          </div>
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar os cursos.
        </div>
      )}

      {canEdit && (
        <form
          onSubmit={handleSubmit}
          className="grid gap-2 md:grid-cols-[minmax(0,1.3fr)_minmax(0,1.7fr)_minmax(0,0.7fr)] text-xs"
        >
          <Input
            label="Nome"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Ex: Curso de Formação de Oficiais"
          />
          <Input
            label="Descrição (opcional)"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Detalhes do curso"
          />
          <div className="flex flex-col justify-end gap-1">
            <Button type="submit" size="sm" disabled={isBusy} className="w-full">
              {editingCourseId ? 'Salvar alterações' : 'Adicionar'}
            </Button>
            {editingCourseId && (
              <button
                type="button"
                className="text-[11px] text-muted-foreground hover:underline disabled:opacity-60"
                disabled={isBusy}
                onClick={() => {
                  setEditingCourseId(null);
                  setName('');
                  setDescription('');
                }}
              >
                Cancelar edição
              </button>
            )}
          </div>
        </form>
      )}

      <div className="max-h-80 space-y-1 overflow-auto rounded-md bg-muted/30 p-2 text-xs">
        {isLoading && <div className="px-2 py-1 text-xs text-muted-foreground">Carregando...</div>}
        {!isLoading && courses.length === 0 && (
          <div className="px-2 py-1 text-xs text-muted-foreground">Nenhum curso cadastrado.</div>
        )}

        {!isLoading && courses.length > 0 && (
          <table className="w-full border-collapse text-[11px]">
            <thead>
              <tr className="border-b bg-muted/60 text-left">
                <th className="px-2 py-1">Nome</th>
                <th className="px-2 py-1">Descrição</th>
                <th className="px-2 py-1">Status</th>
                {canEdit && <th className="px-2 py-1 text-right">Ações</th>}
              </tr>
            </thead>
            <tbody>
              {courses.map((course) => (
                <tr key={course.id} className="border-b last:border-0">
                  <td className="px-2 py-1 font-medium">{course.name}</td>
                  <td className="px-2 py-1 text-[10px] text-muted-foreground">{course.description}</td>
                  <td className="px-2 py-1">
                    {course.is_active ? (
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
                          onClick={() => {
                            setEditingCourseId(course.id);
                            setName(course.name ?? '');
                            setDescription(course.description ?? '');
                          }}
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
                              id: course.id,
                              isActive: !course.is_active,
                            })
                          }
                        >
                          {course.is_active ? 'Inativar' : 'Ativar'}
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="ghost"
                          disabled={isBusy}
                          onClick={() => {
                            const confirmed = window.confirm(
                              'Excluir este curso? Os vínculos com militares serão removidos.',
                            );
                            if (!confirmed) return;
                            deleteMutation.mutate(course.id);
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

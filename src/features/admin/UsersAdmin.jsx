import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

const ROLE_LABELS = {
  master: 'Master',
  editor: 'Editor',
  viewer: 'Viewer',
};

function useUsersAdmin() {
  return useQuery({
    queryKey: ['profiles', 'admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, full_name, email, role, is_active, unit_id, units(acronym)')
        .order('full_name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

function useUnitsSelect() {
  return useQuery({
    queryKey: ['units', 'select-all-active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('units')
        .select('id, acronym')
        .eq('is_active', true)
        .order('acronym', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
  });
}

export default function UsersAdmin({ canEdit }) {
  const queryClient = useQueryClient();
  const { data: users = [], isLoading, error } = useUsersAdmin();
  const { data: units = [] } = useUnitsSelect();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [role, setRole] = useState('viewer');
  const [unitId, setUnitId] = useState('');

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['profiles', 'admin'] });

  const createMutation = useMutation({
    mutationFn: async (values) => {
      const { error: rpcError } = await supabase.rpc('admin_create_user', values);
      if (rpcError) throw rpcError;
    },
    onSuccess: () => {
      invalidate();
      toast.success('Usuário criado com sucesso.');
      setEmail('');
      setPassword('');
      setFullName('');
      setRole('viewer');
      setUnitId('');
    },
    onError: (err) => toast.error(err?.message || 'Erro ao criar usuário.'),
  });

  const updateMutation = useMutation({
    mutationFn: async (values) => {
      const { error: rpcError } = await supabase.rpc('admin_configure_user', values);
      if (rpcError) throw rpcError;
    },
    onSuccess: () => {
      invalidate();
      toast.success('Usuário atualizado com sucesso.');
    },
    onError: (err) => toast.error(err?.message || 'Erro ao atualizar usuário.'),
  });

  const deleteMutation = useMutation({
    mutationFn: async (id) => {
      const { error: rpcError } = await supabase.rpc('admin_delete_user', { p_user_id: id });
      if (rpcError) throw rpcError;
    },
    onSuccess: () => {
      invalidate();
      toast.success('Usuário excluído com sucesso.');
    },
    onError: (err) => toast.error(err?.message || 'Erro ao excluir usuário.'),
  });

  const isBusy =
    createMutation.isPending || updateMutation.isPending || deleteMutation.isPending;

  async function handleCreate(e) {
    e.preventDefault();
    if (!canEdit) return;

    if (!email.trim() || !password || !fullName.trim()) {
      toast.error('Informe e-mail, senha e nome completo.');
      return;
    }

    if (role !== 'master' && !unitId) {
      toast.error('Selecione a unidade do usuário.');
      return;
    }

    await createMutation.mutateAsync({
      p_email: email.trim(),
      p_password: password,
      p_full_name: fullName.trim(),
      p_role: role,
      p_unit_id: role === 'master' ? null : unitId || null,
    });
  }

  async function handleEdit(user) {
    if (!canEdit || isBusy) return;

    const newName = window.prompt('Nome completo:', user.full_name ?? '');
    if (newName === null) return;
    const trimmedName = newName.trim();
    if (!trimmedName) {
      toast.error('O nome não pode ficar em branco.');
      return;
    }

    const newRole = window.prompt('Perfil (master, editor, viewer):', user.role ?? 'viewer');
    if (newRole === null) return;
    const trimmedRole = newRole.trim().toLowerCase();
    if (!ROLE_LABELS[trimmedRole]) {
      toast.error('Perfil inválido. Use master, editor ou viewer.');
      return;
    }

    let newUnitId = user.unit_id;
    if (trimmedRole !== 'master') {
      const options = units.map((u) => `${u.acronym}: ${u.id}`).join('\n');
      const answer = window.prompt(
        `ID da unidade (deixe igual para manter):\n${options}`,
        user.unit_id ?? '',
      );
      if (answer === null) return;
      newUnitId = answer.trim() || null;
    } else {
      newUnitId = null;
    }

    const active = window.confirm(
      `Usuário ativo? OK = ativo, Cancelar = inativo.\nAtual: ${user.is_active ? 'ativo' : 'inativo'}`,
    );

    await updateMutation.mutateAsync({
      p_user_id: user.id,
      p_full_name: trimmedName,
      p_role: trimmedRole,
      p_unit_id: newUnitId,
      p_is_active: active,
    });
  }

  return (
    <div className="space-y-3 rounded-lg border bg-background p-3 text-sm md:col-span-2 lg:col-span-3">
      <div>
        <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
          Usuários
        </div>
        <div className="text-xs text-muted-foreground">
          Criação, edição e remoção de usuários no Authentication do Supabase.
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de usuários.
        </div>
      )}

      {canEdit && (
        <form
          onSubmit={handleCreate}
          className="grid gap-2 text-xs md:grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)_minmax(0,1fr)_minmax(0,0.6fr)_minmax(0,0.8fr)_auto]"
        >
          <Input
            label="E-mail"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="usuario@exemplo.com"
          />
          <Input
            label="Senha"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Mínimo 6 caracteres"
          />
          <Input
            label="Nome completo"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            placeholder="Nome do usuário"
          />
          <label className="space-y-1">
            <span className="text-[11px] font-medium text-muted-foreground">Perfil</span>
            <select
              value={role}
              onChange={(e) => setRole(e.target.value)}
              className="h-9 w-full rounded-md border bg-background px-2 text-xs"
            >
              <option value="viewer">Viewer</option>
              <option value="editor">Editor</option>
              <option value="master">Master</option>
            </select>
          </label>
          <label className="space-y-1">
            <span className="text-[11px] font-medium text-muted-foreground">Unidade</span>
            <select
              value={unitId}
              onChange={(e) => setUnitId(e.target.value)}
              disabled={role === 'master'}
              className="h-9 w-full rounded-md border bg-background px-2 text-xs disabled:opacity-50"
            >
              <option value="">Selecione...</option>
              {units.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.acronym}
                </option>
              ))}
            </select>
          </label>
          <div className="flex items-end">
            <Button type="submit" size="sm" disabled={isBusy} className="w-full md:w-auto">
              Adicionar
            </Button>
          </div>
        </form>
      )}

      <div className="max-h-80 space-y-1 overflow-auto rounded-md bg-muted/30 p-2 text-xs">
        {isLoading && <div className="px-2 py-1 text-xs text-muted-foreground">Carregando...</div>}
        {!isLoading && users.length === 0 && (
          <div className="px-2 py-1 text-xs text-muted-foreground">Nenhum usuário encontrado.</div>
        )}

        {!isLoading && users.length > 0 && (
          <table className="w-full border-collapse text-[11px]">
            <thead>
              <tr className="border-b bg-muted/60 text-left">
                <th className="px-2 py-1">Nome</th>
                <th className="px-2 py-1">E-mail</th>
                <th className="px-2 py-1">Perfil</th>
                <th className="px-2 py-1">Unidade</th>
                <th className="px-2 py-1">Status</th>
                {canEdit && <th className="px-2 py-1 text-right">Ações</th>}
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} className="border-b last:border-0">
                  <td className="px-2 py-1 font-medium">{user.full_name}</td>
                  <td className="px-2 py-1">{user.email}</td>
                  <td className="px-2 py-1">{ROLE_LABELS[user.role] ?? user.role}</td>
                  <td className="px-2 py-1">{user.units?.acronym ?? '—'}</td>
                  <td className="px-2 py-1">
                    {user.is_active ? (
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
                          onClick={() => handleEdit(user)}
                        >
                          Editar
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="outline"
                          disabled={isBusy}
                          onClick={() =>
                            updateMutation.mutate({
                              p_user_id: user.id,
                              p_full_name: user.full_name,
                              p_role: user.role,
                              p_unit_id: user.unit_id,
                              p_is_active: !user.is_active,
                            })
                          }
                        >
                          {user.is_active ? 'Inativar' : 'Ativar'}
                        </Button>
                        <Button
                          type="button"
                          size="xs"
                          variant="ghost"
                          disabled={isBusy}
                          onClick={() => {
                            const confirmed = window.confirm(
                              `Excluir o usuário ${user.email}? Esta ação remove o acesso no Authentication.`,
                            );
                            if (!confirmed) return;
                            deleteMutation.mutate(user.id);
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

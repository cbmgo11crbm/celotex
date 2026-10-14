import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { supabase } from '../../lib/supabaseClient.js';
import { useAuth } from '../../providers/AuthProvider.jsx';
import Button from '../../components/ui/Button.jsx';
import Input from '../../components/ui/Input.jsx';

export default function ResetPasswordPage() {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const navigate = useNavigate();
  const { session, isLoading } = useAuth();

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!password || !confirmPassword) {
      toast.error('Preencha e confirme a nova senha.');
      return;
    }

    if (password !== confirmPassword) {
      toast.error('A confirmação não confere com a nova senha.');
      return;
    }

    if (password.length < 8) {
      toast.error('A nova senha deve ter pelo menos 8 caracteres.');
      return;
    }

    try {
      setIsSubmitting(true);
      const { error } = await supabase.auth.updateUser({ password });
      if (error) {
        throw error;
      }

      toast.success('Senha redefinida com sucesso. Faça login novamente.');
      navigate('/login', { replace: true });
    } catch (error) {
      toast.error(error?.message || 'Não foi possível redefinir a senha. O link pode ter expirado.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-muted/40 px-4">
        <div className="w-full max-w-md rounded-lg border bg-background p-6 text-sm text-muted-foreground shadow-sm">
          Verificando link de redefinição...
        </div>
      </div>
    );
  }

  if (!session) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-muted/40 px-4">
        <div className="w-full max-w-md rounded-lg border bg-background p-6 text-sm text-muted-foreground shadow-sm">
          <p className="mb-2 font-medium">Link inválido ou expirado</p>
          <p>
            O link de redefinição de senha é válido por tempo limitado. Volte para a tela de login e
            solicite um novo link de "Esqueci minha senha".
          </p>
          <Button className="mt-4 w-full" onClick={() => navigate('/login')}>
            Voltar para o login
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/40 px-4">
      <div className="w-full max-w-md rounded-lg border bg-background p-6 shadow-sm">
        <h1 className="mb-2 text-center text-xl font-semibold tracking-tight">Definir nova senha</h1>
        <p className="mb-6 text-center text-sm text-muted-foreground">
          Informe sua nova senha de acesso ao sistema.
        </p>

        <form className="space-y-4" onSubmit={handleSubmit}>
          <div className="space-y-1 text-sm">
            <label htmlFor="password" className="font-medium">
              Nova senha
            </label>
            <Input
              id="password"
              type="password"
              autoComplete="new-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>

          <div className="space-y-1 text-sm">
            <label htmlFor="confirmPassword" className="font-medium">
              Confirmar nova senha
            </label>
            <Input
              id="confirmPassword"
              type="password"
              autoComplete="new-password"
              required
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
            />
          </div>

          <Button type="submit" className="w-full" disabled={isSubmitting}>
            {isSubmitting ? 'Salvando...' : 'Salvar nova senha'}
          </Button>
        </form>
      </div>
    </div>
  );
}

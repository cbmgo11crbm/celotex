import { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { useAuth } from '../../providers/AuthProvider.jsx';
import { supabase } from '../../lib/supabaseClient.js';
import Button from '../../components/ui/Button.jsx';
import Input from '../../components/ui/Input.jsx';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();
  const location = useLocation();
  const { signIn, isLoading, isAuthenticated, hasValidProfile } = useAuth();

  useEffect(() => {
    if (isAuthenticated && hasValidProfile) {
      const redirectTo = location.state?.from?.pathname ?? '/app';
      navigate(redirectTo, { replace: true });
    }
  }, [isAuthenticated, hasValidProfile, location.state, navigate]);

  const handleResetPassword = async () => {
    if (!email) {
      toast.error('Informe o e-mail institucional para receber o link de redefinição.');
      return;
    }

    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      if (error) {
        throw error;
      }

      toast.success('Se o e-mail estiver cadastrado, você receberá um link para redefinir a senha.');
    } catch (error) {
      toast.error(error?.message || 'Não foi possível enviar o e-mail de redefinição de senha.');
    }
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    const result = await signIn({ email, password });
    if (!result.success) {
      let message = 'Não foi possível entrar. Verifique suas credenciais.';
      if (result.error?.message?.toLowerCase().includes('invalid login')) {
        message = 'E-mail ou senha inválidos.';
      }
      toast.error(message);
      return;
    }

    const redirectTo = location.state?.from?.pathname ?? '/app';
    navigate(redirectTo, { replace: true });
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/40 px-4">
      <div className="w-full max-w-md rounded-lg border bg-background p-6 shadow-sm">
        <h1 className="mb-2 text-center text-xl font-semibold tracking-tight">Acesso ao Sistema</h1>
        <p className="mb-6 text-center text-sm text-muted-foreground">
          Sistema de Gestão do Comando Regional de Bombeiros Militar
        </p>

        <form className="space-y-4" onSubmit={handleSubmit}>
          <div className="space-y-1 text-sm">
            <label htmlFor="email" className="font-medium">
              E-mail institucional
            </label>
            <Input
              id="email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>

          <div className="space-y-1 text-sm">
            <label htmlFor="password" className="font-medium">
              Senha
            </label>
            <Input
              id="password"
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>

          <Button type="submit" className="w-full" disabled={isLoading}>
            {isLoading ? 'Entrando...' : 'Entrar'}
          </Button>

          <div className="flex items-center justify-between text-xs text-muted-foreground">
            <button
              type="button"
              onClick={handleResetPassword}
              className="text-xs font-medium text-primary hover:underline"
            >
              Esqueci minha senha
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

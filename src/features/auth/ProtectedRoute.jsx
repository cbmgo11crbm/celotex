import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../providers/AuthProvider.jsx';
import Button from '../../components/ui/Button.jsx';

export default function ProtectedRoute({ children }) {
  const { isAuthenticated, isLoading, hasValidProfile, signOut } = useAuth();
  const location = useLocation();

  if (isLoading && !isAuthenticated) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-muted/40 px-4">
        <div className="rounded-lg border bg-background px-4 py-3 text-sm text-muted-foreground shadow-sm">
          Carregando sessão...
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (!hasValidProfile) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-muted/40 px-4">
        <div className="max-w-md rounded-lg border bg-background p-6 text-sm text-muted-foreground shadow-sm">
          <p className="mb-2 font-medium text-foreground">Seu usuário ainda não está ativo ou não possui perfil configurado.</p>
          <p className="mb-4">
            Entre em contato com um usuário Master para concluir a configuração do seu acesso.
          </p>
          <Button variant="outline" onClick={signOut}>
            Sair
          </Button>
        </div>
      </div>
    );
  }

  return children;
}

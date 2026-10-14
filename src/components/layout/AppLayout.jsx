import { Link, NavLink, Outlet, useLocation, useSearchParams } from 'react-router-dom';
import { Menu, Moon, Sun, LogOut } from 'lucide-react';
import { useState } from 'react';
import { useTheme } from '../../providers/ThemeProvider.jsx';
import { useAuth } from '../../providers/AuthProvider.jsx';

const navItems = [
  { to: '/app', label: 'Dashboard', end: true },
  { to: '/app/militares', label: 'Militares' },
  { to: '/app/viaturas', label: 'Viaturas' },
  { to: '/app/equipamentos', label: 'Equipamentos' },
  { to: '/app/admin', label: 'Administração' },
  { to: '/app/logs', label: 'Logs de alterações', requiresMaster: true },
];

export default function AppLayout() {
  const { theme, toggleTheme } = useTheme();
  const [mobileOpen, setMobileOpen] = useState(false);
  const location = useLocation();
  const [searchParams, setSearchParams] = useSearchParams();
  const { profile, role, signOut } = useAuth();

  const roleLabel =
    role === 'master' ? 'Master' : role === 'editor' ? 'Editor' : role === 'viewer' ? 'Viewer' : 'Sem perfil';

  const isMilitares = location.pathname.startsWith('/app/militares');
  const isViaturas = location.pathname.startsWith('/app/viaturas');
  const showViewToggle = isMilitares || isViaturas;
  const viewMode = searchParams.get('view') === 'table' ? 'table' : 'cards';

  function handleChangeViewMode(mode) {
    const next = new URLSearchParams(searchParams);
    next.set('view', mode);
    setSearchParams(next, { replace: true });
  }

  function handleGuardedNavClick(event, onAfterNavigate) {
    if (typeof window !== 'undefined' && window.__hasUnsavedChanges) {
      const ok = window.confirm(
        'Existem alterações não salvas em um cadastro aberto. Deseja sair da página mesmo assim?',
      );
      if (!ok) {
        event.preventDefault();
        return;
      }
    }
    if (onAfterNavigate) onAfterNavigate();
  }

  return (
    <div className="flex h-screen overflow-hidden bg-background text-foreground">
      {/* Sidebar desktop */}
      <aside className="hidden w-52 shrink-0 overflow-y-auto border-r bg-background/80 p-3 shadow-sm md:flex md:h-screen md:flex-col">
        <div className="mb-6 flex items-center justify-between">
          <Link
            to="/app"
            className="text-sm font-semibold tracking-tight"
            onClick={(event) => handleGuardedNavClick(event)}
          >
            Comando Regional
          </Link>
        </div>
        <nav className="flex-1 space-y-1 text-sm">
          {navItems
            .filter((item) => !item.requiresMaster || role === 'master')
            .map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              onClick={(event) => handleGuardedNavClick(event)}
              className={({ isActive }) =>
                `flex items-center justify-between rounded-md px-3 py-2 transition-colors hover:bg-accent hover:text-accent-foreground ${
                  isActive ? 'bg-accent text-accent-foreground font-medium' : 'text-muted-foreground'
                }`
              }
            >
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>
        <div className="mt-4 border-t pt-4 text-xs text-muted-foreground">
          <div className="flex items-center justify-between">
            <div>
              <div className="font-medium">{profile?.full_name ?? 'Usuário'}</div>
              <div className="text-xs text-muted-foreground">Perfil: {roleLabel}</div>
            </div>
            <button
              type="button"
              onClick={toggleTheme}
              className="inline-flex h-8 w-8 items-center justify-center rounded-md border bg-background text-muted-foreground shadow-sm hover:bg-accent hover:text-accent-foreground"
              aria-label="Alternar tema claro/escuro"
            >
              {theme === 'dark' ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
            </button>
          </div>
          <div className="mt-3 flex items-center justify-between text-xs">
            <button
              type="button"
              onClick={signOut}
              className="inline-flex items-center gap-1 rounded-md px-2 py-1 text-xs text-muted-foreground hover:bg-accent hover:text-accent-foreground"
            >
              <LogOut className="h-3 w-3" />
              Sair
            </button>
          </div>
        </div>
      </aside>

      {/* Conteúdo + header */}
      <div className="flex min-h-screen flex-1 flex-col">
        <header className="flex items-center justify-between border-b bg-background/80 px-4 py-3 shadow-sm">
          <div className="flex items-center gap-2">
            <button
              type="button"
              className="inline-flex items-center justify-center rounded-md border bg-background p-2 text-muted-foreground shadow-sm hover:bg-accent hover:text-accent-foreground md:hidden"
              onClick={() => setMobileOpen((open) => !open)}
              aria-label="Abrir menu"
            >
              <Menu className="h-4 w-4" />
            </button>
            <div className="flex flex-col">
              {location.pathname === '/app' && (
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Dashboard</div>
              )}
              {location.pathname.startsWith('/app/militares') && (
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Militares</div>
              )}
              {location.pathname.startsWith('/app/viaturas') && (
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Viaturas</div>
              )}
              {location.pathname.startsWith('/app/equipamentos') && (
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Equipamentos</div>
              )}
              {location.pathname.startsWith('/app/admin') && (
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Administração</div>
              )}
            </div>
          </div>
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            {showViewToggle && (
              <div className="inline-flex rounded-md border bg-background p-0.5 text-[11px]">
                <button
                  type="button"
                  onClick={() => handleChangeViewMode('table')}
                  className={`rounded px-2 py-1 ${
                    viewMode === 'table'
                      ? 'bg-emerald-600 text-white'
                      : 'text-muted-foreground hover:bg-muted'
                  }`}
                >
                  Tabela
                </button>
                <button
                  type="button"
                  onClick={() => handleChangeViewMode('cards')}
                  className={`rounded px-2 py-1 ${
                    viewMode === 'cards'
                      ? 'bg-emerald-600 text-white'
                      : 'text-muted-foreground hover:bg-muted'
                  }`}
                >
                  Cards
                </button>
              </div>
            )}
            <button
              type="button"
              onClick={toggleTheme}
              className="hidden h-8 w-8 items-center justify-center rounded-md border bg-background text-muted-foreground shadow-sm hover:bg-accent hover:text-accent-foreground md:inline-flex"
              aria-label="Alternar tema claro/escuro"
            >
              {theme === 'dark' ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
            </button>
          </div>
        </header>

        {/* Mobile sidebar */}
        {mobileOpen && (
          <div className="border-b bg-background/95 px-4 py-3 shadow-sm md:hidden">
            <nav className="space-y-1 text-sm">
              {navItems
                .filter((item) => !item.requiresMaster || role === 'master')
                .map((item) => (
                <NavLink
                  key={item.to}
                  to={item.to}
                  end={item.end}
                  onClick={(event) => handleGuardedNavClick(event, () => setMobileOpen(false))}
                  className={({ isActive }) =>
                    `flex items-center justify-between rounded-md px-3 py-2 transition-colors hover:bg-accent hover:text-accent-foreground ${
                      isActive ? 'bg-accent text-accent-foreground font-medium' : 'text-muted-foreground'
                    }`
                  }
                >
                  <span>{item.label}</span>
                </NavLink>
              ))}
            </nav>
          </div>
        )}

        <main className="h-screen flex-1 overflow-y-auto bg-background px-4 py-4">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

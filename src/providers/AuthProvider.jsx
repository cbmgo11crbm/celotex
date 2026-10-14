/* eslint-disable react-refresh/only-export-components */
import { createContext, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { supabase } from '../lib/supabaseClient.js';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [session, setSession] = useState(null);
  const [profile, setProfile] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const hasInitialized = useRef(false);

  useEffect(() => {
    let isMounted = true;

    async function load() {
      if (!hasInitialized.current) {
        setIsLoading(true);
      }
      setError(null);
      try {
        const { data, error: sessionError } = await supabase.auth.getSession();
        if (sessionError) throw sessionError;

        const currentSession = data.session ?? null;
        setSession(currentSession);

        if (!currentSession) {
          setProfile(null);
          return;
        }

        const userId = currentSession.user.id;

        // Perfis inativos não são retornados pelas policies; neste caso
        // trataremos como "sem perfil válido" na camada de apresentação.
        const { data: profiles, error: profileError } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

        if (profileError && profileError.code !== 'PGRST116') {
          throw profileError;
        }

        setProfile(profiles ?? null);

        // Atualiza last_login_at somente para usuários ativos.
        if (profiles?.is_active) {
          await supabase.rpc('touch_last_login');
        }
      } catch (e) {
        if (!isMounted) return;
        setError(e);
        setSession(null);
        setProfile(null);
      } finally {
        if (isMounted) {
          setIsLoading(false);
          hasInitialized.current = true;
        }
      }
    }

    load();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(() => {
      load();
    });

    return () => {
      isMounted = false;
      subscription.unsubscribe();
    };
  }, []);

  const signIn = async ({ email, password }) => {
    setIsLoading(true);
    setError(null);
    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({ email, password });
      if (signInError) throw signInError;
      setSession(data.session ?? null);
      return { success: true };
    } catch (e) {
      setError(e);
      return { success: false, error: e };
    } finally {
      setIsLoading(false);
    }
  };

  const signOut = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const { error: signOutError } = await supabase.auth.signOut();
      if (signOutError) throw signOutError;
      setSession(null);
      setProfile(null);
    } catch (e) {
      setError(e);
    } finally {
      setIsLoading(false);
    }
  };

  const value = useMemo(
    () => ({
      session,
      profile,
      isLoading,
      error,
      isAuthenticated: Boolean(session),
      hasValidProfile: Boolean(profile?.is_active),
      role: profile?.role ?? null,
      unitId: profile?.unit_id ?? null,
      isMaster: profile?.role === 'master',
      isEditor: profile?.role === 'editor',
      isViewer: profile?.role === 'viewer',
      signIn,
      signOut,
    }),
    [session, profile, isLoading, error],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth deve ser usado dentro de AuthProvider');
  }
  return ctx;
}

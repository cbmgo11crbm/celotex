set check_function_bodies = off;

-- Tabela de logs de auditoria
-- A tabela public.audit_logs já foi criada em 0001_initial_schema com as colunas
-- básicas: id, actor_user_id, action, schema_name, table_name, record_id,
-- old_data, new_data, occurred_at. Aqui apenas acrescentamos colunas auxiliares
-- usadas pela UI de logs.

alter table public.audit_logs
  add column if not exists user_email public.citext,
  add column if not exists user_full_name text,
  add column if not exists unit_id uuid references public.units(id) on delete set null,
  add column if not exists changed_columns text[] default array[]::text[];

comment on table public.audit_logs is 'Registros de auditoria de alterações na base de dados.';

alter table public.audit_logs enable row level security;

-- Apenas Master pode consultar logs (cria somente se ainda não existir)
do $$
begin
  if not exists (
    select 1
    from pg_policies p
    where p.schemaname = 'public'
      and p.tablename = 'audit_logs'
      and p.policyname = 'audit_logs_master_select'
  ) then
    create policy audit_logs_master_select
      on public.audit_logs
      for select
      using (private.is_master());
  end if;
end
$$;

-- Função de gatilho genérica para registrar alterações
create or replace function public.audit_log_row()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_email public.citext;
  v_full_name text;
  v_new jsonb;
  v_old jsonb;
  v_changed text[] := array[]::text[];
  v_record_id text;
  v_unit_id uuid;
begin
  if (tg_op = 'INSERT') then
    v_new := to_jsonb(new);
    v_old := null;
  elsif (tg_op = 'DELETE') then
    v_new := null;
    v_old := to_jsonb(old);
  else
    v_new := to_jsonb(new);
    v_old := to_jsonb(old);
  end if;

  -- tenta capturar um identificador básico (id ou pk)
  v_record_id := coalesce(
    coalesce(v_new ->> 'id', v_old ->> 'id'),
    coalesce(v_new ->> 'pk', v_old ->> 'pk')
  );

  -- tenta capturar unit_id, se existir na linha
  begin
    v_unit_id := coalesce(
      nullif(v_new ->> 'unit_id', '')::uuid,
      nullif(v_old ->> 'unit_id', '')::uuid
    );
  exception when others then
    v_unit_id := null;
  end;

  -- lista de colunas alteradas em UPDATE
  if (tg_op = 'UPDATE') then
    select coalesce(array_agg(key), array[]::text[])
    into v_changed
    from jsonb_each(coalesce(v_new, '{}'::jsonb))
    where v_old is null or v_old -> key is distinct from v_new -> key;

    -- Se nenhuma coluna mudou de fato, não registra log para evitar ruído
    if coalesce(array_length(v_changed, 1), 0) = 0 then
      return new;
    end if;
  end if;

  -- informações do usuário, se houver sessão
  if v_user_id is not null then
    select p.email, p.full_name
    into v_email, v_full_name
    from public.profiles p
    where p.id = v_user_id;
  end if;

  insert into public.audit_logs (
    actor_user_id,
    action,
    schema_name,
    table_name,
    record_id,
    user_email,
    user_full_name,
    unit_id,
    changed_columns,
    old_data,
    new_data
  ) values (
    v_user_id,
    tg_op,
    'public',
    tg_table_name,
    v_record_id,
    v_email,
    v_full_name,
    v_unit_id,
    v_changed,
    v_old,
    v_new
  );

  if (tg_op = 'DELETE') then
    return old;
  else
    return new;
  end if;
end;
$$;

comment on function public.audit_log_row() is 'Gatilho genérico de auditoria para INSERT/UPDATE/DELETE em tabelas da aplicação.';

-- Cria gatilhos de auditoria para todas as tabelas públicas (exceto a própria audit_logs)
-- e evita recriar se já existir.
do $$
declare
  r record;
begin
  for r in
    select tablename
    from pg_tables
    where schemaname = 'public'
      and tablename not in ('audit_logs')
  loop
    if not exists (
      select 1
      from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = r.tablename
        and t.tgname = format('audit_%s_row', r.tablename)
    ) then
      execute format(
        'create trigger %I after insert or update or delete on public.%I
         for each row execute function public.audit_log_row();',
        'audit_' || r.tablename || '_row',
        r.tablename
      );
    end if;
  end loop;
end
$$;

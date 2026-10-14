set check_function_bodies = off;

-- Tabela de logs de auditoria
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),

  table_name text not null,
  operation text not null, -- INSERT | UPDATE | DELETE
  record_id text,

  user_id uuid,
  user_email citext,
  user_full_name text,

  unit_id uuid references public.units(id) on delete set null,

  changed_columns text[] default array[]::text[],
  old_data jsonb,
  new_data jsonb
);

comment on table public.audit_logs is 'Registros de auditoria de alterações na base de dados.';

alter table public.audit_logs enable row level security;

-- Apenas Master pode consultar logs
create policy audit_logs_master_select
on public.audit_logs
for select
using (private.is_master());

-- Função de gatilho genérica para registrar alterações
create or replace function public.audit_log_row()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_email citext;
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
  end if;

  -- informações do usuário, se houver sessão
  if v_user_id is not null then
    select p.email, p.full_name
    into v_email, v_full_name
    from public.profiles p
    where p.id = v_user_id;
  end if;

  insert into public.audit_logs (
    table_name,
    operation,
    record_id,
    user_id,
    user_email,
    user_full_name,
    unit_id,
    changed_columns,
    old_data,
    new_data
  ) values (
    tg_table_name,
    tg_op,
    v_record_id,
    v_user_id,
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

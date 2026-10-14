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
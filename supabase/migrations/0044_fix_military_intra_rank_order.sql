begin;

-- 0044_fix_military_intra_rank_order.sql
-- Normaliza intra_rank_order para novos militares e torna a troca
-- de ordem resiliente a valores NULL.

-- Função utilitária que atribui ordem sequencial dentro de cada posto
-- para todos os militares ativos cujo intra_rank_order está nulo.
create or replace function public.init_military_intra_rank_order()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  with ranked as (
    select
      mp.id,
      mp.rank_id,
      row_number() over (
        partition by mp.rank_id
        order by d.rank_order, coalesce(mp.intra_rank_order, 999999), d.war_name, d.full_name, mp.id
      ) as new_intra_rank_order
    from public.military_personnel mp
    join public.v_military_directory d on d.id = mp.id
    where d.is_inactive = false
  )
  update public.military_personnel mp
  set intra_rank_order = r.new_intra_rank_order
  from ranked r
  where mp.id = r.id;
end;
$$;

revoke all on function public.init_military_intra_rank_order() from public;
grant execute on function public.init_military_intra_rank_order() to authenticated;

-- Atualiza swap para garantir que todos os militares do posto tenham
-- intra_rank_order definido antes de trocar.
create or replace function public.swap_military_intra_rank_order(
  p_military_id_a uuid,
  p_military_id_b uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rank_a uuid;
  v_rank_b uuid;
  v_order_a integer;
  v_order_b integer;
begin
  if p_military_id_a is null or p_military_id_b is null then
    raise exception 'IDs de militar não informados.';
  end if;

  -- Garante que todos os militares ativos tenham intra_rank_order preenchido
  perform public.init_military_intra_rank_order();

  select rank_id, intra_rank_order
  into v_rank_a, v_order_a
  from public.military_personnel
  where id = p_military_id_a
  for update;

  select rank_id, intra_rank_order
  into v_rank_b, v_order_b
  from public.military_personnel
  where id = p_military_id_b
  for update;

  if v_rank_a is null or v_rank_b is null then
    raise exception 'Não foi possível encontrar ambos os militares.';
  end if;

  if v_rank_a <> v_rank_b then
    raise exception 'Só é possível reordenar militares dentro do mesmo posto/graduação.';
  end if;

  if v_order_a is null or v_order_b is null then
    raise exception 'intra_rank_order não inicializado.';
  end if;

  update public.military_personnel
  set intra_rank_order = v_order_b
  where id = p_military_id_a;

  update public.military_personnel
  set intra_rank_order = v_order_a
  where id = p_military_id_b;
end;
$$;

revoke all on function public.swap_military_intra_rank_order(uuid, uuid) from public;
grant execute on function public.swap_military_intra_rank_order(uuid, uuid) to authenticated;

commit;

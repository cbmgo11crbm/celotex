begin;

-- View de apoio para ordenação de militares por posto + intra_rank_order
create or replace view public.v_military_order_admin as
select
  mp.id,
  d.full_name,
  d.war_name,
  d.rank_code,
  d.rank_order      as rank_sort_order,
  r.name            as rank_name,
  mp.intra_rank_order
from public.military_personnel mp
join public.v_military_directory d
  on d.id = mp.id
left join public.ranks r
  on r.id = mp.rank_id
where
  -- Apenas militares não inativados (ajuste se desejar incluir inativos)
  d.is_inactive = false
order by
  d.rank_order asc,
  mp.intra_rank_order asc,
  d.war_name asc,
  d.full_name asc;

revoke all on public.v_military_order_admin from public;
grant select on public.v_military_order_admin to authenticated;

-- Função para trocar a ordem relativa entre dois militares do mesmo posto/graduação
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

  -- Garante mesmo posto/graduação
  if v_rank_a <> v_rank_b then
    raise exception 'Só é possível reordenar militares dentro do mesmo posto/graduação.';
  end if;

  -- Troca os valores de intra_rank_order em uma única transação
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

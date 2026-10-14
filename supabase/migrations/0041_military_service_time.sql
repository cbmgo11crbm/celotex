begin;

-- 0041_military_service_time.sql
-- Adiciona campo de data de inclusão do militar e função de overview
-- de tempo de serviço para o dashboard.

alter table public.military_personnel
  add column if not exists inclusion_date date;

create index if not exists military_inclusion_date_idx
  on public.military_personnel (inclusion_date);

-- Função de overview de tempo de serviço por faixas de anos.
-- Considera apenas militares não inativos na view de diretório.

create or replace function public.service_time_overview(p_unit_id uuid default null)
returns table (
  unit_id uuid,
  avg_years numeric,
  bucket_0_5 integer,
  bucket_6_10 integer,
  bucket_11_15 integer,
  bucket_16_20 integer,
  bucket_21_25 integer,
  bucket_26_30 integer,
  bucket_30_plus integer
)
language sql
stable
security invoker
set search_path = ''
as $$
  with base as (
    select
      d.id as military_id,
      d.unit_id,
      d.is_inactive,
      mp.inclusion_date,
      case
        when mp.inclusion_date is null then null
        else extract(year from age(current_date, mp.inclusion_date))::numeric
      end as years
    from public.v_military_directory d
    join public.military_personnel mp on mp.id = d.id
    where
      (p_unit_id is null or d.unit_id = p_unit_id)
      and d.is_inactive = false
  )
  select
    coalesce(p_unit_id, null) as unit_id,
    avg(years) filter (where years is not null) as avg_years,
    count(*) filter (where years is not null and years >= 0 and years <= 5)   as bucket_0_5,
    count(*) filter (where years > 5  and years <= 10)  as bucket_6_10,
    count(*) filter (where years > 10 and years <= 15)  as bucket_11_15,
    count(*) filter (where years > 15 and years <= 20)  as bucket_16_20,
    count(*) filter (where years > 20 and years <= 25)  as bucket_21_25,
    count(*) filter (where years > 25 and years <= 30)  as bucket_26_30,
    count(*) filter (where years > 30)                  as bucket_30_plus
  from base;
$$;

revoke all on function public.service_time_overview(uuid) from public;
grant execute on function public.service_time_overview(uuid) to authenticated;

commit;

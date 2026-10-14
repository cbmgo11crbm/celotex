begin;

-- 0039_military_health_restrictions.sql
-- Adiciona coluna para distinguir "Apto" de "Apto com restrições" nas
-- avaliações periódicas de saúde.

alter table public.military_health_exams
  add column if not exists has_restrictions boolean not null default false;

-- Para alterar o conjunto de colunas da view, precisamos recriar
-- dependências de forma explícita.

drop function if exists public.health_latest_overview(uuid);
drop view if exists public.v_military_health_latest;

-- Recria a view v_military_health_latest expondo has_restrictions
create view public.v_military_health_latest
with (security_invoker = true)
as
with ranked as (
  select
    h.id,
    h.military_id,
    h.year,
    h.exam_date,
    h.is_fit,
    h.has_restrictions,
    h.validity_date,
    h.created_at,
    row_number() over (
      partition by h.military_id
      order by h.exam_date desc, h.created_at desc
    ) as rn
  from public.military_health_exams h
)
select
  id,
  military_id,
  year,
  exam_date,
  is_fit,
  has_restrictions,
  validity_date,
  created_at
from ranked
where rn = 1;

revoke all on public.v_military_health_latest from public;
grant select on public.v_military_health_latest to authenticated;

-- Recria a função de overview de saúde usando a nova view
create or replace function public.health_latest_overview(p_unit_id uuid default null)
returns table (
  unit_id uuid,
  total_military integer,
  with_exam integer,
  without_exam integer,
  count_unfit integer,
  count_expired integer,
  expired_list jsonb
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
      hl.exam_date,
      hl.is_fit,
      hl.validity_date,
      d.rank_code,
      d.war_name,
      d.unit_acronym
    from public.v_military_directory d
    left join public.v_military_health_latest hl
      on hl.military_id = d.id
    where
      (p_unit_id is null or d.unit_id = p_unit_id)
      and d.is_inactive = false
  )
  select
    coalesce(p_unit_id, null) as unit_id,
    count(*)::integer as total_military,
    count(exam_date)::integer as with_exam,
    (count(*) - count(exam_date))::integer as without_exam,
    count(*) filter (where is_fit = false)::integer as count_unfit,
    count(*) filter (where validity_date < current_date)::integer as count_expired,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'military_id', military_id,
          'rank_code', rank_code,
          'war_name', war_name,
          'unit_acronym', unit_acronym,
          'validity_date', validity_date
        )
        order by validity_date asc
      ) filter (where validity_date < current_date),
      '[]'::jsonb
    ) as expired_list
  from base;
$$;

revoke all on function public.health_latest_overview(uuid) from public;
grant execute on function public.health_latest_overview(uuid) to authenticated;

commit;

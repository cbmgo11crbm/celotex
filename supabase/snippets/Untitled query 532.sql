begin;

-- Garante a existência da seção "Serv. Operacional".
insert into public.sections (acronym, name, is_active)
select 'Serv. Operacional', 'Serviço Operacional', true
where not exists (
  select 1
  from public.sections s
  where lower(s.acronym::text) = lower('Serv. Operacional')
);

commit;

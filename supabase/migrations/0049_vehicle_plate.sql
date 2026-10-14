begin;

alter table public.vehicles add column if not exists plate text;

commit;

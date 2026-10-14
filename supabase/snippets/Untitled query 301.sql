select n.nspname as schema, t.typname as type_name
from pg_type t
join pg_namespace n on n.oid = t.typnamespace
where t.typname = 'citext';
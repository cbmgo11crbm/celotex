set role authenticated;
select current_user, current_setting('search_path');
reset role;

set role anon;
select current_user, current_setting('search_path');
reset role;
update public.profiles
set role = 'editor',
    is_active = true,
    unit_id = 'fe382676-4851-4b5c-ae25-b0fb1365c33a', -- 11º CRBM
    updated_at = now()
where id = '13a36674-c4e8-41e6-b49d-0faf128c7421';

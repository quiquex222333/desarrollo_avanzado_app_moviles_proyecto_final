alter table users
  add column auth_user_id uuid references auth.users(id) on delete cascade;

update users set auth_user_id = gen_random_uuid() where auth_user_id is null;

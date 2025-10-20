-- Activar RLS
alter table users enable row level security;
alter table sales enable row level security;
alter table purchases enable row level security;
alter table stock enable row level security;
alter table employees enable row level security;

-- Política: los admin pueden ver todo
create policy "Admins see everything"
on users for all
using (auth.uid() = id or exists(select 1 from users u where u.id = auth.uid() and u.role = 'admin'));

-- Política: encargado de tienda solo ve su tienda
create policy "Store manager sees own store"
on sales for select
using (
  created_by = auth.uid()
);

-- Política: encargado de almacén solo ve sus compras
create policy "Warehouse manager sees own warehouse"
on purchases for select
using (
  created_by = auth.uid()
);

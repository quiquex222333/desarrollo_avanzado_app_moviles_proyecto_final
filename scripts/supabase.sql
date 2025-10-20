-- 🧱 1. Tabla de usuarios (autenticación básica)
create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  role text check (role in ('admin', 'store_manager', 'warehouse_manager')) not null,
  created_at timestamp default now()
);

-- 🏬 2. Tiendas
create table stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  created_at timestamp default now()
);

-- 🏢 3. Almacenes
create table warehouses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text,
  created_at timestamp default now()
);

-- 🧑‍💼 4. Empleados
create table employees (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  full_name text not null,
  assigned_store uuid references stores(id),
  assigned_warehouse uuid references warehouses(id),
  created_at timestamp default now()
);

-- 🪵 5. Productos
create table products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  unit_price numeric(10,2) not null default 0,
  description text,
  created_at timestamp default now()
);

-- 📦 6. Stock (por ubicación)
create table stock (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references products(id) on delete cascade,
  location_type text check (location_type in ('store', 'warehouse')) not null,
  location_id uuid not null, -- referencia dinámica (store o warehouse)
  quantity numeric(10,2) not null default 0,
  updated_at timestamp default now()
);

-- 🧾 7. Proveedores
create table suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  address text
);

-- 💰 8. Compras
create table purchases (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid references suppliers(id),
  warehouse_id uuid references warehouses(id),
  store_id uuid references stores(id),
  total numeric(10,2) default 0,
  created_by uuid references users(id),
  created_at timestamp default now()
);

-- 📋 9. Detalle de compras
create table purchase_items (
  id uuid primary key default gen_random_uuid(),
  purchase_id uuid references purchases(id) on delete cascade,
  product_id uuid references products(id),
  quantity numeric(10,2) not null,
  price numeric(10,2) not null
);

-- 🛍️ 10. Ventas
create table sales (
  id uuid primary key default gen_random_uuid(),
  store_id uuid references stores(id),
  customer_name text,
  total numeric(10,2) default 0,
  created_by uuid references users(id),
  created_at timestamp default now()
);

-- 📋 11. Detalle de ventas
create table sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid references sales(id) on delete cascade,
  product_id uuid references products(id),
  quantity numeric(10,2) not null,
  price numeric(10,2) not null
);

-- 🔄 12. Transferencias entre almacenes y tiendas
create table transfers (
  id uuid primary key default gen_random_uuid(),
  from_location_type text check (from_location_type in ('store', 'warehouse')),
  from_location_id uuid,
  to_location_type text check (to_location_type in ('store', 'warehouse')),
  to_location_id uuid,
  product_id uuid references products(id),
  quantity numeric(10,2),
  created_by uuid references users(id),
  created_at timestamp default now()
);

# 🏗️ Inventario Offline-First

Sistema móvil de gestión de inventario **Offline-First** desarrollado con **Flutter**, **Drift (SQLite)** y **Supabase**.  
Permite administrar productos, compras, ventas y stock por tienda o almacén, con sincronización automática entre el modo offline y online.

---

## 🚀 Características principales

- ✅ **Gestión de inventario**: productos, compras, ventas y transferencias entre almacenes y tiendas.
- 🧠 **Autenticación y roles**: manejo de usuarios con Supabase (admin, store_manager, warehouse_manager).
- 📦 **Sincronización Offline-First**:
  - Funciona completamente sin conexión.
  - Guarda los cambios en una cola local (`sync_queue`).
  - Al reconectarse, sincroniza automáticamente con Supabase.
  - Actualización en tiempo real gracias a **Supabase Realtime**.
- 📊 **Reportes y seguimiento**: ventas y compras por fecha, tienda o almacén.
- 🧩 **Arquitectura limpia**: Flutter + BLoC + Repositorios + Drift + Supabase.

---

## 🧱 Stack Tecnológico

| Capa | Tecnología |
|------|-------------|
| **Frontend móvil** | Flutter 3.x |
| **Gestión de estado** | BLoC |
| **Base local** | Drift (SQLite) |
| **Backend** | Supabase (PostgreSQL + Realtime) |
| **Sincronización** | `connectivity_plus` + `SyncService` personalizado |
| **Autenticación** | Supabase Auth |
| **Dependencias clave** | flutter_bloc, drift, supabase_flutter, connectivity_plus, uuid |

---

## ⚙️ Instalación y configuración

### 1️⃣ Clonar el repositorio
```bash
git clone https://github.com/tuusuario/inventario_offline_first.git
cd inventario_offline_first
```

### 2️⃣ Instalar dependencias
```bash
flutter pub get
```

### 3️⃣ Configurar Supabase

1. Crea un nuevo proyecto en [Supabase.io](https://supabase.io).
2. En el archivo  
   ```
   lib/core/config/supabase_config.dart
   ```
   agrega tus claves:

   ```dart
   class SupabaseConfig {
     static Future<void> init() async {
       await Supabase.initialize(
         url: 'https://<TU_URL_PROYECTO>.supabase.co',
         anonKey: '<TU_ANON_KEY>',
       );
     }
   }
   ```

3. En Supabase SQL Editor, ejecuta este script para crear las tablas principales:

   ```sql
   create table if not exists products (
     id text primary key,
     code text,
     name text,
     category text,
     price double precision,
     updated_at timestamptz default now(),
     is_synced boolean default false
   );

   create table if not exists stock (
     id text primary key,
     product_id text references products(id),
     location_type text,
     location_id text,
     quantity int,
     updated_at timestamptz default now(),
     is_synced boolean default false
   );

   create table if not exists sales (
     id text primary key,
     product_id text references products(id),
     quantity int,
     total double precision,
     date timestamptz default now(),
     updated_at timestamptz default now(),
     is_synced boolean default false
   );

   create table if not exists purchases (
     id text primary key,
     product_id text references products(id),
     quantity int,
     total double precision,
     date timestamptz default now(),
     updated_at timestamptz default now(),
     is_synced boolean default false
   );
   ```

4. (Opcional) En **Database → Settings**, haz clic en **Reset API cache** si ves errores de columnas no encontradas.

---

## 🧩 Estructura de carpetas

```
lib/
├── core/
│   └── config/
│       └── supabase_config.dart
├── data/
│   ├── db/
│   │   ├── database.dart
│   │   └── tables/
│   │       ├── products.dart
│   │       ├── sales.dart
│   │       ├── purchases.dart
│   │       ├── stock.dart
│   │       └── sync_queue.dart
│   ├── repositories/
│   │   ├── products_repository.dart
│   │   ├── sales_repository.dart
│   │   ├── purchases_repository.dart
│   │   └── stock_repository.dart
│   └── services/
│       └── sync_service.dart
├── presentation/
│   ├── auth/
│   ├── features/
│   │   ├── products/
│   │   ├── sales/
│   │   ├── purchases/
│   │   ├── stock/
│   │   └── reports/
│   └── home/
└── main.dart
```

---

## 🧠 Comandos útiles

### ▶️ Ejecutar el proyecto
```bash
flutter run
```

### 🧹 Limpiar caché de compilación
```bash
flutter clean
flutter pub get
```

### 🧰 Generar código de Drift
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 🌐 Generar APK (debug)
```bash
flutter build apk --debug
```

### 📦 Generar APK (release)
```bash
flutter build apk --release
```

APK resultante:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔄 Sincronización Offline-First

La app usa un servicio personalizado (`SyncService`) que:
1. Detecta si hay conexión a Internet (`connectivity_plus`).
2. Envía las operaciones pendientes registradas en `sync_queue`.
3. Marca los registros sincronizados (`isSynced = true`).
4. Recibe actualizaciones en tiempo real desde Supabase Realtime.

Estructura básica:
```dart
final syncService = SyncService(db, Supabase.instance.client);
Connectivity().onConnectivityChanged.listen((status) {
  if (status != ConnectivityResult.none) {
    syncService.syncAll();
  }
});
syncService.initRealtime();
```

---

## 👥 Roles y pantallas

| Rol | Módulos disponibles |
|------|---------------------|
| **Admin** | Productos, Stock, Compras, Ventas, Reportes |
| **Store Manager** | Ventas, Reportes |
| **Warehouse Manager** | Compras, Reportes |

---

## 📱 Arquitectura interna

```
Flutter Widgets
   ↓
BLoC (AuthBloc, ProductsBloc, etc.)
   ↓
Repositories (AuthRepository, ProductsRepository, ...)
   ↓
Local DB (Drift)
   ↓↑
SyncService ↔ Supabase REST/Realtime
```

---

## 🔒 Seguridad (Supabase RLS)

Ejemplo de política segura para la tabla `users`:

```sql
create policy "select_update_own_user"
on users
for all
using (auth.uid() = auth_user_id);
```

---

## 📦 Dependencias principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.4
  drift: ^2.18.0
  drift_sqflite: ^2.2.0
  supabase_flutter: ^2.0.0
  connectivity_plus: ^6.0.1
  uuid: ^4.3.3
```

---

## 🧪 Modo Offline

- Si no hay conexión:
  - Todos los cambios se guardan en la base local (`isSynced = false`).
  - Los inserts generan registros en `sync_queue`.
- Al reconectarse:
  - El `SyncService` envía las operaciones pendientes.
  - Los datos remotos se actualizan automáticamente.
  - Supabase Realtime refleja cambios en tiempo real.

---

## 🧾 Licencia
Este proyecto fue desarrollado con fines educativos y demostrativos.  
Puedes modificarlo, adaptarlo o extenderlo para tu propia empresa o institución.

---

## 👨‍💻 Autor
**Desarrollado por:** Juan Enrique Dempsey Rivera Quisberth
**Universidad:** Catolica de Bolivia San Pablo
**Año:** 2025

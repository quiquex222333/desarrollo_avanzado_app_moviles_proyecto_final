import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventario_offline_first/presentation/auth/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importa tus módulos existentes
import 'package:inventario_offline_first/presentation/features/products/pages/products_page.dart';
import 'package:inventario_offline_first/presentation/features/stock/pages/stock_page.dart';
import 'package:inventario_offline_first/presentation/features/purchases/pages/purchases_page.dart';
import 'package:inventario_offline_first/presentation/features/sales/pages/sales_page.dart';
import 'package:inventario_offline_first/presentation/features/reports/pages/reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final db = RepositoryProvider.of<AppDatabase>(context);
    final authState = context.watch<AuthBloc>().state;

    // --- Si el usuario no está autenticado ---
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No autenticado',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // --- Usuario autenticado ---
    final User user = authState.user;
    final role = user.userMetadata?['role'] ?? 'employee';

    // --- Configura pestañas dinámicamente según el rol ---
    final List<Widget> pages = [];
    final List<NavigationDestination> tabs = [];

    if (role == 'admin') {
      pages.addAll([
        const ProductsPage(),
        const StockPage(),
        const PurchasesPage(),
        const SalesPage(),
        const ReportsPage(),
      ]);
      tabs.addAll([
        const NavigationDestination(
            icon: Icon(Icons.inventory), label: 'Productos'),
        const NavigationDestination(
            icon: Icon(Icons.warehouse), label: 'Stock'),
        const NavigationDestination(
            icon: Icon(Icons.shopping_cart), label: 'Compras'),
        const NavigationDestination(
            icon: Icon(Icons.point_of_sale), label: 'Ventas'),
        const NavigationDestination(
            icon: Icon(Icons.bar_chart), label: 'Reportes'),
      ]);
    } else if (role == 'employee') {
      pages.addAll([
        const SalesPage(),
        const ReportsPage(),
      ]);
      tabs.addAll([
        const NavigationDestination(
            icon: Icon(Icons.point_of_sale), label: 'Ventas'),
        const NavigationDestination(
            icon: Icon(Icons.bar_chart), label: 'Reportes'),
      ]);
    } else if (role == 'warehouse_manager') {
      pages.addAll([
        const PurchasesPage(),
        const ReportsPage(),
      ]);
      tabs.addAll([
        const NavigationDestination(
            icon: Icon(Icons.shopping_cart), label: 'Compras'),
        const NavigationDestination(
            icon: Icon(Icons.bar_chart), label: 'Reportes'),
      ]);
    } else {
      // Si no tiene un rol reconocido
      return Scaffold(
        body: Center(
          child: Text(
            'Rol no autorizado: $role',
            style: const TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
        ),
      );
    }

    // --- Interfaz principal ---
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario Offline-First ($role)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: tabs,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventario_offline_first/data/db/database.dart';
import 'package:inventario_offline_first/presentation/auth/bloc/auth_bloc.dart';
import 'package:inventario_offline_first/presentation/features/reports/pages/reports_page.dart';
import 'package:inventario_offline_first/presentation/features/sales/pages/sales_page.dart';
import 'package:inventario_offline_first/presentation/features/stock/pages/stock_page.dart'; // 👈 importa esta página
import '../features/products/pages/products_page.dart';
import '../features/purchases/pages/purchases_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final db = RepositoryProvider.of<AppDatabase>(context);
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated) {
      return const SizedBox.shrink();
    }

    final role = authState.role ?? '';

    final pages = <Widget>[];
    final tabs = <NavigationDestination>[];

    if (role == 'admin') {
      pages.addAll([
        const ProductsPage(),
        const StockPage(),      // ✅ agregado
        const PurchasesPage(),
        const SalesPage(),
        const ReportsPage(),
      ]);
      tabs.addAll([
        const NavigationDestination(
            icon: Icon(Icons.inventory), label: 'Productos'),
        const NavigationDestination(
            icon: Icon(Icons.warehouse), label: 'Stock'), // ✅ agregado
        const NavigationDestination(
            icon: Icon(Icons.shopping_cart), label: 'Compras'),
        const NavigationDestination(
            icon: Icon(Icons.point_of_sale), label: 'Ventas'),
        const NavigationDestination(
            icon: Icon(Icons.bar_chart), label: 'Reportes'),
      ]);
    } else if (role == 'store_manager') {
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
    }

    return Scaffold(
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

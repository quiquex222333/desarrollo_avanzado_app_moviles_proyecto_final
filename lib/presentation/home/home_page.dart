import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/db/database.dart';

// Repositorios
import '../../data/repositories/products_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/purchases_repository.dart';

// BLoCs
import '../features/products/bloc/products_bloc.dart';
import '../features/stock/bloc/stock_bloc.dart';
import '../features/purchases/bloc/purchases_bloc.dart';

// Páginas
import '../features/products/pages/products_page.dart';
import '../features/stock/pages/stock_page.dart';
import '../features/purchases/pages/purchases_page.dart';

class HomePage extends StatefulWidget {
  final AppDatabase db;
  const HomePage({super.key, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final db = widget.db;

    // ✅ Proveedores de repositorios globales
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: db),
        RepositoryProvider<ProductsRepository>(
            create: (_) => ProductsRepository(db)),
        RepositoryProvider<StockRepository>(
            create: (_) => StockRepository(db)),
        RepositoryProvider<PurchasesRepository>(
            create: (_) => PurchasesRepository(db)),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_selectedIndex)),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // 🧱 Productos
            BlocProvider(
              create: (ctx) =>
                  ProductsBloc(ctx.read<ProductsRepository>())..add(ProductsStarted()),
              child: const ProductsPage(),
            ),

            // 📦 Inventario
            BlocProvider(
              create: (ctx) =>
                  StockBloc(ctx.read<StockRepository>())..add(StockStarted()),
              child: const StockPage(),
            ),

            // 🧾 Compras
            BlocProvider(
              create: (ctx) =>
                  PurchasesBloc(ctx.read<PurchasesRepository>())..add(PurchasesStarted()),
              child: const PurchasesPage(),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Productos',
            ),
            NavigationDestination(
              icon: Icon(Icons.store_outlined),
              selectedIcon: Icon(Icons.store),
              label: 'Inventario',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Compras',
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Productos';
      case 1:
        return 'Inventario';
      case 2:
        return 'Compras';
      default:
        return 'Inventario';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventario_offline_first/data/repositories/products_repository.dart';
import 'package:inventario_offline_first/presentation/features/products/bloc/products_bloc.dart' hide Status;
import 'package:inventario_offline_first/presentation/features/products/pages/products_page.dart';
import '../../../../data/repositories/stock_repository.dart';
import '../../../../data/db/database.dart';
import '../bloc/stock_bloc.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) =>
          StockRepository(RepositoryProvider.of<AppDatabase>(context)),
      child: BlocProvider(
        create: (ctx) =>
            StockBloc(ctx.read<StockRepository>())..add(StockStarted()),
        child: const _StockView(),
      ),
    );
  }
}

class _StockView extends StatelessWidget {
  const _StockView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Gestionar productos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RepositoryProvider.value(
                    value: RepositoryProvider.of<AppDatabase>(context),
                    child: BlocProvider(
                      create: (ctx) => ProductsBloc(
                        ProductsRepository(
                            RepositoryProvider.of<AppDatabase>(context)),
                      )..add(ProductsStarted()),
                      child: const ProductsPage(),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Eliminar base local',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Eliminar base local?'),
                  content: const Text(
                      'Esto borrará completamente todos los datos almacenados localmente.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await deleteLocalDatabase();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Base local eliminada. Reinicia la app.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),

      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state.status == Status.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Sin stock registrado'));
          }

          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final item = state.items[i];
              return ListTile(
                title: Text(item['product']),
                subtitle: Text(
                  'Cantidad: ${item['quantity']} | '
                  '${item['storeId'] != null ? 'Tienda' : 'Almacén'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.read<StockBloc>().add(
                        StockQuantityUpdated(item['id'], item['quantity'] + 1));
                  },
                ),
              );
            },
          );
        },
      ),

      // ➕ Botón para registrar stock
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 1️⃣ Capturar bloc y DB antes del diálogo
          final stockBloc = context.read<StockBloc>();
          final db = RepositoryProvider.of<AppDatabase>(context);
          final products = await db.productsDao.getAll();
          print('PRODUCTOS DISPONIBLES: $products');
          final stock = await db.stockDao.getAll();
          print('STOCK DISPONIBLE: $stock');

          if (products.isEmpty) {
            // Si no hay productos, avisamos al usuario
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Primero crea un producto.')),
              );
            }
            return;
          }

          showDialog(
            context: context,
            builder: (ctx) {
              String? selectedProductId;
              double qty = 0;

              return AlertDialog(
                title: const Text('Agregar entrada de stock'),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return SizedBox(
                      width: 400,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar producto',
                            ),
                            items: products.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id, // ✅ ID real del producto
                                child: Text(p.name),
                              );
                            }).toList(),
                            onChanged: (v) => selectedProductId = v,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Cantidad a agregar',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (v) =>
                                qty = double.tryParse(v.trim()) ?? 0.0,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedProductId != null && qty > 0) {
                        // 2️⃣ Usar bloc externo directamente
                        stockBloc.add(StockAdded(selectedProductId!, qty));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

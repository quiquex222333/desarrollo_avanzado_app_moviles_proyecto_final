import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/purchases_repository.dart';
import '../../../../data/db/database.dart';
import '../bloc/purchases_bloc.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) =>
          PurchasesRepository(RepositoryProvider.of<AppDatabase>(context)),
      child: BlocProvider(
        create: (ctx) => PurchasesBloc(ctx.read<PurchasesRepository>())
          ..add(PurchasesStarted()),
        child: const _PurchasesView(),
      ),
    );
  }
}

class _PurchasesView extends StatelessWidget {
  const _PurchasesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      body: BlocBuilder<PurchasesBloc, PurchasesState>(
        builder: (context, state) {
          if (state.status == PurchasesStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.purchases.isEmpty) {
            return const Center(child: Text('Sin compras registradas'));
          }
          return ListView.builder(
            itemCount: state.purchases.length,
            itemBuilder: (_, i) {
              final p = state.purchases[i];
              return ListTile(
                title: Text('Compra #${p['id']}'),
                subtitle: Text('Total: \$${p['total']}'),
                trailing: Text(p['date'].toString().split(' ').first),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPurchaseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewPurchaseDialog(BuildContext context) async {
    final purchasesBloc = context.read<PurchasesBloc>();
    final db = RepositoryProvider.of<AppDatabase>(context);

    // obtener productos desde Drift
    final products = await db.productsDao.getAll();
    if (products.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primero registra productos.')),
        );
      }
      return;
    }

    final formKey = GlobalKey<FormState>();
    final List<Map<String, dynamic>> items = [];
    double total = 0;
    String? selectedSupplier;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          void recalcTotal() {
            total = items.fold(0, (sum, i) => sum + i['price'] * i['quantity']);
            setState(() {});
          }

          return AlertDialog(
            title: const Text('Registrar compra'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // proveedor simple
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Proveedor (opcional)'),
                      onChanged: (v) => selectedSupplier = v,
                    ),
                    const SizedBox(height: 12),

                    // lista dinámica de productos
                    ...items.map((item) {
                      return ListTile(
                        title: Text(
                          products
                                  .firstWhere((p) => p.id == item['productId'])
                                  .name ??
                              'Producto',
                        ),
                        subtitle: Text(
                            'Cant: ${item['quantity']} x \$${item['price']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              items.remove(item);
                              recalcTotal();
                            });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // botón para agregar un producto
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar producto'),
                      onPressed: () {
                        String? selectedProduct;
                        double qty = 1;
                        double price = 0;

                        showDialog(
                          context: ctx,
                          builder: (pctx) {
                            return AlertDialog(
                              title: const Text('Agregar producto'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        labelText: 'Producto'),
                                    items: products.map((p) {
                                      return DropdownMenuItem<String>(
                                        value: p.id,
                                        child: Text(p.name),
                                      );
                                    }).toList(),
                                    onChanged: (v) => selectedProduct = v,
                                    validator: (v) => v == null
                                        ? 'Selecciona un producto'
                                        : null,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Cantidad'),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (v) =>
                                        qty = double.tryParse(v) ?? 1,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Precio unitario'),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (v) =>
                                        price = double.tryParse(v) ?? 0,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(pctx),
                                    child: const Text('Cancelar')),
                                ElevatedButton(
                                  onPressed: () {
                                    if (selectedProduct != null) {
                                      setState(() {
                                        items.add({
                                          'productId': selectedProduct,
                                          'quantity': qty,
                                          'price': price,
                                        });
                                        recalcTotal();
                                      });
                                      Navigator.pop(pctx);
                                    }
                                  },
                                  child: const Text('Agregar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                onPressed: () {
                  if (items.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('Agrega al menos un producto.')));
                    return;
                  }
                  purchasesBloc.add(PurchaseCreated(
                      selectedSupplier, List.from(items), total));
                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        });
      },
    );
  }
}

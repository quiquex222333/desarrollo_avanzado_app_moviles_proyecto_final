import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/db/database.dart';
import '../../../../data/repositories/sales_repository.dart';
import '../bloc/sales_bloc.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => SalesRepository(RepositoryProvider.of<AppDatabase>(context)),
      child: BlocProvider(
        create: (ctx) => SalesBloc(ctx.read<SalesRepository>())..add(SalesStarted()),
        child: const _SalesView(),
      ),
    );
  }
}

class _SalesView extends StatelessWidget {
  const _SalesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state.status == SalesStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.sales.isEmpty) {
            return const Center(child: Text('Sin ventas registradas'));
          }
          return ListView.builder(
            itemCount: state.sales.length,
            itemBuilder: (_, i) {
              final s = state.sales[i];
              return ListTile(
                title: Text('Venta #${s['id']}'),
                subtitle: Text('Cliente: ${s['customer']}'),
                trailing: Text('\$${s['total']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_sale_btn',
        onPressed: () => _showNewSaleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewSaleDialog(BuildContext context) async {
    final salesBloc = context.read<SalesBloc>();
    final db = RepositoryProvider.of<AppDatabase>(context);
    final products = await db.productsDao.getAll();
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero registra productos.')),
      );
      return;
    }

    final List<Map<String, dynamic>> items = [];
    double total = 0;
    String? customerName;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          void recalcTotal() {
            total = items.fold(0, (sum, i) => sum + i['price'] * i['quantity']);
            setState(() {});
          }

          return AlertDialog(
            title: const Text('Registrar venta'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Cliente (opcional)'),
                      onChanged: (v) => customerName = v,
                    ),
                    const SizedBox(height: 12),
                    ...items.map((item) {
                      return ListTile(
                        title: Text(products
                            .firstWhere((p) => p.id == item['productId'])
                            .name),
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
                                          'productId': selectedProduct!,
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
                    Text('Total: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
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
                  salesBloc
                      .add(SaleCreated(customerName, List.from(items), total));
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

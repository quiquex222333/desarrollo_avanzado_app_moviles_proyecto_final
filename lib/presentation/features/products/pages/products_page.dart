import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/db/database.dart';
import '../../../../data/repositories/products_repository.dart';
import '../bloc/products_bloc.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ProductsRepository(RepositoryProvider.of<AppDatabase>(context)),
      child: BlocProvider(
        create: (ctx) =>
            ProductsBloc(ctx.read<ProductsRepository>())..add(ProductsStarted()),
        child: Scaffold(
          appBar: AppBar(title: const Text('Productos')),
          body: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              final items = state.items;
              if (state.status == Status.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (items.isEmpty) return const Center(child: Text('Sin productos'));
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  title: Text(items[i].name),
                  subtitle: Text('${items[i].code} • ${items[i].category}'),
                  trailing: Text('\$${items[i].price.toStringAsFixed(2)}'),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.read<ProductsBloc>().add(ProductCreated(
                    code: 'P-${DateTime.now().millisecondsSinceEpoch}',
                    name: 'Producto demo',
                    category: 'pisopak',
                    price: 10,
                  ));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

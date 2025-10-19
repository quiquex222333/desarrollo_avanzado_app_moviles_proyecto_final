import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/db/database.dart';
import 'data/repositories/products_repository.dart';
import 'presentation/features/products/pages/products_page.dart';
import 'presentation/features/products/bloc/products_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Creamos la base local
  final db = AppDatabase();

  // Inyectamos dependencias globalmente
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: db),
        RepositoryProvider<ProductsRepository>(
          create: (_) => ProductsRepository(db),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Offline First',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: BlocProvider(
        create: (context) => ProductsBloc(
          context.read<ProductsRepository>(),
        )..add(ProductsStarted()),
        child: const ProductsPage(),
      ),
    );
  }
}

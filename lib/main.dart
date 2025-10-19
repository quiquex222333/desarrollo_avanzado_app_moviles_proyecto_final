import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/db/database.dart';
import 'data/repositories/stock_repository.dart';
import 'presentation/features/stock/bloc/stock_bloc.dart';
import 'presentation/features/stock/pages/stock_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la base local
  final db = AppDatabase();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: db),
        RepositoryProvider<StockRepository>(
          create: (_) => StockRepository(db),
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
        create: (context) =>
            StockBloc(context.read<StockRepository>())..add(StockStarted()),
        child: const StockPage(),
      ),
    );
  }
}

// P-1760891018479
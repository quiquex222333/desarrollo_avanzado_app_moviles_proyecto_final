import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventario_offline_first/presentation/home/home_page.dart';
import 'data/db/database.dart';
import 'data/repositories/stock_repository.dart';

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
      child: MyApp(db: db),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppDatabase db;
  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Offline First',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: HomePage(db: db),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'data/services/sync_service.dart';

import 'package:inventario_offline_first/core/config/supabase_config.dart';
import 'package:inventario_offline_first/data/repositories/auth_repository.dart';
import 'package:inventario_offline_first/global_connectivity.dart';
import 'package:inventario_offline_first/presentation/auth/bloc/auth_bloc.dart';
import 'package:inventario_offline_first/presentation/auth/pages/auth_page.dart';
import 'package:inventario_offline_first/presentation/home/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // 👈 alias agregado
import 'data/db/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();

  // Inicializa base de datos y repositorio
  final db = AppDatabase();
  final supabaseClient = supabase.Supabase.instance.client; // 👈 usa el alias
  final syncService = SyncService(db, supabaseClient);

  // Inicia listener de conexión
  Connectivity().onConnectivityChanged.listen((status) {
    if (status != ConnectivityResult.none) {
      print('🌐 Conectado — sincronizando...');
      syncService.syncAll();
    }
  });

  // Activa realtime
  syncService.initRealtime();

  final authRepo = AuthRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: db),
        RepositoryProvider.value(value: authRepo),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authRepo)..add(AuthStarted()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Offline-First',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

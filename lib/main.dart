import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:inventario_offline_first/presentation/auth/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// 🔥 Firebase
import 'core/firebase/firebase.dart';

import 'core/config/supabase_config.dart';
import 'data/db/database.dart';
import 'data/services/sync_service.dart';
import 'data/repositories/auth_repository.dart';

import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebaseApp();

  // Inicializa Supabase
  await SupabaseConfig.init();
  final supabaseClient = supabase.Supabase.instance.client;

  // Inicializa base de datos local (offline)
  final db = AppDatabase();

  // Servicio de sincronización
  final syncService = SyncService(db, supabaseClient);

  // Listener de conectividad
  Connectivity().onConnectivityChanged.listen((status) {
    if (status != ConnectivityResult.none) {
      print('🌐 Conectado — sincronizando...');
      syncService.syncAll();
    }
  });

  // Activa realtime
  syncService.initRealtime();

  // Repositorio de autenticación
  final authRepository = AuthRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: db),
        RepositoryProvider.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(authRepository)),
        ],
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
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthGate(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

/// Widget que decide a qué pantalla ir según el estado de autenticación
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthAuthenticated) {
          return const HomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

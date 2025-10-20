import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

  /// Inicia sesión
  Future<AuthResponse> login(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // ✅ Guardar la sesión como JSON string si existe
    if (res.session != null) {
      final sessionString = jsonEncode(res.session!.toJson());
      await _storage.write(key: 'session', value: sessionString);
    }

    return res;
  }

  /// Obtiene el rol del usuario autenticado
  Future<String?> getUserRole() async {
    final user = _supabase.auth.currentUser;

    // 🚨 Si no hay usuario autenticado, no consultar la tabla
    if (user == null) {
      print('⚠️ Intento de obtener rol sin sesión activa');
      return null;
    }

    try {
      final res = await _supabase
          .from('users')
          .select('role')
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (res == null) return null;
      return res['role'] as String?;
    } on PostgrestException catch (e) {
      print('❌ Error al obtener rol: ${e.message}');
      return null;
    } catch (e) {
      print('❌ Error desconocido en getUserRole: $e');
      return null;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _storage.delete(key: 'session');
  }

  /// Usuario autenticado actual
  User? get currentUser => _supabase.auth.currentUser;

  /// Restaura sesión previa desde almacenamiento seguro
  Future<void> restoreSession() async {
    final storedSession = await _storage.read(key: 'session');

    // 🚨 Evitar llamadas vacías
    if (storedSession == null || storedSession.isEmpty) {
      print('⚠️ No hay sesión almacenada para restaurar');
      return;
    }

    try {
      final res = await _supabase.auth.recoverSession(storedSession);

      if (res.session != null) {
        final newSessionString = jsonEncode(res.session!.toJson());
        await _storage.write(key: 'session', value: newSessionString);
      }
    } on AuthException catch (e) {
      print('❌ Error de sesión Supabase: ${e.message}');
    } catch (e) {
      print('❌ Error desconocido al restaurar sesión: $e');
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final _secureStorage = const FlutterSecureStorage();

  // Registro de usuario con validación de seguridad
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    if (!_validatePassword(password)) {
      throw Exception(
          'La contraseña no cumple con los requisitos de seguridad.');
    }

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'role': role, 'name': name},
    );

    if (response.user == null) {
      throw Exception('Error al registrar usuario');
    }

    // Guardar sesión de forma segura
    await _secureStorage.write(
        key: 'access_token', value: response.session?.accessToken);
    return response;
  }

  // Login seguro
  Future<AuthResponse> signIn(String email, String password) async {
    final response =
        await _client.auth.signInWithPassword(email: email, password: password);

    if (response.session == null) {
      throw Exception('Credenciales inválidas');
    }

    await _secureStorage.write(
        key: 'access_token', value: response.session!.accessToken);
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await _secureStorage.delete(key: 'access_token');
  }

  Future<User?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    return user;
  }

  // Validación de complejidad de contraseña (8+, mayúscula, minúscula, número, carácter especial)
  bool _validatePassword(String password) {
    final regex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }
}

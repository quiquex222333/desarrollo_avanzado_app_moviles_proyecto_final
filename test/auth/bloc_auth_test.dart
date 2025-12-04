import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:inventario_offline_first/presentation/auth/bloc/auth_bloc.dart';
import 'package:inventario_offline_first/data/repositories/auth_repository.dart';

// Prefijo para evitar conflicto con AuthState de Supabase
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// ---------------------------------------------------------------------------
// MOCKS
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements supabase.User {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;
  late MockUser mockUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  // ---------------------------------------------------------------------------
  // LOGIN TESTS (signIn: POSICIONAL)
  // ---------------------------------------------------------------------------

  group("AuthBloc - Login", () {
    blocTest<AuthBloc, AuthState>(
      "emits [AuthLoading, AuthAuthenticated] when login succeeds",
      setUp: () {
        when(() => mockAuthRepository.signIn(
              "test@mail.com",
              "123456",
            )).thenAnswer(
          (_) async => supabase.AuthResponse(user: mockUser),
        );
      },
      build: () => authBloc,
      act: (bloc) =>
          bloc.add(const LoginRequested("test@mail.com", "123456")),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "emits [AuthLoading, AuthError] when login fails",
      setUp: () {
        when(() => mockAuthRepository.signIn(
              any(),
              any(),
            )).thenThrow(Exception("Login failed"));
      },
      build: () => authBloc,
      act: (bloc) =>
          bloc.add(const LoginRequested("wrong", "wrong")),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ---------------------------------------------------------------------------
  // REGISTER TESTS (signUp: NOMBRADOS)
  // ---------------------------------------------------------------------------

  group("AuthBloc - Register", () {
    blocTest<AuthBloc, AuthState>(
      "emits [AuthLoading, AuthAuthenticated] when registration succeeds",
      setUp: () {
        when(() => mockAuthRepository.signUp(
              email: "new@mail.com",
              password: "123456",
              name: "Test User",
              role: "admin",
            )).thenAnswer(
          (_) async => supabase.AuthResponse(user: mockUser),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const RegisterRequested(
          "Test User",
          "new@mail.com",
          "123456",
          "admin",
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      "emits [AuthLoading, AuthError] when registration fails",
      setUp: () {
        when(() => mockAuthRepository.signUp(
              email: any(named: "email"),
              password: any(named: "password"),
              name: any(named: "name"),
              role: any(named: "role"),
            )).thenThrow(Exception("Registration failed"));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const RegisterRequested(
          "bad",
          "bad",
          "bad",
          "admin",
        ),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // ---------------------------------------------------------------------------
  // LOGOUT TESTS
  // ---------------------------------------------------------------------------

  group("AuthBloc - Logout", () {
    blocTest<AuthBloc, AuthState>(
      "returns AuthInitial after logout",
      setUp: () {
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => {});
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthInitial>(),
      ],
    );
  });
}

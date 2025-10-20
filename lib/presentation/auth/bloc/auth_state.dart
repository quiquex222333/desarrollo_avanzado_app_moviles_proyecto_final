part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? email;
  final String? role;

  const AuthState({required this.status, this.email, this.role});

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.authenticated(String email, String role) =>
      AuthState(status: AuthStatus.authenticated, email: email, role: role);

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? role,
  }) =>
      AuthState(
        status: status ?? this.status,
        email: email ?? this.email,
        role: role ?? this.role,
      );

  @override
  List<Object?> get props => [status, email, role];
}

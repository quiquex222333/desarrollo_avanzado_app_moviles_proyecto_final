import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthState.initial()) {
    // 🔹 Evento de inicio de la app
    on<AuthStarted>((event, emit) async {
      try {
        await repo.restoreSession();
        final user = repo.currentUser;

        if (user != null) {
          final role = await repo.getUserRole();
          emit(AuthState.authenticated(user.email ?? '', role ?? ''));
        } else {
          emit(AuthState.unauthenticated());
        }
      } catch (e) {
        print('⚠️ Error en AuthStarted: $e');
        emit(AuthState.unauthenticated());
      }
    });

    // 🔹 Login
    on<AuthLoginRequested>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));
      try {
        await repo.login(event.email, event.password);
        final user = repo.currentUser;
        if (user != null) {
          final role = await repo.getUserRole();
          emit(AuthState.authenticated(user.email ?? '', role ?? ''));
        } else {
          emit(state.copyWith(status: AuthStatus.failure));
        }
      } catch (e) {
        print('❌ Error en AuthLoginRequested: $e');
        emit(state.copyWith(status: AuthStatus.failure));
      }
    });

    // 🔹 Logout
    on<AuthLogoutRequested>((event, emit) async {
      await repo.logout();
      emit(AuthState.unauthenticated());
    });
  }
}

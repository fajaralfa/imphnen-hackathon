import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imphenhackaton/features/auth/domain/entities/user_entity.dart';
import 'package:imphenhackaton/features/auth/domain/usecases/get_current_user.dart';
import 'package:imphenhackaton/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:imphenhackaton/features/auth/domain/usecases/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
  })  : _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(const AuthState()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _signInWithGoogle();

    result.fold(
      (failure) {
        print('=== AUTH BLOC FAILURE ===');
        print('Failure type: ${failure.runtimeType}');
        print('Failure props: ${failure.properties}');
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.properties.isNotEmpty
                ? failure.properties.first.toString()
                : 'Gagal masuk dengan Google',
          ),
        );
      },
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _signOut();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Gagal keluar',
        ),
      ),
      (_) => emit(
        const AuthState(status: AuthStatus.unauthenticated),
      ),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _getCurrentUser();

    result.fold(
      (failure) => emit(
        const AuthState(status: AuthStatus.unauthenticated),
      ),
      (user) {
        if (user != null) {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
            ),
          );
        } else {
          emit(
            const AuthState(status: AuthStatus.unauthenticated),
          );
        }
      },
    );
  }
}

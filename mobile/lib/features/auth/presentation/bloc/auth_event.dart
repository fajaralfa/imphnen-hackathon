part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Sign in with Google
class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

/// Sign out
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Check current authentication status
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

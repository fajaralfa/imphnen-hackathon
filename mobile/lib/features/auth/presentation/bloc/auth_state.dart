part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Get user's display name or email
  String get displayName => user?.displayName ?? user?.email ?? '';

  /// Get user's token for API calls
  String? get token => user?.token;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

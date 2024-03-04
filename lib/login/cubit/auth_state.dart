part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class Authenticated extends AuthState {
  final User user;

  Authenticated(this.user);
}

final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

final class AuthLoading extends AuthState {}

final class AuthSignedOut extends AuthState {}

final class AuthSignedOutError extends AuthState {
  final String message;

  AuthSignedOutError(this.message);
}

final class AuthSignedOutLoading extends AuthState {}

final class AuthSignedOutSuccess extends AuthState {}

final class AuthSignedOutUnauthenticated extends AuthState {}

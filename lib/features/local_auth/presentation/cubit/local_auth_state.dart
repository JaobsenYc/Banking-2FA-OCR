part of 'local_auth_cubit.dart';

sealed class LocalAuthState extends Equatable {
  const LocalAuthState();

  @override
  List<Object> get props => [];
}

final class LocalAuthInitial extends LocalAuthState {}

final class LocalAuthLoading extends LocalAuthState {}

final class LocalAuthDone extends LocalAuthState {
  final bool res;

  const LocalAuthDone(this.res);

  @override
  List<Object> get props => [res];
}

final class LocalCanNotAuthenticate extends LocalAuthState {}

final class LocalAuthError extends LocalAuthState {
  final String? message;

  const LocalAuthError(this.message);

  @override
  List<Object> get props => [message ?? ''];
}

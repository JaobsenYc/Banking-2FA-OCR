import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

part 'local_auth_state.dart';

class LocalAuthCubit extends Cubit<LocalAuthState> {
  LocalAuthCubit() : super(LocalAuthInitial());
  final LocalAuthentication auth = LocalAuthentication();

  void checkBiometrics() async {
    if( state is LocalAuthLoading) return;
    emit(LocalAuthLoading());
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      if (canAuthenticate) {
        final res = await auth.authenticate(
          localizedReason: "Please authenticate to login",
          options: const AuthenticationOptions(
          ),
        );
        emit( LocalAuthDone(res));
      }
      emit(LocalCanNotAuthenticate());
    } on PlatformException catch (e) {
      emit(LocalAuthError(e.message));
    } catch (e) {
      emit(LocalAuthError(e.toString()));
    }
  }
}

import 'package:motunge/model/auth/enum/auth_state.dart';
import 'package:motunge/model/auth/profile_response.dart';

abstract class AuthBlocState {
  const AuthBlocState();
}

class AuthInitial extends AuthBlocState {
  const AuthInitial();
}

class AuthLoading extends AuthBlocState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthBlocState {
  final AuthStatus status;
  final ProfileResponse? profile;

  const AuthAuthenticated({
    required this.status,
    this.profile,
  });
}

class AuthUnauthenticated extends AuthBlocState {
  const AuthUnauthenticated();
}

class AuthNeedRegister extends AuthBlocState {
  const AuthNeedRegister();
}

class AuthError extends AuthBlocState {
  final String message;

  const AuthError({required this.message});
}

class AuthLoginSuccess extends AuthBlocState {
  final bool isUserRegistered;

  const AuthLoginSuccess({required this.isUserRegistered});
}

class AuthRegisterSuccess extends AuthBlocState {
  const AuthRegisterSuccess();
}

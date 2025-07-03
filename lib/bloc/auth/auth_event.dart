abstract class AuthEvent {
  const AuthEvent();
}

class AuthLoginStatusChecked extends AuthEvent {
  const AuthLoginStatusChecked();
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

class AuthAppleLoginRequested extends AuthEvent {
  const AuthAppleLoginRequested();
}

class AuthRegisterRequested extends AuthEvent {
  final String nickname;

  const AuthRegisterRequested({required this.nickname});
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthProfileRequested extends AuthEvent {
  const AuthProfileRequested();
}

class AuthNicknameChangeRequested extends AuthEvent {
  final String nickname;

  const AuthNicknameChangeRequested({required this.nickname});
}

class AuthAccountDeleteRequested extends AuthEvent {
  const AuthAccountDeleteRequested();
}

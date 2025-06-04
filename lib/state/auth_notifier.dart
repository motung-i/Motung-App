import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/auth_state.dart';
import 'package:motunge/model/auth/google_oauth_response.dart';
import 'package:motunge/model/auth/token_refresh_request.dart';

class AuthNotifier extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  AuthNotifier() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refreshToken');

    if (refreshToken == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final response = await AuthDataSource()
          .refreshToken(TokenRefreshRequest(refreshToken: refreshToken));
      await storage.write(key: 'accessToken', value: response.accessToken);
      await storage.write(key: 'refreshToken', value: response.refreshToken);

      final registerCheck = await AuthDataSource().checkRegister();
      _status = registerCheck.isUserRegistered
          ? AuthStatus.authenticated
          : AuthStatus.needRegister;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> login(GoogleOAuthLoginResponse response) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'refreshToken', value: response.refreshToken);
    await storage.write(key: 'accessToken', value: response.accessToken);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'refreshToken');
    await storage.delete(key: 'accessToken');
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> changeNickname() async {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}

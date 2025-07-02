import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/enum/auth_state.dart';
import 'package:motunge/model/auth/oauth_response.dart';
import 'package:motunge/model/auth/token_refresh_request.dart';
import 'package:motunge/constants/app_constants.dart';

class AuthNotifier extends ChangeNotifier {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  AuthStatus _status = AuthStatus.loading;
  AuthStatus get status => _status;

  AuthNotifier() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);

    if (refreshToken == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final response = await AuthDataSource()
          .refreshToken(TokenRefreshRequest(refreshToken: refreshToken));
      await _storage.write(
          key: AppConstants.accessTokenKey, value: response.accessToken);
      await _storage.write(
          key: AppConstants.refreshTokenKey, value: response.refreshToken);

      final registerCheck = await AuthDataSource().checkRegister();
      _status = registerCheck.isUserRegistered
          ? AuthStatus.authenticated
          : AuthStatus.needRegister;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> login(OAuthLoginResponse response) async {
    await _storage.write(
        key: AppConstants.refreshTokenKey, value: response.refreshToken);
    await _storage.write(
        key: AppConstants.accessTokenKey, value: response.accessToken);
    notifyListeners();
  }

  void setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.accessTokenKey);
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> changeNickname() async {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}

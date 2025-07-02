import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:motunge/model/auth/apple_oauth_request.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/enum/auth_state.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/oauth_response.dart';
import 'package:motunge/model/auth/profile_response.dart';
import 'package:motunge/model/auth/register_request.dart';
import 'package:motunge/routes/app_router.dart';

class AuthViewModel {
  final AuthDataSource _authDataSource = AuthDataSource();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// FCM 토큰을 가져오는 공통 메소드
  Future<String?> _getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
    return await FirebaseMessaging.instance.getToken();
  }

  /// 로그인 후 공통 처리 로직
  Future<bool> _handlePostLogin(OAuthLoginResponse loginResponse) async {
    await AppRouter.authNotifier.login(loginResponse);

    final isUserRegisterResponse = await _authDataSource.checkRegister();

    if (isUserRegisterResponse.isUserRegistered) {
      AppRouter.authNotifier.setStatus(AuthStatus.authenticated);
    } else {
      AppRouter.authNotifier.setStatus(AuthStatus.needRegister);
    }

    return isUserRegisterResponse.isUserRegistered;
  }

  Future<bool?> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final fcmToken = await _getFcmToken();

      final request = GoogleOAuthLoginRequest(
        accessToken: googleAuth.accessToken!,
        deviceToken: fcmToken,
      );

      final loginResponse = await _authDataSource.googleLogin(request);
      return await _handlePostLogin(loginResponse);
    } catch (e) {
      debugPrint('Google login error: $e');
      return null;
    }
  }

  Future<bool?> appleLogin() async {
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final fcmToken = await _getFcmToken();

      debugPrint('result: ${result.identityToken}');

      final loginResponse = await _authDataSource.appleLogin(
          AppleOAuthLoginRequest(
              identityToken: result.identityToken!, deviceToken: fcmToken));

      return await _handlePostLogin(loginResponse);
    } catch (e) {
      debugPrint('Apple login error: $e');
      return null;
    }
  }

  Future<void> register(String nickname) async {
    await _authDataSource.register(RegisterRequest(nickname: nickname));
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await AppRouter.authNotifier.logout();
  }

  Future<ProfileResponse> getProfile() async {
    return await _authDataSource.getProfile();
  }

  Future<void> changeNickname(String nickname) async {
    await _authDataSource.changeNickname(nickname);
  }

  Future<void> deleteAccount() async {
    await _authDataSource.deleteUser();
    await _googleSignIn.signOut();
    await AppRouter.authNotifier.logout();
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:motunge/model/auth/apple_oauth_request.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/enum/auth_state.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/profile_response.dart';
import 'package:motunge/model/auth/register_request.dart';
import 'package:motunge/routes/app_router.dart';

class AuthViewModel {
  final AuthDataSource _authDataSource = AuthDataSource();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<bool?> googleLogin() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    await FirebaseMessaging.instance.requestPermission();
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    final request = GoogleOAuthLoginRequest(
      accessToken: googleAuth.accessToken!,
      deviceToken: fcmToken,
    );

    final loginResponse = await _authDataSource.googleLogin(request);

    await AppRouter.authNotifier.login(loginResponse);

    final isUserRegisterResponse = await _authDataSource.checkRegister();

    if (isUserRegisterResponse.isUserRegistered) {
      AppRouter.authNotifier.setStatus(AuthStatus.authenticated);
    } else {
      AppRouter.authNotifier.setStatus(AuthStatus.needRegister);
    }

    return isUserRegisterResponse.isUserRegistered;
  }

  Future<bool?> appleLogin() async {
    final result = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    await FirebaseMessaging.instance.requestPermission();
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    debugPrint('result: ${result.identityToken}');

    final loginResponse = await _authDataSource.appleLogin(
        AppleOAuthLoginRequest(
            identityToken: result.identityToken!, deviceToken: fcmToken));

    await AppRouter.authNotifier.login(loginResponse);

    final isUserRegisterResponse = await _authDataSource.checkRegister();

    if (isUserRegisterResponse.isUserRegistered) {
      AppRouter.authNotifier.setStatus(AuthStatus.authenticated);
    } else {
      AppRouter.authNotifier.setStatus(AuthStatus.needRegister);
    }

    return isUserRegisterResponse.isUserRegistered;
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

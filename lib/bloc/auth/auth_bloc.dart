import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:motunge/bloc/auth/auth_event.dart';
import 'package:motunge/bloc/auth/auth_state.dart';
import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/apple_oauth_request.dart';
import 'package:motunge/model/auth/enum/auth_state.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/oauth_response.dart';
import 'package:motunge/model/auth/register_request.dart';
import 'package:motunge/model/auth/token_refresh_request.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final AuthDataSource _authDataSource = AuthDataSource();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  AuthBloc() : super(const AuthInitial()) {
    on<AuthLoginStatusChecked>(_onLoginStatusChecked);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthAppleLoginRequested>(_onAppleLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthProfileRequested>(_onProfileRequested);
    on<AuthNicknameChangeRequested>(_onNicknameChangeRequested);
    on<AuthAccountDeleteRequested>(_onAccountDeleteRequested);

    add(const AuthLoginStatusChecked());
  }

  Future<String?> _getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
    return await FirebaseMessaging.instance.getToken();
  }

  Future<bool> _handlePostLogin(OAuthLoginResponse loginResponse) async {
    await _storage.write(
        key: AppConstants.refreshTokenKey, value: loginResponse.refreshToken);
    await _storage.write(
        key: AppConstants.accessTokenKey, value: loginResponse.accessToken);

    final isUserRegisterResponse = await _authDataSource.checkRegister();
    return isUserRegisterResponse.isUserRegistered;
  }

  Future<void> _onLoginStatusChecked(
    AuthLoginStatusChecked event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final refreshToken =
          await _storage.read(key: AppConstants.refreshTokenKey);

      if (refreshToken == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final response = await _authDataSource
          .refreshToken(TokenRefreshRequest(refreshToken: refreshToken));
      await _storage.write(
          key: AppConstants.accessTokenKey, value: response.accessToken);
      await _storage.write(
          key: AppConstants.refreshTokenKey, value: response.refreshToken);

      final registerCheck = await _authDataSource.checkRegister();

      if (registerCheck.isUserRegistered) {
        try {
          final profile = await _authDataSource.getProfile();
          emit(AuthAuthenticated(
            status: AuthStatus.authenticated,
            profile: profile,
          ));
        } catch (e) {
          emit(const AuthAuthenticated(status: AuthStatus.authenticated));
        }
      } else {
        emit(const AuthNeedRegister());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(const AuthError(message: '구글 로그인이 취소되었습니다.'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final fcmToken = await _getFcmToken();

      final request = GoogleOAuthLoginRequest(
        accessToken: googleAuth.accessToken!,
        deviceToken: fcmToken,
      );

      final loginResponse = await _authDataSource.googleLogin(request);
      final isUserRegistered = await _handlePostLogin(loginResponse);

      if (isUserRegistered) {
        try {
          final profile = await _authDataSource.getProfile();
          emit(AuthAuthenticated(
            status: AuthStatus.authenticated,
            profile: profile,
          ));
        } catch (e) {
          emit(const AuthAuthenticated(status: AuthStatus.authenticated));
        }
      } else {
        emit(const AuthNeedRegister());
      }
    } catch (e) {
      debugPrint('Google login error: $e');
      emit(AuthError(message: '구글 로그인 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onAppleLoginRequested(
    AuthAppleLoginRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final fcmToken = await _getFcmToken();

      final loginResponse = await _authDataSource.appleLogin(
          AppleOAuthLoginRequest(
              identityToken: result.identityToken!, deviceToken: fcmToken));

      final isUserRegistered = await _handlePostLogin(loginResponse);

      if (isUserRegistered) {
        try {
          final profile = await _authDataSource.getProfile();
          emit(AuthAuthenticated(
            status: AuthStatus.authenticated,
            profile: profile,
          ));
        } catch (e) {
          emit(const AuthAuthenticated(status: AuthStatus.authenticated));
        }
      } else {
        emit(const AuthNeedRegister());
      }
    } catch (e) {
      debugPrint('Apple login error: $e');
      emit(AuthError(message: '애플 로그인 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authDataSource.register(RegisterRequest(nickname: event.nickname));
      emit(const AuthRegisterSuccess());

      try {
        final profile = await _authDataSource.getProfile();
        emit(AuthAuthenticated(
          status: AuthStatus.authenticated,
          profile: profile,
        ));
      } catch (e) {
        emit(const AuthAuthenticated(status: AuthStatus.authenticated));
      }
    } catch (e) {
      emit(AuthError(message: '회원가입 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _googleSignIn.signOut();
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.accessTokenKey);
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: '로그아웃 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onProfileRequested(
    AuthProfileRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    try {
      final profile = await _authDataSource.getProfile();
      emit(AuthAuthenticated(
        status: AuthStatus.authenticated,
        profile: profile,
      ));
    } catch (e) {
      emit(AuthError(message: '프로필 조회 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onNicknameChangeRequested(
    AuthNicknameChangeRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authDataSource.changeNickname(event.nickname);

      final profile = await _authDataSource.getProfile();
      emit(AuthAuthenticated(
        status: AuthStatus.authenticated,
        profile: profile,
      ));
    } catch (e) {
      emit(AuthError(message: '닉네임 변경 중 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _onAccountDeleteRequested(
    AuthAccountDeleteRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authDataSource.deleteUser();
      await _googleSignIn.signOut();
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.accessTokenKey);
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: '계정 삭제 중 오류가 발생했습니다: $e'));
    }
  }
}

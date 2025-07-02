import 'package:motunge/dataSource/base_data_source.dart';
import 'package:motunge/model/auth/apple_oauth_request.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/oauth_response.dart';
import 'package:motunge/model/auth/is_user_register_response.dart';
import 'package:motunge/model/auth/profile_response.dart';
import 'package:motunge/model/auth/register_request.dart';
import 'package:motunge/model/auth/token_refresh_request.dart';
import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/utils/error_handler.dart';

class AuthDataSource extends BaseDataSource {
  Future<OAuthLoginResponse> googleLogin(
      GoogleOAuthLoginRequest request) async {
    try {
      final response = await dio.post(
        getUrl(AppConstants.authGoogleLoginEndpoint),
        data: request.toJson(),
      );
      return OAuthLoginResponse.fromJson(response.data);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<OAuthLoginResponse> appleLogin(AppleOAuthLoginRequest request) async {
    try {
      final response = await dio.post(
        getUrl(AppConstants.authAppleLoginEndpoint),
        data: request.toJson(),
      );
      return OAuthLoginResponse.fromJson(response.data);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<IsUserRegisterResponse> checkRegister() async {
    try {
      final response =
          await dio.get(getUrl(AppConstants.authCheckRegisterEndpoint));
      return IsUserRegisterResponse.fromJson(response.data);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      await dio.post(getUrl(AppConstants.authRegisterEndpoint), data: request);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<OAuthLoginResponse> refreshToken(TokenRefreshRequest request) async {
    try {
      final response = await dio.post(
        getUrl(AppConstants.authRefreshEndpoint),
        data: request.toJson(),
      );
      return OAuthLoginResponse.fromJson(response.data);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<void> logout() async {
    try {
      await dio.post(getUrl(AppConstants.authLogoutEndpoint));
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await dio.delete(getUrl(AppConstants.authDeleteAccountEndpoint));
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<ProfileResponse> getProfile() async {
    try {
      final response = await dio.get(getUrl(AppConstants.userEndpoint));
      return ProfileResponse.fromJson(response.data);
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<void> changeNickname(String nickname) async {
    try {
      await dio.patch(getUrl(AppConstants.userNicknameEndpoint), data: {
        'nickname': nickname,
      });
    } catch (e) {
      throw AppError.fromException(e);
    }
  }

  Future<void> deleteUser() async {
    try {
      await dio.delete(getUrl(AppConstants.userEndpoint));
    } catch (e) {
      throw AppError.fromException(e);
    }
  }
}

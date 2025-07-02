import 'package:motunge/dataSource/base_data_source.dart';
import 'package:motunge/model/auth/apple_oauth_request.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/oauth_response.dart';
import 'package:motunge/model/auth/is_user_register_response.dart';
import 'package:motunge/model/auth/profile_response.dart';
import 'package:motunge/model/auth/register_request.dart';
import 'package:motunge/model/auth/token_refresh_request.dart';

class AuthDataSource extends BaseDataSource {
  Future<OAuthLoginResponse> googleLogin(
      GoogleOAuthLoginRequest request) async {
    final response = await dio.post(getUrl('/auth/google/login/callback'),
        data: request.toJson());
    return OAuthLoginResponse.fromJson(response.data);
  }

  Future<OAuthLoginResponse> appleLogin(AppleOAuthLoginRequest request) async {
    final response = await dio.post(getUrl('/auth/apple/login/callback'),
        data: request.toJson());
    return OAuthLoginResponse.fromJson(response.data);
  }

  Future<IsUserRegisterResponse> checkRegister() async {
    final response = await dio.get(getUrl('/auth/check-register'));
    return IsUserRegisterResponse.fromJson(response.data);
  }

  Future<void> register(RegisterRequest request) async {
    await dio.post(getUrl('/auth/register'), data: request);
  }

  Future<OAuthLoginResponse> refreshToken(TokenRefreshRequest request) async {
    final response =
        await dio.post(getUrl('/auth/refresh'), data: request.toJson());
    return OAuthLoginResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await dio.post(getUrl('/auth/logout'));
  }

  Future<void> deleteAccount() async {
    await dio.delete(getUrl('/auth/delete-account'));
  }

  Future<ProfileResponse> getProfile() async {
    final response = await dio.get(getUrl('/user'));
    return ProfileResponse.fromJson(response.data);
  }

  Future<void> changeNickname(String nickname) async {
    await dio.patch(getUrl('/user/nickname'), data: {
      'nickname': nickname,
    });
  }

  Future<void> deleteUser() async {
    await dio.delete(getUrl('/user'));
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/google_oauth_response.dart';
import 'package:motunge/model/auth/is_user_register_response.dart';
import 'package:motunge/model/auth/register_request.dart';
import 'package:motunge/model/auth/token_refresh_request.dart';
import 'package:motunge/network/dio.dart';

class AuthDataSource {
  final dio = AppDio.getInstance();

  Future<GoogleOAuthLoginResponse> googleLogin(
      GoogleOAuthLoginRequest request) async {
    final response = await dio.post('${dotenv.env['API_URL']}/auth/login',
        data: request.toJson());
    return GoogleOAuthLoginResponse.fromJson(response.data);
  }

  Future<IsUserRegisterResponse> checkRegister() async {
    final response =
        await dio.get('${dotenv.env['API_URL']}/auth/check-register');
    return IsUserRegisterResponse.fromJson(response.data);
  }

  Future<void> register(RegisterRequest request) async {
    await dio.post('${dotenv.env['API_URL']}/auth/register', data: request);
  }

  Future<GoogleOAuthLoginResponse> refreshToken(
      TokenRefreshRequest request) async {
    final response = await dio.post('${dotenv.env['API_URL']}/auth/refresh',
        data: request.toJson());
    return GoogleOAuthLoginResponse.fromJson(response.data);
  }
}

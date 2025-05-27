import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/google_oauth_response.dart';
import 'package:motunge/network/dio.dart';

class AuthDataSource {
  final dio = AppDio.getInstance();

  Future<GoogleOAuthLoginResponse> googleLogin(
      GoogleOAuthLoginRequest request) async {
    final response = await dio.post('${dotenv.env['API_URL']}/auth/login',
        data: request.toJson());
    return GoogleOAuthLoginResponse.fromJson(response.data);
  }
}

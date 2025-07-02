import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motunge/model/auth/token_refresh_request.dart';
import 'package:motunge/model/auth/oauth_response.dart';
import 'package:motunge/routes/app_router.dart';
import 'package:motunge/constants/app_constants.dart';

abstract class AppDio {
  AppDio._internal();

  static Dio? _instance;

  static Dio getInstance() => _instance ??= _AppDio();
}

class _AppDio with DioMixin implements Dio {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool _isRefreshing = false;
  static final List<Completer<void>> _refreshQueue = [];

  _AppDio() {
    httpClientAdapter = IOHttpClientAdapter();

    options = BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      receiveDataWhenStatusError: true,
    );

    interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path ==
              "${dotenv.env['API_URL']}${AppConstants.authRefreshEndpoint}") {
            return handler.next(options);
          }
          final token = await _storage.read(key: AppConstants.accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // 401 에러이고 토큰 갱신 요청이 아닌 경우
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path
                  .contains(AppConstants.authRefreshEndpoint)) {
            // 이미 토큰 갱신 중이면 대기
            if (_isRefreshing) {
              final completer = Completer<void>();
              _refreshQueue.add(completer);
              await completer.future;

              // 토큰 갱신 완료 후 원래 요청 재시도
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            }

            _isRefreshing = true;

            try {
              final refreshToken =
                  await _storage.read(key: AppConstants.refreshTokenKey);

              if (refreshToken == null) {
                // Refresh token이 없으면 로그아웃
                await _handleLogout();
                return handler.next(error);
              }

              // 토큰 갱신 시도
              final refreshResponse = await _refreshToken(refreshToken);

              // 새 토큰 저장
              await _storage.write(
                  key: AppConstants.accessTokenKey,
                  value: refreshResponse.accessToken);
              await _storage.write(
                  key: AppConstants.refreshTokenKey,
                  value: refreshResponse.refreshToken);

              // 대기 중인 모든 요청 재시도
              for (final completer in _refreshQueue) {
                completer.complete();
              }
              _refreshQueue.clear();

              // 원래 요청 재시도
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              // 토큰 갱신 실패 시 로그아웃
              await _handleLogout();
              for (final completer in _refreshQueue) {
                completer.completeError(e);
              }
              _refreshQueue.clear();
              return handler.next(error);
            } finally {
              _isRefreshing = false;
            }
          }

          return handler.next(error);
        },
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  Future<OAuthLoginResponse> _refreshToken(String refreshToken) async {
    final dio = Dio();
    dio.options.baseUrl = _baseUrl;

    final response = await dio.post(
      AppConstants.authRefreshEndpoint,
      data: TokenRefreshRequest(refreshToken: refreshToken).toJson(),
    );

    return OAuthLoginResponse.fromJson(response.data);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    // 새로운 토큰으로 Authorization 헤더 업데이트
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }

    // 원래 요청 재시도
    return fetch(requestOptions);
  }

  Future<void> _handleLogout() async {
    await AppRouter.authNotifier.logout();
  }
}

final String _baseUrl = '${dotenv.env['API_URL']}';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AppDio {
  AppDio._internal();

  static Dio? _instance;

  static Dio getInstance() => _instance ??= _AppDio();
}

class _AppDio with DioMixin implements Dio {
  _AppDio() {
    httpClientAdapter = IOHttpClientAdapter();

    options = BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveDataWhenStatusError: true,
    );

    interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path == "${dotenv.env['API_URL']}/auth/refresh") {
            return handler.next(options);
          }
          final token = await FlutterSecureStorage().read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }
}

final String _baseUrl = '${dotenv.env['API_URL']}';

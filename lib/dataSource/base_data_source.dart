import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:motunge/network/dio.dart';

abstract class BaseDataSource {
  final Dio dio = AppDio.getInstance();

  String get baseUrl => dotenv.env['API_URL'] ?? '';

  String getUrl(String endpoint) => '$baseUrl$endpoint';
}

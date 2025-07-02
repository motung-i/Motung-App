import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/view/designSystem/colors.dart';

enum ErrorType {
  network,
  auth,
  validation,
  server,
  unknown,
}

class AppError {
  final ErrorType type;
  final String message;
  final int? statusCode;

  AppError({
    required this.type,
    required this.message,
    this.statusCode,
  });

  factory AppError.fromException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppError(
            type: ErrorType.network,
            message: '연결 시간이 초과되었습니다.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 401:
              return AppError(
                type: ErrorType.auth,
                message: '인증이 필요합니다.',
                statusCode: statusCode,
              );
            case 403:
              return AppError(
                type: ErrorType.auth,
                message: '접근 권한이 없습니다.',
                statusCode: statusCode,
              );
            case 404:
              return AppError(
                type: ErrorType.server,
                message: '요청한 리소스를 찾을 수 없습니다.',
                statusCode: statusCode,
              );
            case 500:
              return AppError(
                type: ErrorType.server,
                message: '서버에 오류가 발생했습니다.',
                statusCode: statusCode,
              );
            default:
              return AppError(
                type: ErrorType.server,
                message: '서버 요청에 실패했습니다.',
                statusCode: statusCode,
              );
          }
        default:
          return AppError(
            type: ErrorType.network,
            message: AppConstants.networkErrorMessage,
          );
      }
    }

    return AppError(
      type: ErrorType.unknown,
      message: AppConstants.unknownErrorMessage,
    );
  }
}

class ErrorHandler {
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.error,
        duration: duration,
      ),
    );
  }

  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  static void showAppErrorSnackBar(
    BuildContext context,
    AppError error,
  ) {
    Color backgroundColor;
    switch (error.type) {
      case ErrorType.network:
        backgroundColor = AppColors.error;
        break;
      case ErrorType.auth:
        backgroundColor = Colors.orange;
        break;
      case ErrorType.validation:
        backgroundColor = Colors.amber;
        break;
      case ErrorType.server:
        backgroundColor = AppColors.error;
        break;
      case ErrorType.unknown:
        backgroundColor = AppColors.grey700;
        break;
    }

    showErrorSnackBar(
      context,
      error.message,
      backgroundColor: backgroundColor,
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(buttonText ?? '확인'),
            ),
          ],
        );
      },
    );
  }
}

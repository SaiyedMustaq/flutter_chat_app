import 'package:dio/dio.dart' as dio;
import 'package:flutter_socket_app/core/network/api_endpoints.dart';
import 'package:flutter_socket_app/features/auth/controller/auth_controller.dart';

import 'package:get/get.dart';
import 'exceptions.dart' hide DioException;

class DioClient {
  final dio.Dio _dio = dio.Dio();

  DioClient() {
    _dio.options = dio.BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = Get.find<AuthController>().token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (dio.DioException error, handler) async {
          if (error.response != null) {
            final statusCode = error.response!.statusCode;
            final message =
                error.response!.data?['message'] ?? 'An error occurred';

            switch (statusCode) {
              case 401:
                return handler.reject(
                  dio.DioException(
                    error: error,
                    requestOptions: error.requestOptions,
                    message: message,
                  ),
                );
              case 404:
                return handler.reject(
                  dio.DioException(
                    error: error,
                    requestOptions: error.requestOptions,
                    message: message,
                  ),
                );
              case 500:
                return handler.reject(
                  dio.DioException(
                    error: error,
                    requestOptions: error.requestOptions,
                    message: message,
                  ),
                );
              default:
                return handler.reject(
                  dio.DioException(
                    error: error,
                    requestOptions: error.requestOptions,
                    message: message,
                  ),
                );
            }
          } else {
            return handler.reject(
              dio.DioException(
                error: error,
                requestOptions: error.requestOptions,
              ),
            );
          }
        },
      ),
    );
  }

  // GET method
  Future<dio.Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST method
  Future<dio.Response<dynamic>> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on dio.DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Handle Dio errors
  dynamic _handleDioError(dio.DioException error) {
    if (error.error is AppException) {
      throw error.error as AppException;
    } else if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 'An error occurred';

      switch (statusCode) {
        case 401:
          throw dio.DioException(
            error: error,
            requestOptions: error.requestOptions,
            message: message,
          );
        case 404:
          throw dio.DioException(
            error: error,
            requestOptions: error.requestOptions,
            message: message,
          );
        case 500:
          throw dio.DioException(
            error: error,
            requestOptions: error.requestOptions,
            message: message,
          );
        default:
          throw dio.DioException(
            error: error,
            requestOptions: error.requestOptions,
            message: message,
          );
      }
    } else {
      throw dio.DioException(
        error: error,
        requestOptions: error.requestOptions,
        message: 'No internet connection',
      );
    }
  }
}

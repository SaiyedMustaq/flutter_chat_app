import 'package:flutter_socket_app/core/network/api_service.dart';
import 'package:flutter_socket_app/core/network/exceptions.dart';
import 'package:flutter_socket_app/core/utils/base_response.dart';
import 'package:flutter_socket_app/features/auth/model/login_request.dart';
import 'package:flutter_socket_app/features/auth/model/register_request.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<BaseResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(request.toJson());
      final loginResponse = LoginResponse.fromJson(response.data);

      return BaseResponse(
        success: true,
        message: 'Login successful',
        data: loginResponse,
        statusCode: response.statusCode!,
      );
    } on AppException catch (e) {
      return BaseResponse(
        success: false,
        message: e.message,
        data: null,
        statusCode: e.statusCode,
      );
    }
  }

  Future<BaseResponse<RegisterResponse>> register(
    RegisterRequest request,
  ) async {
    try {
      final response = await _apiService.register(request.toJson());
      final registerResponse = RegisterResponse.fromJson(response.data);

      return BaseResponse(
        success: true,
        message: 'Registration successful',
        data: registerResponse,
        statusCode: response.statusCode!,
      );
    } on AppException catch (e) {
      return BaseResponse(
        success: false,
        message: e.message,
        data: null,
        statusCode: e.statusCode,
      );
    }
  }

  Future<BaseResponse<void>> logout() async {
    try {
      final response = await _apiService.logout();

      return BaseResponse(
        success: true,
        message: 'Logout successful',
        data: null,
        statusCode: response.statusCode!,
      );
    } on AppException catch (e) {
      return BaseResponse(
        success: false,
        message: e.message,
        data: null,
        statusCode: e.statusCode,
      );
    }
  }
}

import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter_socket_app/core/network/api_service.dart';
import 'package:flutter_socket_app/core/network/exceptions.dart';
import 'package:flutter_socket_app/core/utils/base_response.dart';
import 'package:flutter_socket_app/features/auth/model/login_request.dart';
import 'package:flutter_socket_app/features/auth/model/register_request.dart';

import '../../../core/network/api_endpoints.dart';
import '../../user_list_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<BaseResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(request.toJson());

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        // Chat Plugin
        await Future.delayed(Duration(milliseconds: 500));
        return BaseResponse(
          success: true,
          message: 'Login successful',
          data: loginResponse,
          statusCode: response.statusCode!,
        );
      } else {
        return BaseResponse(
          success: false,
          message: 'Some thing wont wrong',
          data: null,
          statusCode: response.statusCode!,
        );
      }
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
      if (response.statusCode == 200) {
        final registerResponse = RegisterResponse.fromJson(response.data);
        await Future.delayed(Duration(milliseconds: 500));
        return BaseResponse(
          success: true,
          message: 'Registration successful',
          data: registerResponse,
          statusCode: response.statusCode!,
        );
      } else {
        return BaseResponse(
          success: false,
          message: 'Registration successful',
          data: null,
          statusCode: response.statusCode!,
        );
      }
    } on AppException catch (e) {
      print("ERROR $e");
      return BaseResponse(
        success: false,
        message: e.message,
        data: null,
        statusCode: e.statusCode,
      );
    }
  }

  Future<void> logout() async {
    try {
      if (ChatConfig.instance.userId != null) {
        ChatPlugin.chatService.fullDisconnect();
      }
    } catch (ex) {}
  }

  Future<BaseResponse<UserList>> fetchAllUser() async {
    try {
      final response = await _apiService.getAlluser(AppConstants.users);

      if (response.statusCode == 200) {
        return BaseResponse(
          success: true,
          message: 'User fetch success',
          data: UserList.fromJson(response.data),
          statusCode: response.statusCode!,
        );
      } else {
        return BaseResponse(
          success: true,
          message: 'No user found',
          data: null,
          statusCode: response.statusCode!,
        );
      }
    } on AppException catch (e) {
      return BaseResponse(
        success: false,
        message: e.message,
        data: null,
        statusCode: e.statusCode,
      );
    }
  }

  Future<BaseResponse<dynamic>> setApiHandler(String url) async {
    final response = await _apiService.setUpApiHandler(url);
    if (response.statusCode == 200) {
      return BaseResponse(
        success: true,
        message: 'User fetch success',
        data: UserList.fromJson(response.data),
        statusCode: response.statusCode!,
      );
    } else {
      return BaseResponse(
        success: true,
        message: 'No user found',
        data: null,
        statusCode: response.statusCode!,
      );
    }
  }
}

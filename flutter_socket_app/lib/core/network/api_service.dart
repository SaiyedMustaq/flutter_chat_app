import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'dio_client.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  // Auth methods
  Future<Response> login(Map<String, dynamic> data) async {
    return await _dioClient.post(AppConstants.login, data: data);
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dioClient.post(AppConstants.register, data: data);
  }

  Future<Response> logout() async {
    return await _dioClient.post(AppConstants.logout);
  }
}

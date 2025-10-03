// register_request.dart
import 'package:flutter_socket_app/features/auth/model/user.dart';

class RegisterRequest {
  final String userName;
  final String password;
  final String name;

  RegisterRequest({
    required this.userName,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
    'name': name,
  };
}

// register_response.dart
class RegisterResponse {
  final String message;
  final User user;

  RegisterResponse({required this.message, required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
    );
  }
}

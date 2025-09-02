// register_request.dart
import 'package:flutter_socket_app/features/auth/model/user.dart';

class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
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

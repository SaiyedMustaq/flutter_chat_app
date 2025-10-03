import 'package:flutter/material.dart';
import 'package:flutter_socket_app/features/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _authController.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(
          () => Text(
            'Welcome ${_authController.userName.value}',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

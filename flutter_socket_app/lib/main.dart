import 'package:flutter/material.dart';
import 'package:flutter_socket_app/core/network/api_service.dart';
import 'package:flutter_socket_app/core/network/dio_client.dart';
import 'package:flutter_socket_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_socket_app/features/auth/repository/auth_repository.dart';
import 'package:flutter_socket_app/features/auth/view/login_screen.dart';
import 'package:flutter_socket_app/features/auth/view/register_screen.dart';
import 'package:flutter_socket_app/features/home/home_screen.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(
    AuthController(AuthRepository(ApiService(DioClient()))),
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () =>
              authController.isLoggedIn.value ? HomeScreen() : LoginScreen(),
        ),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }
}

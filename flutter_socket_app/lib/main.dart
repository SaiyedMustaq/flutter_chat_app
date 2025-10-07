import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_socket_app/core/network/api_endpoints.dart';
import 'package:flutter_socket_app/core/network/api_service.dart';
import 'package:flutter_socket_app/core/network/dio_client.dart';
import 'package:flutter_socket_app/core/utils/app_constant.dart';
import 'package:flutter_socket_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_socket_app/features/auth/repository/auth_repository.dart';
import 'package:flutter_socket_app/features/auth/view/login_screen.dart';
import 'package:flutter_socket_app/features/auth/view/register_screen.dart';
import 'package:flutter_socket_app/features/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
await ChatPlugin.initialize(
    config: ChatConfig(
      apiUrl: AppConstants.baseUrl,
      enableTypingIndicators: true,
      enableReadReceipts: true,
      enableOnlineStatus: true,
      autoMarkAsRead: true,
      connectionTimeout: 15,
      maxReconnectionAttempts: 3,
      chatRoomRefreshInterval: 30,
      userId: null, // Will be set after login
      token: null, // Will be set after login  
    ),
  );
  
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(AuthController(AuthService(ApiService(DioClient()))));

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => AppConstant.isLogin ? HomeScreen() : LoginScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }
}

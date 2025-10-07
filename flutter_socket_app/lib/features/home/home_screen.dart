import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_app/core/utils/app_constant.dart';
import 'package:flutter_socket_app/features/auth/controller/auth_controller.dart';
import 'package:flutter_socket_app/features/user_list_model.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AuthController _authController = Get.find<AuthController>();
  bool isLoading = false;

  @override
  void initState() {
    isLoading = true;
    WidgetsBinding.instance.addObserver(this);
    if (AppConstant.isLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadData();
        _ensureChatConnection();
      });

      setState(() {
        isLoading = false;
      });
    }
    super.initState();
  }

  void _ensureChatConnection() async {
    if (ChatConfig.instance.userId != null) {
      try {
        final chatService = ChatPlugin.chatService;
        print("CHAT SERVICE ${chatService.isSocketConnected}");
        if (!chatService.isSocketConnected) {
          await chatService.initGlobalConnection();
        } else {
          chatService.refreshGlobalConnection();
        }
        chatService.updateUserStatus(true);
      } catch (ex) {
        print("Error $ex");
      }
    } else {
      await _authController.initializeChatPlugin(
        AppConstant.userId,
        AppConstant.token,
      );
    }
  }

  Future<void> loadData() async {
    await _authController.checkLoginStatus();
    isLoading = false;
    setState(() {});
  }

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
      body: isLoading
          ? CircularProgressIndicator()
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _authController.userList.length,
              itemBuilder: (context, index) {
                UserData userData = _authController.userList[index];
                return ListTile(title: Text("${userData.userName}"));
              },
            ),
    );
  }
}

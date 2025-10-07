import 'dart:convert';

import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter_socket_app/core/utils/app_constant.dart';
import 'package:flutter_socket_app/core/utils/base_response.dart';
import 'package:flutter_socket_app/features/auth/model/login_request.dart';
import 'package:flutter_socket_app/features/auth/model/register_request.dart';
import 'package:flutter_socket_app/features/auth/repository/auth_repository.dart';
import 'package:flutter_socket_app/features/user_list_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/network/api_endpoints.dart';

class AuthController extends GetxController {
  final AuthService _authRepository;
  final GetStorage _storage = GetStorage();

  // Observable variables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var userName = ''.obs;
  var userId = '';
  String? token;
  RxList<UserData> userList = <UserData>[].obs;

  AuthController(this._authRepository);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
      userName.value = _storage.read('userName') ?? '';
      token = _storage.read('token');
      userId = _storage.read('userId') ?? '';
      if (isLoggedIn.value) {
        userList.clear();
        BaseResponse baseResponse = await _authRepository.fetchAllUser();

        UserList userListResponse = baseResponse.data;
        userList.addAll(userListResponse.data ?? []);
        await initializeChatPlugin(userId, token!);
      }
    } catch (ex) {
      rethrow;
    }
  }

  Future<void> login(String userName, String password) async {
    isLoading.value = true;

    try {
      final request = LoginRequest(userName: userName, password: password);
      final response = await _authRepository.login(request);

      if (response.success && response.data != null) {
        // Save user data
        _storage.write('isLoggedIn', true);
        _storage.write('userName', userName);
        AppConstant.userName = userName;
        AppConstant.isLogin = true;
        AppConstant.token = response.data!.token;
        _storage.write('token', response.data!.token);
        _storage.write("userId", response.data!.user.id);

        isLoggedIn.value = true;
        this.userName.value = userName;
        token = response.data!.token;
        print("TOKEN $token");
        await initializeChatPlugin(AppConstant.userId, AppConstant.token);
        Get.offAllNamed('/home');
        Get.snackbar('Success', response.message);
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during login');
      print("ERROR $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String userName, String password, String name) async {
    isLoading.value = true;

    try {
      final request = RegisterRequest(
        userName: userName,
        password: password,
        name: name,
      );
      final response = await _authRepository.register(request);
      return response.success;
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during registration');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<void> logout() async {
    try {
      // Clear local storage
      _storage.remove('isLoggedIn');
      _storage.remove('userName');
      _storage.remove('token');
      _storage.remove('userId');

      isLoggedIn.value = false;

      userName.value = '';
      token = null;
      _authRepository.logout();

      Get.offAllNamed('/login');
    } catch (e) {
      // Even if API call fails, clear local storage
    } finally {}
  }

  Future<String?> getUserId() async {
    return _storage.read("key");
  }

  Future<void> initializeChatPlugin(String userId, String token) async {
    try {
      if (ChatConfig.instance.userId == userId) {
        ChatPlugin.chatService.refreshGlobalConnection();
        return;
      }
      await ChatPlugin.initialize(
        config: ChatConfig(
          apiUrl: AppConstants.baseUrl,
          userId: userId,
          token: token,
          enableTypingIndicators: true,
          enableOnlineStatus: true,
          enableReadReceipts: true,
          autoMarkAsRead: true,
          maxReconnectionAttempts: 5,
          debugMode: true,
        ),
      );
      await setChatApiHandler(userId, token);
      await ChatPlugin.chatService.initialize();
      //  await ChatPlugin.chatService.loadChatRooms();
    } catch (e) {
      print("initilizeChatPlugin ### $e");
      print(e);
    }
  }

  Future<void> setChatApiHandler(String userId, String token) async {
    final apiHandler = ChatApiHandlers(
      loadMessagesHandler: ({limit = 20, page = 1, searchText = ""}) async {
        final receiverId = ChatPlugin.chatService.receiverId;
        if (receiverId.isEmpty) return [];
        try {
          var url =
              "${AppConstants.baseUrl}/app/chat/messages?currentUserId=$userId&receiverId=$receiverId&page=$page&limit=$limit";
          if (searchText.isNotEmpty) {
            url += "&searchText=${Uri.encodeComponent(searchText)}";
          }
          final response = await _authRepository.setApiHandler(url);
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.data);
            return data.map((msg) => ChatMessage.fromMap(msg, userId)).toList();
          } else {
            return [];
          }
        } catch (ex) {
          print("Error loadMessagesHandler=> $ex");
          return [];
        }
      },
      loadChatRoomsHandler: () async {
        try {
          var url = "${AppConstants.baseUrl}chat/getChatRoom";

          final response = await _authRepository.setApiHandler(url);

          return [];
          // if (response.statusCode == 200) {
          //   final List<dynamic> data = jsonDecode(response.data);
          //   return data.map((room) => ChatRoom.fromMap(room)).toList();
          // } else {
          //   return [];
          // }
        } catch (ex) {
          print("Error loadChatRoomsHandler==> $ex");
          return [];
        }
      },
    );
    ChatPlugin.chatService.setApiHandlers(apiHandler);
  }
}

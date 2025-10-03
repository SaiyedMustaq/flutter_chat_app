import 'package:flutter_socket_app/core/utils/app_constant.dart';
import 'package:flutter_socket_app/features/auth/model/login_request.dart';
import 'package:flutter_socket_app/features/auth/model/register_request.dart';
import 'package:flutter_socket_app/features/auth/repository/auth_repository.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final GetStorage _storage = GetStorage();

  // Observable variables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var userName = ''.obs;
  String? token;

  AuthController(this._authRepository);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
    userName.value = _storage.read('userEmail') ?? '';
    token = _storage.read('token');
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
        AppConstant.isLogin = isLoggedIn.value;
        AppConstant.token = response.data!.token;
        _storage.write('token', response.data!.token);
        _storage.write('user', response.data!.user.toJson());

        isLoggedIn.value = true;
        this.userName.value = userName;
        token = response.data!.token;

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
      _storage.remove('userEmail');
      _storage.remove('token');
      _storage.remove('user');

      isLoggedIn.value = false;
      userName.value = '';
      token = null;

      Get.offAllNamed('/login');
    } catch (e) {
      // Even if API call fails, clear local storage
    } finally {}
  }

  Future<String?> getUserId() async {
    return _storage.read("key");
  }
}

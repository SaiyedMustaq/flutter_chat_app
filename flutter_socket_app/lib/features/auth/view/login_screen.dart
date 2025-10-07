import 'package:flutter/material.dart';
import 'package:flutter_socket_app/features/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _userNameController = TextEditingController(
    text: "Tester1",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "Tester1234",
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              Obx(
                () => _authController.isLoading.value
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _authController.login(
                              _userNameController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text('Login', style: TextStyle(fontSize: 16)),
                      ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.toNamed('/register');
                },
                child: Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

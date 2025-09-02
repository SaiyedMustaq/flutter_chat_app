import 'package:flutter/material.dart';
import 'package:flutter_socket_app/features/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              Obx(
                () => _authController.isLoading.value
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          // if (_formKey.currentState!.validate()) {
                          //   bool success = await _authController.login(
                          //     _emailController.text.trim(),
                          //     _passwordController.text.trim(),
                          //   );

                          //   if (success) {
                          //     Get.offAllNamed('/home');
                          //     Get.snackbar(
                          //       'Success',
                          //       'Login successful',
                          //       backgroundColor: Colors.green,
                          //       colorText: Colors.white,
                          //     );
                          //   } else {
                          //     Get.snackbar(
                          //       'Error',
                          //       'Invalid credentials',
                          //       backgroundColor: Colors.red,
                          //       colorText: Colors.white,
                          //     );
                          //   }
                          // }
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_testing/common/utils/colors.dart';
import 'package:vc_testing/common/utils/utils.dart';
import 'package:vc_testing/common/widgets/custom_button.dart';
import 'package:vc_testing/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true; // Toggle between login and registration

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context: context, content: 'Please fill out all fields.');
      return;
    }

    if (_isLogin) {
      // Login
      ref.read(authControllerProvider).signInWithEmailAndPassword(
            context: context,
            email: email,
            password: password,
          );
    } else {
      // Register
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        showSnackBar(context: context, content: 'Please enter your name.');
        return;
      }
      ref.read(authControllerProvider).signUpWithEmailAndPassword(
            context: context,
            email: email,
            password: password,
            name: name,
            profilePic: null, // You can add image picker logic here
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_isLogin) // Show name field only during registration
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                  ),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _submit,
                  text: _isLogin ? 'LOGIN' : 'REGISTER',
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _toggleAuthMode,
                child: Text(
                  _isLogin
                      ? 'Create a new account'
                      : 'I already have an account',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

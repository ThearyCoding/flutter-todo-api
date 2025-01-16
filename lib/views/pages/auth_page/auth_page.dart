import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_api/services/api/api_auth_service.dart';
import 'package:flutter_todo_api/utils/snackbar_utils.dart';
import 'package:go_router/go_router.dart';

import '../../../routers/app_route.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _txtusername = TextEditingController();
  final _txtpassword = TextEditingController();
  final _txtemail = TextEditingController();
  final _txtconfirm = TextEditingController();
  bool _isLoginPage = true;

  void _togglePage() {
    setState(() {
      _isLoginPage = !_isLoginPage;
    });
  }

  final ApiAuthService _authService = ApiAuthService();

  Future<void> signUp() async {
    if (_txtconfirm.text != _txtpassword.text) {
      showSnackbar(context, 'Passwords do not match');
      return;
    }

    try {
      await _authService.signUp(
        _txtusername.text,
        _txtemail.text,
        _txtpassword.text,
      );
      if (!mounted) return;
      showSnackbar(context, 'Account created successfully');
    } catch (e) {
      if (e is DioException) {
        log('DioError: ${e.response?.data}');
        showSnackbar(context, 'Error: ${e.response?.data['message']}');
      } else {
        log('Unexpected error: $e');
      }
    }
  }

  Future<void> login() async {
    try {
      final response =
          await _authService.login(_txtemail.text, _txtpassword.text);

      if (response != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
      }
      if (!mounted) return;
      context.go(AppPath.home);
    } on DioException catch (e) {
      log('DioError: ${e.message}');
      if (e.response != null) {
        log('Response data: ${e.response?.data}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${e.response?.data['message'] ?? 'Invalid credentials'}')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    } catch (e) {
      log('Unexpected error during login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: _isLoginPage ? screenHeight * 0.5 : screenHeight * 0.62,
            width: screenHeight * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _isLoginPage ? "Welcome Back!" : "Create an Account",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLoginPage
                          ? "Login to your account to continue."
                          : "Sign up to get started and explore amazing features.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_isLoginPage) ...[
                      TextField(
                        controller: _txtemail,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    TextField(
                      controller: _txtusername,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'Enter your username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _txtpassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (!_isLoginPage) ...[
                      const SizedBox(height: 15),
                      TextField(
                        controller: _txtconfirm,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: 'Confirm your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_isLoginPage) {
                            login();
                          } else {
                            await signUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _isLoginPage ? "Login" : "Sign Up",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLoginPage
                              ? "Don't have an account?"
                              : "Already have an account?",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: _togglePage,
                          child: Text(
                            _isLoginPage ? "Sign up" : "Log in",
                            style: const TextStyle(color: Color(0xFF6A11CB)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

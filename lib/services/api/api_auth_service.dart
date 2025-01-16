import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_todo_api/services/api/api_service.dart';
import 'package:flutter_todo_api/services/api/sp_service.dart';

class ApiAuthService {
  final ApiService _apiService = ApiService.instance;
  final SpService _spService = SpService();
  Future<void> signUp(String username, String email, String password) async {
    try {
      final response = await _apiService.request(
        '/api/users/register',
        method: DioMethod.post,
        param: {
          'email': email,
          'password': password,
          'username': username,
        },
        contentType: Headers.jsonContentType,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('User successfully registered: $email');
      } else {
        log('Unexpected status code: ${response.statusCode}, Response: ${response.data}');
        throw Exception(
            'Registration failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('Sign-up failed: ${e.message}');
      if (e.response != null) {
        log('Response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      log('Unexpected error during sign-up: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiService.request(
        '/api/users/login',
        method: DioMethod.post,
        param: {'email': email, 'password': password},
        contentType: Headers.jsonContentType,
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _spService.setToken(token);
        return token;
      } else {
        log('Unexpected status code: ${response.statusCode}, Response: ${response.data}');
        throw Exception(
            'Login failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('Login failed: ${e.message}');
      if (e.response != null) {
        log('Response status: ${e.response?.statusCode}');
        log('Response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      log('Unexpected error during login: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}

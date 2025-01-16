import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_todo_api/core/constants.dart';
import 'package:flutter_todo_api/models/todo_model.dart';

enum DioMethod { post, get, put, delete }

class ApiService {
  ApiService._singleton();

  static final ApiService instance = ApiService._singleton();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
    ),
  );

  Future<Response> request(
    String endpoint, {
    required DioMethod method,
    Map<String, dynamic>? param,
    String? contentType,
    FormData? formData,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Set headers
      _dio.options.headers = {
        HttpHeaders.authorizationHeader: 'Bearer token',
        if (headers != null) ...headers,
      };

      // Set content type if provided
      if (contentType != null) {
        _dio.options.contentType = contentType;
      }

      // Handle different methods
      switch (method) {
        case DioMethod.post:
          return await _dio.post(endpoint, data: formData ?? param);
        case DioMethod.get:
          return await _dio.get(endpoint, queryParameters: param);
        case DioMethod.put:
          return await _dio.put(endpoint, data: formData ?? param);
        case DioMethod.delete:
          return await _dio.delete(endpoint, data: formData ?? param);
        default:
          throw Exception('Unsupported HTTP method');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      log('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  void _handleDioError(DioException error) {
    log('Dio error occurred: ${error.type}');
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        log('Connection timeout: ${error.message}');
        break;
      case DioExceptionType.sendTimeout:
        log('Send timeout: ${error.message}');
        break;
      case DioExceptionType.receiveTimeout:
        log('Receive timeout: ${error.message}');
        break;
      case DioExceptionType.badCertificate:
        log('Invalid certificate: ${error.message}');
        break;
      case DioExceptionType.badResponse:
        log('HTTP error (${error.response?.statusCode}): ${error.response?.data}');
        break;
      case DioExceptionType.cancel:
        log('Request was cancelled: ${error.message}');
        break;
      case DioExceptionType.connectionError:
        log('Network error: ${error.message}');
        break;
      case DioExceptionType.unknown:
        log('Unknown error: ${error.message}');
        break;
    }
  }

  Future<List<TodoModel>> fetchTodos() async {
    final response = await request(
      todos,
      method: DioMethod.get,
    );

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> jsonData = response.data as List<dynamic>;
      return jsonData.map((todo) => TodoModel.fromJson(todo)).toList();
    } else {
      log('Failed to load todos: ${response.statusCode}, ${response.data}');
      throw Exception('Failed to load todos: ${response.statusCode}');
    }
  }

  Future<void> createTodo(TodoModel todo) async {
    final response = await request(
      'todos',
      method: DioMethod.post,
      param: {
        'title': todo.title,
        'completed': todo.isCompleted,
        'description': todo.description,
      },
      contentType: Headers.jsonContentType,
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      log('Add Todo Successful');
    } else {
      log('Failed to create todo: ${response.statusCode}, ${response.data}');
      throw Exception(
          'Failed to create todo: ${response.statusCode}, Response: ${response.data}');
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    final response = await request(
      'todos/${todo.id}',
      method: DioMethod.put,
      param: {
        'title': todo.title,
        'completed': todo.isCompleted,
        'description': todo.description,
      },
      contentType: Headers.jsonContentType,
    );

    if (response.statusCode == HttpStatus.ok) {
      log('Update Todo Successful!');
    } else {
      log('Failed to update todo: ${response.statusCode}, ${response.data}');
      throw Exception('Failed to update todo');
    }
  }

  Future<void> deleteTodo(String id) async {
    final response = await request(
      'todos/$id',
      method: DioMethod.delete,
      contentType: Headers.jsonContentType,
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.noContent) {
      log('Todo deleted successfully!');
    } else {
      log('Failed to delete todo: ${response.statusCode}, ${response.data}');
      throw Exception('Failed to delete todo');
    }
  }

  Future<List<TodoModel>> fetchTodosActive() async {
    final response = await request(
      '$todos/active',
      method: DioMethod.get,
    );

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> jsonData = response.data as List<dynamic>;
      return jsonData.map((todo) => TodoModel.fromJson(todo)).toList();
    } else {
      log('Failed to fetch active todos: ${response.statusCode}');
      return [];
    }
  }
}

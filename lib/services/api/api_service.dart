import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_todo_api/core/constants.dart';
import 'package:flutter_todo_api/models/todo_model.dart';

enum DioMethod { post, get, put, delete }

class ApiService {
  ApiService._singleton();

  static final ApiService instance = ApiService._singleton();

  Future<Response> request(
    String endpoint,
    DioMethod method,
    Map<String, dynamic> param,
    String? contentType,
    formData,
  ) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          contentType: contentType ?? Headers.formUrlEncodedContentType,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer token',
          },
        ),
      );

      switch (method) {
        case DioMethod.post:
          return await dio.post(endpoint, data: param);
        case DioMethod.get:
          return await dio.get(endpoint, queryParameters: param);
        case DioMethod.put:
          return await dio.put(endpoint, data: param);
        case DioMethod.delete:
          return await dio.delete(endpoint, data: param);
        default:
          return await dio.post(endpoint, data: param);
      }
    } catch (e) {
      log('Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<TodoModel>> fetchTodos() async {
    final response = await ApiService.instance.request(
      todos,
      DioMethod.get,
      {},
      null,
      null,
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
      DioMethod.post,
      {
        'title': todo.title,
        'completed': todo.isCompleted,
        'description': todo.description
      },
      Headers.jsonContentType,
      null,
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
    try {
      final response = await request(
        'todos/${todo.id}',
        DioMethod.put,
        {
          'title': todo.title,
          'completed': todo.isCompleted,
          'description': todo.description
        },
        Headers.jsonContentType,
        null,
      );

      if (response.statusCode == HttpStatus.ok) {
        log('Update Todo Successful!');
      } else {
        log('Failed to update todo with status code: ${response.statusCode}');
      }
    } catch (err) {
      throw Exception('Failed to update todo: ${err.toString()}');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final response = await request(
        'todos/$id',
        DioMethod.delete,
        {},
        Headers.jsonContentType,
        null,
      );
      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.noContent) {
        log('Todo deleted successfully!');
      } else {
        log('Failed to delete todo: ${response.statusCode}, ${response.data}');
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (err) {
      log('Failed to delete todo: $err');
      throw Exception('Failed to delete todo: ${err.toString()}');
    }
  }

  Future<List<TodoModel>> fetchTodosActive() async {
    final response = await request(
      '$todos/active',
      DioMethod.get,
      {},
      null,
      null,
    );

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> todoJson = response.data as List<dynamic>;

      return todoJson.map((todo) => TodoModel.fromJson(todo)).toList();
    } else {
      log('error fetching todo active: ${response.statusCode}');
      return [];
    }
  }
}

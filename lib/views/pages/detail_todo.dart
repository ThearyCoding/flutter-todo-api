import 'package:flutter/material.dart';
import 'package:flutter_todo_api/models/todo_model.dart';

class DetailTodo extends StatelessWidget {
  final TodoModel todo;
  const DetailTodo({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(todo.title),
          Text(todo.description),
          Text('${todo.createdAt!.toLocal()}')
        ],
      ),
    );
  }
}

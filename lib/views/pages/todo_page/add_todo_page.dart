import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo_api/bloc/todo_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../models/todo_model.dart';

class AddTodoPage extends StatefulWidget {
  final TodoModel? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _txtTitle = TextEditingController();
  final TextEditingController _txtDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _txtTitle.text = widget.todo!.title;
      _txtDescription.text = widget.todo!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final title = _txtTitle.text;
          final description = _txtDescription.text;

          if (title.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a title')),
            );
            return;
          }

          if (widget.todo != null) {
            final updatedTodo = widget.todo!.copyWith(
              title: title,
              description: description,
            );
            context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
          } else {
            context.read<TodoBloc>().add(CreateTodo(
                  title: title,
                  description: description,
                  isCompleted: false,
                ));
          }

          context.pop();
        },
        child: const Icon(Icons.check),
      ),
      appBar: AppBar(
        title: Text(widget.todo != null ? 'Edit Todo Task' : 'Add Todo Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _txtTitle,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Type your title here',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _txtDescription,
                maxLength: 300,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Type your description here',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

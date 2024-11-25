part of 'todo_bloc.dart';

abstract class TodoState {}

class TodoInit extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  final String filterOption;

  TodoLoaded(this.todos, {this.filterOption = 'Show all'});

  List<TodoModel> get filteredTodos {
    if (filterOption == 'Show active') {
      return todos.where((todo) => !todo.isCompleted).toList();
    } else if (filterOption == 'Show completed') {
      return todos.where((todo) => todo.isCompleted).toList();
    }
    return todos;
  }
}

class TodoError extends TodoState {
  String error;

  TodoError(this.error);
}

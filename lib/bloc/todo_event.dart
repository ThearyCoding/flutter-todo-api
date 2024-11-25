part of 'todo_bloc.dart';

abstract class TodoEvent{}

class FetchTodo extends TodoEvent{}
class ChangeFilter extends TodoEvent {
  final String filterOption;
  ChangeFilter(this.filterOption);
}


class FetchTodoById extends TodoEvent{
  TodoModel todo;

  FetchTodoById(this.todo);
}



class CreateTodo extends TodoEvent {
  final String title;
  final bool isCompleted;
  final String description;

  CreateTodo({required this.title, this.isCompleted = false,required this.description});
}


class ToggleTodo extends TodoEvent{
  TodoModel todo;

  ToggleTodo(this.todo);
}

class DeleteTodo extends TodoEvent{
  String id;

  DeleteTodo(this.id);
}

class UpdateTodo extends TodoEvent{
  TodoModel todo;
  UpdateTodo(this.todo);
}

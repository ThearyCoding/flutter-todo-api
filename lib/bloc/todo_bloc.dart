import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo_api/models/todo_model.dart';
import 'package:flutter_todo_api/services/api/api_service.dart';

part 'todo_state.dart';
part 'todo_event.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final ApiService apiService;
  TodoBloc({required this.apiService}) : super(TodoInit()) {
    on<FetchTodo>(_fetchTodo);
    on<CreateTodo>(_createTodo);
    on<ToggleTodo>(_toggleTodo);
    on<DeleteTodo>(_deleteTodo);
    on<UpdateTodo>(_updateTodo);
    on<ChangeFilter>(_changeFilter);
  }

  Future<void> _changeFilter(
      ChangeFilter event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(TodoLoaded(currentState.todos, filterOption: event.filterOption));
    }
  }

  Future<void> _createTodo(CreateTodo even, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todo = TodoModel(
          title: even.title,
          description: even.description,
          isCompleted: even.isCompleted);

      await apiService.createTodo(todo);

      final todos = await apiService.fetchTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _fetchTodo(FetchTodo even, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todo = await apiService.fetchTodos();
      emit(TodoLoaded(todo));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _updateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      if (state is TodoLoaded) {
        final currentTodo = state as TodoLoaded;

        final updatedTodos = currentTodo.todos.map((todo) {
          return todo.id == event.todo.id ? event.todo : todo;
        }).toList();

        emit(TodoLoaded(updatedTodos,
            filterOption: (state as TodoLoaded).filterOption));
      }
    } catch (err) {
      emit(TodoError(err.toString()));
    }
  }

  Future<void> _toggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;

      final updatedTodos = currentState.todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();

      emit(TodoLoaded(updatedTodos,
          filterOption: (state as TodoLoaded).filterOption));

      try {
        await apiService.updateTodo(event.todo);
      } catch (e) {
        emit(TodoError('Failed to update todo: ${e.toString()}'));
      }
    }
  }

  Future<void> _deleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;

      final previousTodos = currentState.todos;

      final updatedTodos =
          previousTodos.where((todo) => todo.id != event.id).toList();
      emit(TodoLoaded(updatedTodos,
          filterOption: (state as TodoLoaded).filterOption));

      try {
        await apiService.deleteTodo(event.id);
      } catch (e) {
        emit(TodoLoaded(previousTodos));
        emit(TodoError('Failed to delete todo: ${e.toString()}'));
      }
    }
  }
}

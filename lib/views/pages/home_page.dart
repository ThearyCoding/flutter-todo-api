import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo_api/bloc/todo_bloc.dart';
import 'package:flutter_todo_api/routers/app_route.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(FetchTodo());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/home/add-todo');
          context.goNamed(PathName.addTodo);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Todo App"),
        actions: [
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              String currentFilter = 'Show all';

              if (state is TodoLoaded) {
                currentFilter = state.filterOption;
              }

              return DropdownButton<String>(
                value: currentFilter,
                icon: const Icon(Icons.more_vert, color: Colors.white),
                items: <String>['Show all', 'Show active', 'Show completed']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<TodoBloc>().add(ChangeFilter(value));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else if (state is TodoError) {
            return Center(
              child: Text('Error: ${state.toString()}'),
            );
          } else if (state is TodoLoaded) {
            final todos = state.filteredTodos;

            return todos.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (ctx, index) =>
                        const SizedBox(height: 10),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        onTap: () {
                          //  context.push(AppPath.detailTodo, extra: todos[index]);

                          // context.go('/home/add-todo', extra: {
                          //   'todo': todo,
                          // });
                          context.goNamed(
                            PathName.addTodo,
                            extra: todo,
                          );
                        },
                        title: Text(
                          todo.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Checkbox(
                          shape: const ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          value: todo.isCompleted,
                          onChanged: (value) {
                            final updatedTodo = todo.copyWith(
                              isCompleted: value ?? false,
                            );
                            context
                                .read<TodoBloc>()
                                .add(ToggleTodo(updatedTodo));
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final isdel = await isDeleted();
                            if (isdel) {
                              if (!context.mounted) return;
                              context
                                  .read<TodoBloc>()
                                  .add(DeleteTodo(todo.id!));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Todo deleted successfully!')),
                              );
                            }
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(todo.isCompleted ? 'Completed' : 'Pending'),
                            Text(
                              'Created at: ${todo.createdAt?.toLocal()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text("No have todo task"),
                  );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<bool> isDeleted() async {
    bool result = false;

    result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("Are you sure you want to delete this task?"),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      context.pop(false);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      context.pop(true);
                    },
                    child: const Text("Yes")),
              ],
            ),
          );
        });
    return result;
  }
}

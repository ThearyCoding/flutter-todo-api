import 'package:flutter/material.dart';
import 'package:flutter_todo_api/bloc/todo_bloc.dart';
import 'package:flutter_todo_api/routers/app_route.dart';
import 'package:flutter_todo_api/services/api/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme/theme.dart';

void main() {
  final ApiService apiService = ApiService.instance;
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (ctx) => TodoBloc(apiService: apiService))
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppGoRouter.router,
      theme: FlutterTodosTheme.light,
      darkTheme: FlutterTodosTheme.dark,
      debugShowCheckedModeBanner: false,
    );
  }
}

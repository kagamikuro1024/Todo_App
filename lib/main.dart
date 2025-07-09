import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import '/bloc/todo_event.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/theme_bloc.dart';
import '/repositories/todo_repository.dart';

void main() {
  // Khởi tạo TodoRepository
  final TodoRepository todoRepository = TodoRepository();

  runApp(
    // Cung cấp nhiều BLoC cho toàn bộ cây widget
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TodoBloc(todoRepository: todoRepository)..add(LoadTodos()),
        ),
        BlocProvider(create: (context) => ThemeBloc()),
      ],
      child: const TodoApp(),
    ),
  );
}

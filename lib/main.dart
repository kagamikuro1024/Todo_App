import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'screens/login_screen.dart'; // Import màn hình đăng nhập
import '/bloc/todo_event.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/theme_bloc.dart';
import '/repositories/todo_repository.dart';
import '/services/api_service.dart'; // Import ApiService

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter binding đã được khởi tạo
  final prefs = await SharedPreferences.getInstance();
  final String? jwtToken = prefs.getString('jwt_token');

  // Khởi tạo TodoRepository với ApiService
  final apiService = ApiService();
  final TodoRepository todoRepository = TodoRepository(apiService: apiService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TodoBloc(todoRepository: todoRepository)..add(LoadTodos()),
        ),
        BlocProvider(create: (context) => ThemeBloc()),
      ],
      child: MyApp(isAuthenticated: jwtToken != null), // Truyền trạng thái xác thực
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeInitial ? themeState.isDarkMode : false;

        return MaterialApp(
          title: 'Todo App BloC',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: isAuthenticated ? const TodoApp() : const LoginScreen(), // Chuyển hướng
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[800],
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: Colors.lightBlueAccent,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blueAccent;
          }
          return Colors.grey;
        }),
      ),
      cardTheme: const CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[200],
        contentTextStyle: const TextStyle(color: Colors.black),
        actionTextColor: Colors.blueAccent,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blueAccent;
          }
          return Colors.grey;
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: Colors.grey[850],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[400],
        backgroundColor: Colors.grey[900],
      ),
    );
  }
}
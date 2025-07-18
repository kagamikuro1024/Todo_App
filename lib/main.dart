import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'screens/login_screen.dart';
import '/bloc/todo_event.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/theme_bloc.dart';
import '/repositories/todo_repository.dart';
import '/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[main] Starting app...');
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(
          create: (context) {
            debugPrint('[main] Creating TodoBloc');
            final todoBloc = TodoBloc(
              todoRepository: TodoRepository(apiService: ApiService()),
            );
            debugPrint('[main] TodoBloc created successfully');
            // Test event để kiểm tra TodoBloc có hoạt động không
            todoBloc.add(LoadTodos());
            debugPrint('[main] LoadTodos event dispatched');
            return todoBloc;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeInitial
            ? themeState.isDarkMode
            : false;
        return MaterialApp(
          title: 'Todo App BloC',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthGate(),
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? isAuthenticated;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    debugPrint('[AuthGate] Checking authentication...');
    final prefs = await SharedPreferences.getInstance();
    final String? jwtToken = prefs.getString('jwt_token');
    if (jwtToken != null) {
      debugPrint('[AuthGate] JWT token found, validating...');
      final apiService = ApiService();
      try {
        await apiService.fetchTodos();
        debugPrint('[AuthGate] Token is valid, user is authenticated');
        setState(() => isAuthenticated = true);
        // Load todos khi xác thực thành công
        debugPrint('[AuthGate] Dispatching LoadTodos event');
        context.read<TodoBloc>().add(LoadTodos());
        return;
      } catch (e) {
        debugPrint('[AuthGate] Token validation failed: $e');
        await prefs.remove('jwt_token');
      }
    } else {
      debugPrint('[AuthGate] No JWT token found');
    }
    setState(() => isAuthenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (isAuthenticated!) {
      debugPrint('[AuthGate] Showing TodoApp');
      return const TodoApp();
    } else {
      debugPrint('[AuthGate] Showing login screen');
      return const LoginScreen();
    }
  }
}

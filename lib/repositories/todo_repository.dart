import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/todo.dart';

class TodoRepository {
  static const String _todosKey = 'todos';

  // Tải danh sách todos từ SharedPreferences
  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(_todosKey);
    if (todosJson != null) {
      final List<dynamic> jsonList = json.decode(todosJson);
      return jsonList.map((json) => Todo.fromJson(json)).toList();
    }
    return [];
  }

  // Lưu danh sách todos vào SharedPreferences
  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson = json.encode(todos.map((todo) => todo.toJson()).toList());
    await prefs.setString(_todosKey, todosJson);
  }
}

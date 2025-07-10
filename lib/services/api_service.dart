import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/todo.dart'; // Đảm bảo import đúng đường dẫn đến model Todo của bạn

class ApiService {
final String backendUrl = 'http://10.0.2.2:3000'; // URL backend của bạn
final String _baseUrl = 'http://10.0.2.2:3000/api/todos'; // URL base của API Todos
  String? _jwtToken;

  ApiService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    await _loadToken(); // Đảm bảo token được tải trước mỗi request
    if (_jwtToken == null) {
      throw Exception('JWT Token not found. Please login.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_jwtToken',
    };
  }

  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        return List<Todo>.from(l.map((model) => Todo.fromJson(model)));
      } else if (response.statusCode == 401) {
        // Token hết hạn hoặc không hợp lệ, yêu cầu đăng nhập lại
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to load todos: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching todos: $e');
      rethrow;
    }
  }

  Future<Todo> addTodo(Todo todo) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: await _getHeaders(),
        body: jsonEncode(todo.toJson()),
      );

      if (response.statusCode == 201) {
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to add todo: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    }
  }

  Future<Todo> updateTodo(Todo todo) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${todo.id}'),
        headers: await _getHeaders(),
        body: jsonEncode(todo.toJson()),
      );

      if (response.statusCode == 200) {
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to update todo: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$todoId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        print('Todo deleted successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to delete todo: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Xóa token khi đăng xuất
    _jwtToken = null;
    // Có thể gọi API logout nếu backend có route logout riêng
    try {
      await http.get(Uri.parse('http://10.0.2.2:3000/auth/logout'));
    } catch (e) {
      print('Error calling backend logout: $e');
    }
  }
  // Đăng ký tài khoản mới
Future<String> registerWithEmail(String email, String password) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/auth/local/register'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({'email': email, 'password': password}),
  );
  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['token'];
  } else {
    throw Exception(jsonDecode(response.body)['message'] ?? 'Đăng ký thất bại');
  }
}

// Đăng nhập bằng email & password
Future<String> loginWithEmail(String email, String password) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/auth/local/login'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({'email': email, 'password': password}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['token'];
  } else {
    throw Exception(
      jsonDecode(response.body)['message'] ?? 'Đăng nhập thất bại',
    );
  }
}

}


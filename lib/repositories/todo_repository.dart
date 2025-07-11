import '/models/todo.dart';
import '/services/api_service.dart';

class TodoRepository {
  final ApiService _apiService; // Sử dụng ApiService

  TodoRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService(); // Khởi tạo ApiService

  // Tải danh sách todos từ API
  Future<List<Todo>> loadTodos() async {
    return await _apiService.fetchTodos();
  }

  // Lưu danh sách todos lên API
  Future<Todo> addTodo(Todo todo) async {
    return await _apiService.addTodo(todo);
  }

  Future<Todo> updateTodo(Todo todo) async {
    return await _apiService.updateTodo(todo);
  }

  Future<void> deleteTodo(Todo todo) async {
    await _apiService.deleteTodo(todo.id);
  }

  // Hàm logout để xóa token
  Future<void> logout() async {
    await _apiService.logout();
  }
}

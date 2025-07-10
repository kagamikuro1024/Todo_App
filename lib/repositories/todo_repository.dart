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

  // Lưu danh sách todos (thực ra là thêm/cập nhật) lên API
  // Các phương thức này sẽ gọi API tương ứng
  Future<void> addTodo(Todo todo) async {
    await _apiService.addTodo(todo);
  }

  Future<void> updateTodo(Todo todo) async {
    await _apiService.updateTodo(todo);
  }

  Future<void> deleteTodo(Todo todo) async {
    await _apiService.deleteTodo(todo.id);
  }

  // Không còn cần saveTodos(List<Todo> todos) vì mỗi thao tác sẽ gọi API riêng
  // Các hàm như toggleAll và clearCompleted sẽ được xử lý trong Bloc
  // bằng cách gọi updateTodo/deleteTodo nhiều lần.

  // Hàm logout để xóa token
  Future<void> logout() async {
    await _apiService.logout();
  }
}
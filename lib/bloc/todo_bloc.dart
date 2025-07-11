import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'todo_event.dart';
import 'todo_state.dart';
import '/models/todo.dart';
import '/repositories/todo_repository.dart';

final Uuid _uuid = const Uuid();

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _todoRepository; // Trường này là private

  TodoBloc({required TodoRepository todoRepository})
      : _todoRepository = todoRepository,
        super(TodosLoading()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleAll>(_onToggleAll);
    on<ClearCompleted>(_onClearCompleted);
    on<UpdateFilter>(_onUpdateFilter);
    on<UndoDeleteTodo>(_onUndoDeleteTodo);
    on<Logout>(_onLogout); // Thêm handler cho sự kiện Logout
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    try {
      final todos = await _todoRepository.loadTodos();
      emit(TodosLoaded(todos: todos));
    } catch (e) {
      print('Error loading todos: $e');
      emit(TodosNotLoaded());
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final newTodo = event.todo.copyWith(id: _uuid.v4());
      try {
        // Use the todo object returned by the repository to ensure consistency
        final addedTodo = await _todoRepository.addTodo(newTodo); // Modified
        final updatedTodos = List<Todo>.from((state as TodosLoaded).todos)..add(addedTodo); // Modified
        emit((state as TodosLoaded).copyWith(todos: updatedTodos));
      } catch (e) {
        print('Error adding todo to backend: $e');
        // Xử lý lỗi (ví dụ: hiển thị SnackBar)
      }
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      try {
        // Use the todo object returned by the repository to ensure consistency
        final updatedBackendTodo = await _todoRepository.updateTodo(event.todo); // Modified
        final updatedTodos = (state as TodosLoaded).todos.map((todo) {
          return todo.id == event.todo.id ? updatedBackendTodo : todo; // Modified
        }).toList();
        emit((state as TodosLoaded).copyWith(todos: updatedTodos));
      } catch (e) {
        print('Error updating todo on backend: $e');
        // Xử lý lỗi
      }
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final currentTodos = (state as TodosLoaded).todos;
      final updatedTodos = currentTodos.where((todo) => todo.id != event.todo.id).toList();
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));

      try {
        await _todoRepository.deleteTodo(event.todo);
      } catch (e) {
        print('Error deleting todo from backend: $e');
        emit((state as TodosLoaded).copyWith(todos: currentTodos));
      }
    }
  }

  Future<void> _onToggleAll(ToggleAll event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final allComplete = (state as TodosLoaded).todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = [];
      for (var todo in (state as TodosLoaded).todos) {
        final toggledTodo = todo.copyWith(complete: !allComplete);
        updatedTodos.add(toggledTodo);
        try {
          await _todoRepository.updateTodo(toggledTodo);
        } catch (e) {
          print('Error toggling todo on backend: $e');
        }
      }
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));
    }
  }

  Future<void> _onClearCompleted(ClearCompleted event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final completedTodos = (state as TodosLoaded).todos.where((todo) => todo.complete).toList();
      final updatedTodos = (state as TodosLoaded).todos.where((todo) => !todo.complete).toList();
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));

      for (var todo in completedTodos) {
        try {
          await _todoRepository.deleteTodo(todo);
        } catch (e) {
          print('Error clearing completed todo from backend: $e');
        }
      }
    }
  }

  void _onUpdateFilter(UpdateFilter event, Emitter<TodoState> emit) {
    if (state is TodosLoaded) {
      emit((state as TodosLoaded).copyWith(activeFilter: event.filter));
    }
  }

  Future<void> _onUndoDeleteTodo(UndoDeleteTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final List<Todo> currentTodos = List.from((state as TodosLoaded).todos);
      if (event.index >= 0 && event.index <= currentTodos.length) {
        currentTodos.insert(event.index, event.todo);
      } else {
        currentTodos.add(event.todo);
      }
      emit((state as TodosLoaded).copyWith(todos: currentTodos));

      try {
        await _todoRepository.addTodo(event.todo);
      } catch (e) {
        print('Error undoing delete todo on backend: $e');
      }
    }
  }

  // Handler cho sự kiện Logout
  Future<void> _onLogout(Logout event, Emitter<TodoState> emit) async {
    try {
      await _todoRepository.logout();
      // Sau khi logout thành công, chúng ta có thể chuyển state về trạng thái ban đầu
      // hoặc một trạng thái biểu thị người dùng đã đăng xuất.
      // Tuy nhiên, việc điều hướng màn hình sẽ do Widget đảm nhiệm.
      emit(TodosLoading()); // Reset state sau khi logout
    } catch (e) {
      print('Error during logout: $e');
      // Xử lý lỗi logout (ví dụ: hiển thị thông báo lỗi cho người dùng)
      // Giữ nguyên trạng thái hiện tại hoặc chuyển sang trạng thái lỗi nếu cần
    }
  }
}
import 'package:equatable/equatable.dart';
import '/models/todo.dart';
import '/utils/app_constants.dart';

// Lớp cơ sở cho tất cả các trạng thái Todo
abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

// Trạng thái khi todos đang được tải
class TodosLoading extends TodoState {}

// Trạng thái khi todos đã được tải thành công
class TodosLoaded extends TodoState {
  final List<Todo> todos;
  final VisibilityFilter activeFilter; // Bộ lọc hiện tại

  const TodosLoaded({
    this.todos = const [],
    this.activeFilter = VisibilityFilter.all,
  });

  // Lấy danh sách todos đã lọc
  List<Todo> get filteredTodos {
    switch (activeFilter) {
      case VisibilityFilter.all:
        return todos;
      case VisibilityFilter.active:
        return todos.where((todo) => !todo.complete).toList();
      case VisibilityFilter.completed:
        return todos.where((todo) => todo.complete).toList();
    }
  }

  // Lấy số lượng todos đã hoàn thành
  int get numCompleted => todos.where((todo) => todo.complete).length;

  // Lấy số lượng todos chưa hoàn thành
  int get numActive => todos.length - numCompleted;

  // Phương thức copyWith để tạo bản sao của trạng thái với các thay đổi
  TodosLoaded copyWith({
    List<Todo>? todos,
    VisibilityFilter? activeFilter,
  }) {
    return TodosLoaded(
      todos: todos ?? this.todos,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object> get props => [todos, activeFilter];

  @override
  String toString() {
    return 'TodosLoaded { todos: $todos, activeFilter: $activeFilter }';
  }
}

// Trạng thái khi có lỗi khi tải todos
class TodosNotLoaded extends TodoState {}
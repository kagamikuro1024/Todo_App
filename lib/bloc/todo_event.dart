import 'package:equatable/equatable.dart';
import '/models/todo.dart';
import '/utils/app_constants.dart';

// Lớp cơ sở cho tất cả các sự kiện Todo
abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện để tải danh sách todos
class LoadTodos extends TodoEvent {}

// Sự kiện để thêm một todo mới
class AddTodo extends TodoEvent {
  final Todo todo;

  const AddTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

// Sự kiện để cập nhật một todo hiện có
class UpdateTodo extends TodoEvent {
  final Todo todo;

  const UpdateTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

// Sự kiện để xóa một todo
class DeleteTodo extends TodoEvent {
  final Todo todo;

  const DeleteTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

// Sự kiện để chuyển đổi trạng thái hoàn thành của tất cả todos
class ToggleAll extends TodoEvent {}

// Sự kiện để xóa tất cả các todos đã hoàn thành
class ClearCompleted extends TodoEvent {}

// Sự kiện để cập nhật bộ lọc hiển thị todos
class UpdateFilter extends TodoEvent {
  final VisibilityFilter filter;

  const UpdateFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

// Sự kiện để hoàn tác xóa một todo
class UndoDeleteTodo extends TodoEvent {
  final Todo todo;
  final int index;

  const UndoDeleteTodo(this.todo, this.index);

  @override
  List<Object> get props => [todo, index];
}
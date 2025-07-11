import 'package:equatable/equatable.dart';
import '/models/todo.dart';
import '/models/search_filter.dart';
import '../utils/app_constants.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final Todo todo;

  const AddTodo(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'AddTodo { todo: $todo }';
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  const UpdateTodo(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'UpdateTodo { todo: $todo }';
}

class DeleteTodo extends TodoEvent {
  final Todo todo;

  const DeleteTodo(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'DeleteTodo { todo: $todo }';
}

class ToggleAll extends TodoEvent {}

class ClearCompleted extends TodoEvent {}

class UpdateFilter extends TodoEvent {
  final VisibilityFilter filter;

  const UpdateFilter(this.filter);

  @override
  List<Object> get props => [filter];

  @override
  String toString() => 'UpdateFilter { filter: $filter }';
}

class UndoDeleteTodo extends TodoEvent {
  final Todo todo;
  final int index;

  const UndoDeleteTodo(this.todo, this.index);

  @override
  List<Object> get props => [todo, index];

  @override
  String toString() => 'UndoDeleteTodo { todo: $todo, index: $index }';
}

// Thêm sự kiện Logout
class Logout extends TodoEvent {}

// Các event mới cho chức năng tìm kiếm
class UpdateSearchFilter extends TodoEvent {
  final SearchFilter searchFilter;

  const UpdateSearchFilter(this.searchFilter);

  @override
  List<Object> get props => [searchFilter];

  @override
  String toString() => 'UpdateSearchFilter { searchFilter: $searchFilter }';
}

class ClearSearchFilter extends TodoEvent {}

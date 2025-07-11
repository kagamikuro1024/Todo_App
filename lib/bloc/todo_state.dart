import 'package:equatable/equatable.dart';
import '/models/todo.dart';
import '/models/search_filter.dart';
import '/utils/app_constants.dart';

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
  final VisibilityFilter activeFilter;
  final SearchFilter searchFilter;

  const TodosLoaded({
    this.todos = const [],
    this.activeFilter = VisibilityFilter.all,
    this.searchFilter = const SearchFilter(),
  });

  // Lấy danh sách todos đã lọc theo filter
  List<Todo> get filteredTodos {
    List<Todo> filtered = todos;

    // Lọc theo VisibilityFilter
    switch (activeFilter) {
      case VisibilityFilter.all:
        break;
      case VisibilityFilter.active:
        filtered = filtered.where((todo) => !todo.complete).toList();
        break;
      case VisibilityFilter.completed:
        filtered = filtered.where((todo) => todo.complete).toList();
        break;
    }

    // Lọc theo SearchFilter
    if (searchFilter.hasFilters) {
      // Lọc theo query (tên)
      if (searchFilter.query.isNotEmpty) {
        filtered = filtered.where((todo) {
          return todo.task.toLowerCase().contains(
                searchFilter.query.toLowerCase(),
              ) ||
              todo.note.toLowerCase().contains(
                searchFilter.query.toLowerCase(),
              );
        }).toList();
      }

      // Lọc theo trạng thái
      switch (searchFilter.status) {
        case SearchStatus.all:
          break;
        case SearchStatus.active:
          filtered = filtered.where((todo) => !todo.complete).toList();
          break;
        case SearchStatus.completed:
          filtered = filtered.where((todo) => todo.complete).toList();
          break;
      }

      // Lọc theo ngày tạo
      if (searchFilter.startDate != null) {
        filtered = filtered.where((todo) {
          return todo.createdAt.isAfter(searchFilter.startDate!) ||
              todo.createdAt.isAtSameMomentAs(searchFilter.startDate!);
        }).toList();
      }

      if (searchFilter.endDate != null) {
        filtered = filtered.where((todo) {
          return todo.createdAt.isBefore(searchFilter.endDate!) ||
              todo.createdAt.isAtSameMomentAs(searchFilter.endDate!);
        }).toList();
      }
    }

    return filtered;
  }

  // Lấy số lượng todos đã hoàn thành
  int get numCompleted => todos.where((todo) => todo.complete).length;

  // Lấy số lượng todos chưa hoàn thành
  int get numActive => todos.length - numCompleted;

  // Phương thức copyWith để tạo bản sao của trạng thái với các thay đổi
  TodosLoaded copyWith({
    List<Todo>? todos,
    VisibilityFilter? activeFilter,
    SearchFilter? searchFilter,
  }) {
    return TodosLoaded(
      todos: todos ?? this.todos,
      activeFilter: activeFilter ?? this.activeFilter,
      searchFilter: searchFilter ?? this.searchFilter,
    );
  }

  @override
  List<Object> get props => [todos, activeFilter, searchFilter];

  @override
  String toString() {
    return 'TodosLoaded { todos: $todos, activeFilter: $activeFilter, searchFilter: $searchFilter }';
  }
}

// Trạng thái khi có lỗi khi tải todos
class TodosNotLoaded extends TodoState {}

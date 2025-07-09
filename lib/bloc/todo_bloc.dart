
//import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'todo_event.dart';
import 'todo_state.dart';
import '/models/todo.dart';
import '/repositories/todo_repository.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _todoRepository;

  TodoBloc({required TodoRepository todoRepository})
      : _todoRepository = todoRepository,
        super(TodosLoading()) {
    // Đăng ký các trình xử lý sự kiện
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleAll>(_onToggleAll);
    on<ClearCompleted>(_onClearCompleted);
    on<UpdateFilter>(_onUpdateFilter);
    on<UndoDeleteTodo>(_onUndoDeleteTodo);
  }

  // Xử lý sự kiện LoadTodos
  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    try {
      final todos = await _todoRepository.loadTodos();
      emit(TodosLoaded(todos: todos));
    } catch (_) {
      emit(TodosNotLoaded());
    }
  }

  // Xử lý sự kiện AddTodo
  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final updatedTodos = List<Todo>.from((state as TodosLoaded).todos)..add(event.todo);
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));
      await _todoRepository.saveTodos(updatedTodos);
    }
  }

  // Xử lý sự kiện UpdateTodo
  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final updatedTodos = (state as TodosLoaded).todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));
      await _todoRepository.saveTodos(updatedTodos);
    }
  }

  // Xử lý sự kiện DeleteTodo
  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final updatedTodos = (state as TodosLoaded).todos.where((todo) => todo.id != event.todo.id).toList();
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));
      await _todoRepository.saveTodos(updatedTodos);
    }
  }

  // Xử lý sự kiện ToggleAll
  Future<void> _onToggleAll(ToggleAll event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final allComplete = (state as TodosLoaded).todos.every((todo) => todo.complete);
      final updatedTodos = (state as TodosLoaded).todos.map((todo) {
        return todo.copyWith(complete: !allComplete);
      }).toList();
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));
      await _todoRepository.saveTodos(updatedTodos);
    }
  }

  // Xử lý sự kiện ClearCompleted
  Future<void> _onClearCompleted(ClearCompleted event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final updatedTodos = (state as TodosLoaded).todos.where((todo) => !todo.complete).toList();
      emit((state as TodosLoaded).copyWith(todos: updatedTodos));
      await _todoRepository.saveTodos(updatedTodos);
    }
  }

  // Xử lý sự kiện UpdateFilter
  void _onUpdateFilter(UpdateFilter event, Emitter<TodoState> emit) {
    if (state is TodosLoaded) {
      emit((state as TodosLoaded).copyWith(activeFilter: event.filter));
    }
  }

  // Xử lý sự kiện UndoDeleteTodo
  Future<void> _onUndoDeleteTodo(UndoDeleteTodo event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final List<Todo> currentTodos = List.from((state as TodosLoaded).todos);
      // Chèn lại todo vào vị trí ban đầu hoặc cuối danh sách nếu không có index
      if (event.index >= 0 && event.index <= currentTodos.length) {
        currentTodos.insert(event.index, event.todo);
      } else {
        currentTodos.add(event.todo);
      }
      emit((state as TodosLoaded).copyWith(todos: currentTodos));
      await _todoRepository.saveTodos(currentTodos);
    }
  }
}
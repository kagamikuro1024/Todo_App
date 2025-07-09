import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/todo_event.dart';
import '/bloc/todo_state.dart';
//import '/models/todo.dart';
import '/screens/add_edit_screen.dart';
import '/utils/app_constants.dart';
import '/widgets/filter_button.dart';
import '/widgets/todo_item.dart';
import '/widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          // Nút chuyển đổi theme
          const ThemeToggleButton(),
          // Nút để chuyển đổi tất cả hoặc xóa tất cả đã hoàn thành
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_all') {
                context.read<TodoBloc>().add(ToggleAll());
              } else if (value == 'clear_completed') {
                context.read<TodoBloc>().add(ClearCompleted());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'toggle_all',
                child: Text('Đánh dấu tất cả hoàn thành/chưa hoàn thành'),
              ),
              const PopupMenuItem<String>(
                value: 'clear_completed',
                child: Text('Xóa tất cả đã hoàn thành'),
              ),
            ],
          ),
          // Nút lọc
          const FilterButton(),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodosLoaded &&
              state.todos.isEmpty &&
              state.activeFilter == VisibilityFilter.completed) {
            // Hiển thị SnackBar nếu không có todos nào và bộ lọc là "đã hoàn thành"
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Không có todo nào đã hoàn thành.'),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is TodosLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodosLoaded) {
            final filteredTodos = state.filteredTodos;
            if (filteredTodos.isEmpty) {
              return Center(
                child: Text(
                  state.activeFilter == VisibilityFilter.all
                      ? 'Chưa có todo nào. Nhấn "+" để thêm!'
                      : 'Không có todo nào ${state.activeFilter == VisibilityFilter.active ? 'chưa hoàn thành' : 'đã hoàn thành'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return TodoItem(
                  todo: todo,
                  onDismissed: (direction) {
                    // Xóa todo khi vuốt
                    context.read<TodoBloc>().add(DeleteTodo(todo));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa "${todo.task}"'),
                          action: SnackBarAction(
                            label: 'Hoàn tác',
                            onPressed: () {
                              context.read<TodoBloc>().add(
                                UndoDeleteTodo(todo, index),
                              );
                            },
                          ),
                        ),
                      );
                  },
                  onTap: () {
                    // Chỉnh sửa todo khi nhấn vào
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditScreen(isEditing: true, todo: todo),
                      ),
                    );
                  },
                  onCheckboxChanged: (_) {
                    // Đánh dấu hoàn thành/chưa hoàn thành
                    context.read<TodoBloc>().add(
                      UpdateTodo(todo.copyWith(complete: !todo.complete)),
                    );
                  },
                );
              },
            );
          } else if (state is TodosNotLoaded) {
            return const Center(child: Text('Không thể tải todos.'));
          }
          return const Center(child: Text('Trạng thái không xác định.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mở màn hình thêm todo mới
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddEditScreen(isEditing: false)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

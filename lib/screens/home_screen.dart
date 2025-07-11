import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/todo_event.dart';
import '/bloc/todo_state.dart';
//import '/models/todo.dart';
import '/screens/add_edit_screen.dart';
import '/utils/app_constants.dart';
//import '/widgets/filter_button.dart';
import '/widgets/todo_item.dart';
import '/widgets/search_widget.dart';
//import '/widgets/theme_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) async {
          debugPrint('[HomeScreen] State changed: ${state.runtimeType}');
          if (state is TodosLoaded) {
            debugPrint('[HomeScreen] Todos count: ${state.todos.length}');
          }

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
          // Nếu không thể tải todos (có thể do token hết hạn hoặc lỗi xác thực), chuyển về màn hình đăng nhập
          if (state is TodosNotLoaded) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('jwt_token');
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
        builder: (context, state) {
          debugPrint('[HomeScreen] Building with state: ${state.runtimeType}');
          if (state is TodosLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodosLoaded) {
            final filteredTodos = state.filteredTodos;
            debugPrint(
              '[HomeScreen] Filtered todos count: ${filteredTodos.length}',
            );

            return Column(
              children: [
                const SearchWidget(),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Danh sách công việc',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                Expanded(
                  child: filteredTodos.isEmpty
                      ? Center(
                          child: Text(
                            state.activeFilter == VisibilityFilter.all
                                ? 'Chưa có todo nào. Nhấn "+" để thêm!'
                                : 'Không có todo nào ${state.activeFilter == VisibilityFilter.active ? 'chưa hoàn thành' : 'đã hoàn thành'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTodos.length,
                          itemBuilder: (context, index) {
                            final todo = filteredTodos[index];
                            return TodoItem(
                              todo: todo,
                              onDismissed: (direction) {
                                // Xóa todo khi vuốt
                                print(
                                  '[HomeScreen] Deleting todo: ${todo.task}',
                                );
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
                                print(
                                  '[HomeScreen] Editing todo: ${todo.task}',
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddEditScreen(
                                      isEditing: true,
                                      todo: todo,
                                    ),
                                  ),
                                );
                              },
                              onCheckboxChanged: (_) {
                                // Đánh dấu hoàn thành/chưa hoàn thành
                                print(
                                  '[HomeScreen] Toggling todo: ${todo.task}',
                                );
                                context.read<TodoBloc>().add(
                                  UpdateTodo(
                                    todo.copyWith(complete: !todo.complete),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
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
          print('[HomeScreen] Opening add todo screen');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditScreen(isEditing: false),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

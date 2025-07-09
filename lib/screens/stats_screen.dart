import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/todo_state.dart';
import '/widgets/stats_card.dart';
import '/widgets/theme_toggle_button.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        actions: const [ThemeToggleButton()],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodosLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodosLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StatsCard(
                    title: 'Đã hoàn thành',
                    count: state.numCompleted,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  StatsCard(
                    title: 'Chưa hoàn thành',
                    count: state.numActive,
                    color: Colors.orange,
                  ),
                ],
              ),
            );
          } else if (state is TodosNotLoaded) {
            return const Center(child: Text('Không thể tải thống kê.'));
          }
          return const Center(child: Text('Trạng thái không xác định.'));
        },
      ),
    );
  }
}

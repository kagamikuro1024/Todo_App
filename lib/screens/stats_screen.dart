import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/todo_state.dart';
import '/widgets/stats_card.dart';
//import '/widgets/theme_toggle_button.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state is TodosLoading) {
          return Container(
            // Nền tổng thể
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is TodosLoaded) {
          return Container(
            // Nền tổng thể
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với icon và title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thống kê Todo',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                'Tổng quan công việc của bạn',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Stats Cards với animation
                    Column(
                      children: [
                        // Card hoàn thành
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          child: StatsCard(
                            title: 'Đã hoàn thành',
                            count: state.numCompleted,
                            color: Colors.white,
                            icon: Icons.check_circle,
                            subtitle: 'Công việc đã xong',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card chưa hoàn thành
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          child: StatsCard(
                            title: 'Chưa hoàn thành',
                            count: state.numActive,
                            color: Colors.white,
                            icon: Icons.pending,
                            subtitle: 'Công việc đang làm',
                          ),
                        ),
                      ],
                    ),

                    // Progress indicator
                    if (state.todos.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: isDarkMode
                                      ? Colors.green[400]
                                      : Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tiến độ hoàn thành',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Stack(
                              children: [
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeInOut,
                                  height: 12,
                                  width:
                                      MediaQuery.of(context).size.width *
                                      0.8 *
                                      (state.numCompleted / state.todos.length),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green[400]!,
                                        Colors.green[600]!,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${state.numCompleted}/${state.todos.length} công việc',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${((state.numCompleted / state.todos.length) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.green[400]
                                        : Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        } else if (state is TodosNotLoaded) {
          return Container(
            // Nền tổng thể
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Không thể tải thống kê',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        }
        return Container(
          // Nền tổng thể
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
          ),
          child: const Center(child: Text('Trạng thái không xác định.')),
        );
      },
    );
  }
}

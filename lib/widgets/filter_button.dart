import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/todo_event.dart';
import '/bloc/todo_state.dart';
import '/utils/app_constants.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        final activeFilter = state is TodosLoaded
            ? state.activeFilter
            : VisibilityFilter.all;
        return PopupMenuButton<VisibilityFilter>(
          onSelected: (filter) {
            context.read<TodoBloc>().add(UpdateFilter(filter));
          },
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<VisibilityFilter>>[
                PopupMenuItem<VisibilityFilter>(
                  value: VisibilityFilter.all,
                  child: Row(
                    children: [
                      const Text('Tất cả'),
                      if (activeFilter == VisibilityFilter.all)
                        const Icon(Icons.check, size: 16),
                    ],
                  ),
                ),
                PopupMenuItem<VisibilityFilter>(
                  value: VisibilityFilter.active,
                  child: Row(
                    children: [
                      const Text('Chưa hoàn thành'),
                      if (activeFilter == VisibilityFilter.active)
                        const Icon(Icons.check, size: 16),
                    ],
                  ),
                ),
                PopupMenuItem<VisibilityFilter>(
                  value: VisibilityFilter.completed,
                  child: Row(
                    children: [
                      const Text('Đã hoàn thành'),
                      if (activeFilter == VisibilityFilter.completed)
                        const Icon(Icons.check, size: 16),
                    ],
                  ),
                ),
              ],
          icon: const Icon(Icons.filter_list),
          tooltip: 'Lọc Todos',
        );
      },
    );
  }
}

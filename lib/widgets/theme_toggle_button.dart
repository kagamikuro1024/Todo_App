import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/bloc/theme_bloc.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state is ThemeInitial ? state.isDarkMode : false;

        return IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () {
            context.read<ThemeBloc>().add(ToggleTheme());
          },
          tooltip: isDarkMode
              ? 'Chuyển sang chế độ sáng'
              : 'Chuyển sang chế độ tối',
        );
      },
    );
  }
}

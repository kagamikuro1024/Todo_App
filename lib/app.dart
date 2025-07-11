import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import '/bloc/theme_bloc.dart';
import 'screens/login_screen.dart';
import '/bloc/todo_bloc.dart';
import '/bloc/todo_event.dart';
import '/widgets/filter_button.dart';
import '/widgets/theme_toggle_button.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), //
    StatsScreen(), //
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Hàm xử lý đăng xuất
  void _handleLogout() async {
    // Dispatch sự kiện Logout đến TodoBloc
    context.read<TodoBloc>().add(Logout()); //

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeInitial
            ? themeState.isDarkMode
            : false;
        return Scaffold(
          appBar: AppBar(
            title: Text(_selectedIndex == 0 ? 'Todos' : 'Thống kê'),
            actions: [
              // Nút chuyển đổi theme
              const ThemeToggleButton(), 
              // Nút để chuyển đổi tất cả hoặc xóa tất cả đã hoàn thành
              if (_selectedIndex == 0) ...[
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'toggle_all') {
                      // Dispatch sự kiện ToggleAll đến TodoBloc
                      context.read<TodoBloc>().add(ToggleAll()); //
                    } else if (value == 'clear_completed') {
                      // Dispatch sự kiện ClearCompleted đến TodoBloc
                      context.read<TodoBloc>().add(ClearCompleted()); //
                    } else if (value == 'logout') {
                      _handleLogout();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'toggle_all',
                          child: Text(
                            'Đánh dấu tất cả hoàn thành/chưa hoàn thành',
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'clear_completed',
                          child: Text('Xóa tất cả đã hoàn thành'),
                        ),
                        const PopupMenuDivider(), // Đường phân cách
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Text('Đăng xuất'), // Nút đăng xuất
                        ),
                      ],
                ),
                // Nút lọc
                const FilterButton(), //
              ] else ...[
                // Nút đăng xuất cho tab thống kê
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      _handleLogout();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Text('Đăng xuất'),
                        ),
                      ],
                ),
              ],
            ],
          ),
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todos'),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Thống kê',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blueAccent,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}

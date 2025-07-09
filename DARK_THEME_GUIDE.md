# Hướng dẫn sử dụng Dark Theme

## Cấu hình Dark Theme đã được thêm vào ứng dụng Todo

### 1. Các file đã được tạo/cập nhật:

#### **File mới:**
- `lib/bloc/theme_bloc.dart` - BLoC quản lý theme
- `lib/widgets/theme_toggle_button.dart` - Widget nút chuyển đổi theme

#### **File đã cập nhật:**
- `lib/main.dart` - Thêm ThemeBloc vào MultiBlocProvider
- `lib/app.dart` - Cấu hình light/dark theme
- `lib/screens/home_screen.dart` - Thêm nút chuyển đổi theme
- `lib/screens/stats_screen.dart` - Thêm nút chuyển đổi theme

### 2. Cách sử dụng:

#### **Chuyển đổi theme:**
- Nhấn vào nút **mặt trời** (☀️) hoặc **mặt trăng** (🌙) trên AppBar
- Nút sẽ hiển thị ở cả màn hình Todos và Thống kê

#### **Vị trí nút:**
- **HomeScreen**: Nút theme ở đầu AppBar (bên trái)
- **StatsScreen**: Nút theme ở cuối AppBar (bên phải)

### 3. Tính năng của Dark Theme:

#### **Light Theme (Mặc định):**
- Nền sáng, chữ tối
- AppBar màu xanh dương
- Card màu trắng với shadow
- Bottom navigation màu trắng

#### **Dark Theme:**
- Nền tối, chữ sáng
- AppBar màu xám đậm
- Card màu xám nhạt
- Bottom navigation màu xám đậm
- SnackBar màu sáng với chữ tối

### 4. Cấu trúc BLoC Theme:

```dart
// Events
ToggleTheme - Chuyển đổi giữa light/dark

// States
ThemeInitial - Chứa trạng thái isDarkMode

// BLoC
ThemeBloc - Xử lý logic chuyển đổi theme
```

### 5. Lưu ý kỹ thuật:

- Theme được quản lý bằng BLoC pattern
- Sử dụng `ThemeMode.dark` và `ThemeMode.light`
- Tự động áp dụng cho toàn bộ ứng dụng
- Không cần restart app khi chuyển đổi

### 6. Mở rộng:

Để thêm tính năng lưu trạng thái theme:
1. Thêm SharedPreferences để lưu `isDarkMode`
2. Load trạng thái khi khởi động app
3. Lưu trạng thái khi người dùng thay đổi

### 7. Chạy ứng dụng:

```bash
flutter pub get
flutter run
```

Sau đó nhấn vào nút theme trên AppBar để chuyển đổi giữa light và dark mode! 
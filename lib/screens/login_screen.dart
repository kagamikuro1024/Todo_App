import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import '/app.dart';
import '/widgets/theme_toggle_button.dart';
import 'register_screen.dart';
import '../services/api_service.dart';
import '../main.dart'; 

// Màn hình Đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn? _googleSignIn; // Khởi tạo lazy
  final String _backendUrl = 'http://10.0.2.2:3000'; // URL backend

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Khởi tạo Google Sign-In chỉ khi cần
  GoogleSignIn get _getGoogleSignIn {
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn!;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _googleSignIn?.disconnect(); // Cleanup Google Sign-In
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await _getGoogleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        if (!mounted) return; // Kiểm tra mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập Google đã bị hủy.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Gửi accessToken đến backend để xác thực và lấy JWT
      final response = await http.post(
        Uri.parse('$_backendUrl/auth/google/callback'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'accessToken': googleAuth.accessToken!,
        }),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String jwtToken = data['token'];

        // Lưu JWT token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwtToken);

        // Chuyển hướng đến màn hình chính sau khi đăng nhập thành công
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to login with Google: \n${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      // !!! QUAN TRỌNG: Kiểm tra mounted trước khi cập nhật UI hoặc điều hướng !!!
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Google Sign-In: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEmailPasswordSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final token = await api.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: const [ThemeToggleButton()],
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 36.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Chào mừng đến với Todo App!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Quản lý công việc của bạn mọi lúc, mọi nơi.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Email Input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Nhập email của bạn',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Input
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          hintText: 'Nhập mật khẩu của bạn',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _handleEmailPasswordSignIn,
                                  icon: const Icon(Icons.login),
                                  label: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).appBarTheme.backgroundColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      52,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'HOẶC',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _handleSignIn,
                                  icon: Image.asset(
                                    'assets/google_logo.png', 
                                    height: 28.0,
                                    width: 28.0,
                                  ),
                                  label: const Text(
                                    'Đăng nhập với Google',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                        minimumSize: const Size(
                                          double.infinity,
                                          52,
                                        ),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.0,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Colors.blueAccent.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                        shadowColor: Colors.blueAccent
                                            .withValues(alpha: 0.2),
                                      ).copyWith(
                                        overlayColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >(
                                              (states) =>
                                                  states.contains(
                                                    WidgetState.pressed,
                                                  )
                                                  ? Colors.blue.withValues(
                                                      alpha: 0.1,
                                                    )
                                                  : null,
                                            ),
                                      ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () {
                          // Chuyển hướng đến màn hình đăng ký
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Chưa có tài khoản? Đăng ký ngay',
                          style: TextStyle(
                            color: isDarkMode ? Colors.blueAccent : Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Đăng nhập mọi lúc, mọi nơi, trên bất kỳ thiết bị nào.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

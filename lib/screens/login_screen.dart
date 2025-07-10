import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/app.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String _backendUrl = 'http://localhost:3000'; // URL backend 

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Gửi accessToken đến backend để xác thực và lấy JWT
      final response = await http.post(
        Uri.parse('$_backendUrl/auth/google/callback'), // Backend sẽ xử lý callback từ Google
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'accessToken': googleAuth.accessToken!,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String jwtToken = data['token'];

        // Lưu JWT token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwtToken);

        // Chuyển hướng đến màn hình chính sau khi đăng nhập thành công
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TodoApp()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login with Google: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Google Sign-In: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập Todo App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào mừng đến với Todo App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _handleSignIn,
              icon: Image.asset(
                'assets/google_logo.png', // Thêm ảnh logo Google vào thư mục assets
                height: 24.0,
              ),
              label: const Text('Đăng nhập với Google', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
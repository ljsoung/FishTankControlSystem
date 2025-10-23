import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/response_handler.dart';
import 'reset_password_api.dart';

class InsertChangePasswordPage extends StatefulWidget {
  final String userId;

  const InsertChangePasswordPage({super.key, required this.userId});

  @override
  State<InsertChangePasswordPage> createState() =>
      _InsertChangePasswordPageState();
}

class _InsertChangePasswordPageState extends State<InsertChangePasswordPage> {
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  Future<void> _resetPassword() async {
    final newPassword = _newPwController.text.trim();
    final confirmNewPassword = _confirmPwController.text.trim();

    try {
      final response = await ResetPasswordApi.resetPassword(widget.userId, newPassword, confirmNewPassword);

      showResponseMessage(context, response);

      if (response.statusCode == 200) {

        Navigator.popUntil(context, (route) => route.isFirst); // 로그인 화면으로 복귀
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00BCD4),
              Color(0xFF2196F3),
              Color(0xFF006064),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Text(
                    '비밀번호 재설정',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _newPwController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '새 비밀번호',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _confirmPwController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '새 비밀번호 확인',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('되돌아가기'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: _resetPassword,
                        child: const Text('비밀번호 변경'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Image.asset('assets/fish_tank.png', height: 350),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

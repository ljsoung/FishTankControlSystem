import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/response_handler.dart';
import '../resetpw/reset_password_screen.dart';
import 'change_password_api.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _verifyUser() async {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();

    try {
      final response = await ChangePasswordApi.verifyUser(id, name);

      showResponseMessage(context, response);

      if (response.statusCode == 200) {

        // 다음 화면으로 이동하면서 ID 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsertChangePasswordPage(userId: id),
          ),
        );
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
                    '비밀번호 변경',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // ID
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 이름
                    TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 버튼 2개
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
                        onPressed: _verifyUser,
                        child: const Text('확인'),
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

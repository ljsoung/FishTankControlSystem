import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const FishTankApp());
}

// Fish_Tank라는 상단 제목? 타이틀 부분

class FishTankApp extends StatelessWidget {
  const FishTankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Tank',
      home: const FishTankLogin(),
    );
  }
}

// 로그인 화면 로직 구현

class FishTankLogin extends StatefulWidget {
  const FishTankLogin({super.key});

  @override
  State<FishTankLogin> createState() => _FishTankLoginState();
}

class _FishTankLoginState extends State<FishTankLogin> {
  bool _isChecked = false; // 체크박스 상태 저장 변수

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> _login() async {
    final String id = _idController.text;
    final String password = _pwController.text;

    try {
      // Spring Boot API 주소
      final url = Uri.parse("http://192.168.34.17:8080/api/user/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "password": password}),
      );

      showResponseMessage(context, response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data["token"];

        print("JWT TOKEN: $token");

        // 다음 화면으로 이동 예시
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버 연결 실패: $e")),
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
              Color(0xFF00BCD4), // 청록색
              Color(0xFF2196F3), // 밝은 파랑
              Color(0xFF006064), // 어두운 민트 블루
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
                    'Fish Tank',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 아이디
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: '아이디',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호
                  TextField(
                    controller: _pwController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 체크박스 추가 부분
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isChecked,
                        activeColor: Colors.white,
                        checkColor: Colors.blue,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        '자동 로그인',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 버튼 3개
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text('회원가입'),
                      ),
                      
                      // 비밀번호 변경
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChangePasswordPage()),
                          );
                        },
                        child: const Text('비밀번호 변경'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _login,
                        child: const Text('로그인'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 어항 이미지
                  Image.asset(
                    "assets/fish_tank.png",
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// 회원가입 화면
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwCheckController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _register() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();
    final pwCheck = _pwCheckController.text.trim();
    final name = _nameController.text.trim();

      // Spring Boot API 주소
      final url = Uri.parse("http://192.168.34.17:8080/api/user/register");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": id,
          "password": pw,
          "confirmPassword": pwCheck,
          "name": name,
        }),
      );

      showResponseMessage(context, response);

      if (response.statusCode == 200) {
        Navigator.pop(context); // 로그인 화면으로 돌아가기
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
              Color(0xFF00BCD4), // 청록색
              Color(0xFF2196F3), // 밝은 파랑
              Color(0xFF006064), // 어두운 민트 블루
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
                    '회원가입',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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

                  // 비밀번호
                  TextField(
                    controller: _pwController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호 확인
                  TextField(
                    controller: _pwCheckController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호 확인',
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
                          backgroundColor: Colors.white, // 버튼 배경 흰색
                          foregroundColor: Colors.black, // 글자색 (파란색)
                          side: BorderSide(color: Colors.black), // 테두리도 파란색
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // 되돌아가기
                        },
                        child: const Text('되돌아가기'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _register,
                        child: const Text('확인'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 어항 이미지
                  Image.asset(
                    'assets/fish_tank.png',
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 비밀번호 변경
class ChangePasswordPage extends StatelessWidget{
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00BCD4), // 청록색
              Color(0xFF2196F3), // 밝은 파랑
              Color(0xFF006064), // 어두운 민트 블루
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
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // ID
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),


                  // 이름
                  const TextField(
                    decoration: InputDecoration(
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
                          backgroundColor: Colors.white, // 버튼 배경 흰색
                          foregroundColor: Colors.black, // 글자색 (파란색)
                          side: BorderSide(color: Colors.black), // 테두리도 파란색
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // 되돌아가기
                        },
                        child: const Text('되돌아가기'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const InsertChangePasswordPage()),
                          );
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 어항 이미지
                  Image.asset(
                    'assets/fish_tank.png',
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// 변경할 비밀번호 입력
class InsertChangePasswordPage extends StatelessWidget{
  const InsertChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00BCD4), // 청록색
              Color(0xFF2196F3), // 밝은 파랑
              Color(0xFF006064), // 어두운 민트 블루
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
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // ID
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '변경할 비밀번호',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),


                  // 이름
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '변경할 비밀번호 확인',
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
                          backgroundColor: Colors.white, // 버튼 배경 흰색
                          foregroundColor: Colors.black, // 글자색 (파란색)
                          side: BorderSide(color: Colors.black), // 테두리도 파란색
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // 되돌아가기
                        },
                        child: const Text('되돌아가기'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // 확인 로직
                        },
                        child: const Text('비밀번호 변경'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 어항 이미지
                  Image.asset(
                    'assets/fish_tank.png',
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showResponseMessage(BuildContext context, http.Response response) {
  try {
    final data = jsonDecode(response.body);
    String message = "";

    if (data is Map && data.containsKey("message")) {
      // 일반적인 서버 메시지
      message = data["message"];
    }
    else if (data is List) {
      // 유효성 검사 실패 시: defaultMessage 필터링
      final messages = data
          .whereType<Map>() // Map 형태만 필터링
          .where((item) => item.containsKey("defaultMessage"))
          .map((item) => item["defaultMessage"].toString())
          .toList();

      message = messages.isNotEmpty ? messages.join("\n") : response.body;
    }
    else {
      message = response.body;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("응답 처리 중 오류: $e")),
    );
  }
}

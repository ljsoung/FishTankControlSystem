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

        if (!mounted) return;   // 비동기 확인
        // 메인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainFishTankScreen()),
        );
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

    final url = Uri.parse("http://192.168.34.17:8080/api/user/verify");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "name": name}),
      );

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


// 변경할 비밀번호 입력
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

    final url = Uri.parse("http://192.168.34.17:8080/api/user/reset");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": widget.userId, // 전달받은 id 사용
          "newPassword": newPassword,
          "confirmNewPassword": confirmNewPassword,
        }),
      );

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

void showResponseMessage(BuildContext context, http.Response response) {
  try {

    if (response.body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("서버에서 빈 응답을 받았습니다.")),
      );
      return;
    }

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

class MainFishTankScreen extends StatelessWidget {
  const MainFishTankScreen({super.key});

  // 메인 화면 UI
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final horizontalPadding = (sw * 0.03).clamp(8.0, 24.0);
    final verticalPadding = (sh * 0.012).clamp(6.0, 16.0);

    return Scaffold(
      body: SafeArea(
        child: Container(
          // ✅ 배경: 그라데이션 효과 적용
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF00BCD4), // 청록색
                Color(0xFF2196F3), // 밝은 파랑
                Color(0xFF006064), // 어두운 민트 블루
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 상단 수질 데이터
              Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [ // 추후 센서 데이터와 연동시 고정값 변경
                    Expanded(child: _buildDataBox("DO: 100")),
                    SizedBox(width: sw * 0.02),
                    Expanded(child: _buildDataBox("TDS: 250")),
                    SizedBox(width: sw * 0.02),
                    Expanded(child: _buildDataBox("23°C")),
                  ],
                ),
              ),

              // 중앙 이미지 부분
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/fish_tank.png',
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ),
              ),


              //하단 메뉴 버튼 3개
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: SizedBox(
                  height: 130, // 버튼 2줄을 보여줄 충분한 높이 확보
                  child: GridView.count(
                    crossAxisCount: 2, //한 줄에 2개씩
                    mainAxisSpacing: 10, // 세로 간격
                    crossAxisSpacing: 10, // 가로 간격
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    childAspectRatio: 3.8, //버튼 비율 (가로 : 세로) - 화면에 맞춰 조절 가능
                    children: [
                      _buildMenuButton("꾸미기", Icons.brush),
                      _buildMenuButton("어종 선택", Icons.pets),
                      _buildMenuButton("센서 데이터", Icons.sensors),
                      _buildMenuButton("사료 배식 시간", Icons.alarm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 상단 데이터 박스 위젯
  Widget _buildDataBox(String label) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black38, width: 1),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown, // 텍스트가 박스보다 커지면 자동 축소
        child: Text(
          label,
          textAlign: TextAlign.center, // 여러 줄일 때 중앙 정렬
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // 🔹 하단 버튼 위젯
  Widget _buildMenuButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: 페이지 이동 기능 추가 가능
      },
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black26),
        ),
      ),
    );
  }
}

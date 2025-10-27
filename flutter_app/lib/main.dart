import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

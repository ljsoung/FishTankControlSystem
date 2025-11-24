import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point') // 안드로이드 백그라운드 동작
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드에서 알림 도착!");
  print("제목: ${message.notification?.title}");
  print("내용: ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const FishTankApp());
}

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


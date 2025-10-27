import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

final FlutterLocalNotificationsPlugin _notifications =
FlutterLocalNotificationsPlugin();

// ✅ 정확한 알람 설정 화면 열기 (Android 12+)
Future<void> openExactAlarmSettings() async {
  try {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  } catch (e) {
    print("⚠️ 정확한 알람 설정창 열기 실패: $e");
  }
}

// ✅ 알림 초기화 함수
void initializeNotifications() async {
  tzdata.initializeTimeZones();

  const AndroidInitializationSettings initAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings settings =
  InitializationSettings(android: initAndroid);

  await _notifications.initialize(settings);

  // ✅ Android 13 이상에서 알림 권한 요청
  final status = await Permission.notification.request();
  if (status.isGranted) {
    print('🔔 알림 권한 허용됨');
  } else {
    print('🚫 알림 권한 거부됨');
  }
}

// ✅ 특정 시각에 알림 예약
Future<void> scheduleFeedNotification(DateTime targetTime) async {
  try {
    await _notifications.zonedSchedule(
      0, // 알림 ID
      '🐟 사료 배식 시간이에요!',
      '지금 사료를 주셔야 할 시간입니다.',
      tz.TZDateTime.from(targetTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feed_channel',
          'Feed Timer',
          channelDescription: '사료 배식 알림',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  } on PlatformException catch (e) {
    // ✅ 정확한 알람 권한이 없을 경우 처리
    if (e.code == 'exact_alarms_not_permitted') {
      print("⚠️ 정확한 알람 권한이 필요합니다. 설정창을 엽니다.");
      await openExactAlarmSettings();
    } else {
      print("❌ 알림 스케줄링 실패: $e");
      rethrow;
    }
  }
}

// ✅ 배식 시간 설정 UI
Future<String?> showFeedTimePicker(BuildContext context) async {
  int selectedHour = 0;
  int selectedMinute = 0;

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        height: 300,
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              '사료 배식 시간 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: const Duration(hours: 0, minutes: 0),
                onTimerDurationChanged: (Duration newDuration) {
                  selectedHour = newDuration.inHours;
                  selectedMinute = newDuration.inMinutes % 60;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final target =
                  now.add(Duration(hours: selectedHour, minutes: selectedMinute));

                  // ✅ 알림 예약
                  await scheduleFeedNotification(target);

                  // ✅ 포맷된 시간 텍스트 반환
                  final formatted =
                      '${selectedHour.toString().padLeft(2, '0')}시간 ${selectedMinute.toString().padLeft(2, '0')}분 후';
                  Navigator.pop(context, formatted);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('사료 배식 알림이 $formatted에 설정되었습니다.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: const Text('확인', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

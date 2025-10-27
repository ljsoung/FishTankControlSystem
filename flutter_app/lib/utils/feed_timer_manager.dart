import 'dart:async';
import 'package:flutter/material.dart';

class FeedTimerManager {
  Duration? remainingTime;
  Timer? timer;
  String? feedTimeText;

  final VoidCallback onTimeUpdate; // UI 업데이트 콜백
  final BuildContext context;

  FeedTimerManager({
    required this.context,
    required this.onTimeUpdate,
  });

  // ✅ Duration → “MM:SS” 형태로 변환
  String formatDuration(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // ✅ 카운트다운 시작
  void startCountdown(Duration duration) {
    timer?.cancel();
    remainingTime = duration;
    onTimeUpdate();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingTime!.inSeconds <= 1) {
        t.cancel();
        handleFeedTimeReached();
      } else {
        remainingTime = remainingTime! - const Duration(seconds: 1);
        onTimeUpdate();
      }
    });
  }

  // ✅ 타이머 종료 시 처리
  void handleFeedTimeReached() {
    feedTimeText = "00:00";

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🐟 밥을 줄 시간이에요!"),
        duration: Duration(seconds: 3),
      ),
    );

    // TODO: 자동 배식 제어 로직 (ex: Spring Boot → Raspberry Pi)
    // ex) await http.post("$baseUrl/api/feeder/start")

    Future.delayed(const Duration(seconds: 3), () {
      startCountdown(const Duration(minutes: 1)); // 1분 자동 재시작
    });
  }

  // ✅ 종료
  void dispose() {
    timer?.cancel();
  }
}

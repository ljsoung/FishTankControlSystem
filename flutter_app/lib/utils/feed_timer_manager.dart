import 'dart:async';
import 'package:flutter/material.dart';

class FeedTimerManager {
  Duration? remainingTime;
  Timer? timer;
  String? feedTimeText;
  Duration? initialDuration;


  final VoidCallback onTimeUpdate; // UI 업데이트 콜백
  final BuildContext context;

  FeedTimerManager({
    required this.context,
    required this.onTimeUpdate,
  });

  // “HH:MM:SS” 형태로 변환
  String formatDuration(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      return "$h:$m:$s";
    } else {
      return "$m:$s";
    }
  }

  // ✅ 카운트다운 시작
  void startCountdown(Duration duration) {
    timer?.cancel();
    initialDuration = duration;
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

    if (initialDuration != null) {
      startCountdown(initialDuration!);
    }
  }

  // ✅ 종료
  void dispose() {
    timer?.cancel();
  }
}

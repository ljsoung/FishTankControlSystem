import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                onPressed: () {
                  // ✅ 포맷된 시간 텍스트 반환
                  final formatted =
                      '${selectedHour.toString().padLeft(2, '0')}시간 ${selectedMinute.toString().padLeft(2, '0')}분 후';
                  Navigator.pop(context, formatted);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('배식 시간이 $formatted 로 설정되었습니다.'),
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

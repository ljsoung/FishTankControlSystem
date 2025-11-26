import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> showFeedTimePicker(BuildContext context) async {
  Duration selectedDuration = const Duration(hours: 0, minutes: 0);

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
                  selectedDuration = newDuration;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () async {
                  final hours = selectedDuration.inHours;
                  final minutes = selectedDuration.inMinutes % 60;

                  final formatted =
                      '${hours.toString().padLeft(2, '0')}시간 '
                      '${minutes.toString().padLeft(2, '0')}분 후';

                  // ESP IP 주소
                  const espIp = "http://192.168.0.142/feedTime";

                  // ESP로 POST 전송
                  await http.post(
                    Uri.parse(espIp),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "hours": hours,
                      "minutes": minutes,
                      "totalSeconds": selectedDuration.inSeconds,
                    }),
                  );

                  Navigator.pop(context, formatted);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('배식 시간이 설정되었습니다. ($formatted)'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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

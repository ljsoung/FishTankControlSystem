// response_handler.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    } else if (data is List) {
      // 유효성 검사 실패 시: defaultMessage 필터링
      final messages = data
          .whereType<Map>() // Map 형태만 필터링
          .where((item) => item.containsKey("defaultMessage"))
          .map((item) => item["defaultMessage"].toString())
          .toList();

      message = messages.isNotEmpty ? messages.join("\n") : response.body;
    } else {
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

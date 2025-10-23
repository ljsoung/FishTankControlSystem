// reset_password_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordApi {
  static Future<http.Response> resetPassword(String id, String newPassword, String confirmNewPassword) {
    final url = Uri.parse("http://192.168.34.17:8080/api/user/reset");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "newPassword": newPassword,
        "confirmNewPassword": confirmNewPassword,
      }),
    );
  }
}

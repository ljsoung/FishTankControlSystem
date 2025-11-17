// change_password_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChangePasswordApi {
  static Future<http.Response> verifyUser(String id, String name) {
    // final url = Uri.parse("https://jwejweiya.shop/api/user/verify");
    final url = Uri.parse("http://192.168.34.17:8080/api/user/verify");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "name": name}),
    );
  }
}

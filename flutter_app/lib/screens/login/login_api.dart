// login_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginApi {
  static Future<http.Response> loginUser(String id, String password) {
    final url = Uri.parse("https://54.116.12.17:8080/api/user/login");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "password": password}),
    );
  }
}

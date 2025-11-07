// login_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginApi {
  static Future<http.Response> loginUser(String id, String password) {
    final url = Uri.parse("https://jwejweiya.shop/api/user/login");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "password": password}),
    );
  }
}

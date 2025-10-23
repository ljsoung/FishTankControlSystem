// signup_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupApi {
  static Future<http.Response> registerUser(String id, String password, String confirmPassword, String name) {
    final url = Uri.parse("http://192.168.34.17:8080/api/user/register");
    return http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "password": password,
        "confirmPassword": confirmPassword,
        "name": name,
      }),
    );
  }
}

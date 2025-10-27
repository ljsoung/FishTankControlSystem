
import 'dart:io' show Platform;

String getBaseUrl() {
  if (Platform.isAndroid) return 'http://10.0.2.2:8080';
  if (Platform.isIOS) return 'http://127.0.0.1:8080';
  return 'http://localhost:8080';
}
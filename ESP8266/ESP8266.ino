#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WebServer.h>
#include <SoftwareSerial.h>

// 와이파이 정보
const char* ssid     = "Flip5_0201";
const char* password = "dltmdwns";

// 1시간마다 받는 센서데이터를 보낼 서버 주소 (예: 로컬 서버 or jwejweiya.shop의 테스트 엔드포인트)
const char* senserServerUrl = "https://jwejweiya.shop/api/sensor/input";

// 사료량 데이터를 보낼 서버 주소 (예: 로컬 서버 or jwejweiya.shop의 테스트 엔드포인트)
const char* feedServerUrl = "https://jwejweiya.shop/api/sensor/feed";

// 센서 토큰 (앱에서 보낸 POST 내부에서 받아오기)
String sensorToken = "";

// HTTP 서버 (앱이 토큰 설정할 때 사용)
ESP8266WebServer server(80);

// UNO <-> ESP용 소프트웨어 시리얼 (ESP 기준 D6=RX, D5=TX)
SoftwareSerial unoSerial(D6, D5);  // RX, TX

unsigned long lastPostTime = 0;
const unsigned long postIntervalMs = 10 * 1000;   // 10초마다 전송 (테스트용)

// ====== UNO에 최초 센서 데이터 요청 ======
void requestInitialSensorDataFromUno() {
  // 프로토콜: "REQ_FIRST\n" 한 줄을 UNO로 보냄
  unoSerial.println("REQ_FIRST");
  Serial.println("#ESP: UNO에 최초 센서 데이터 측정 요청 전송");
}

// ====== 토큰 설정용 핸들러 ======
void handleRoot() {
  String msg = "ESP8266 Sensor Node\n";
  msg += "현재 센서 토큰: ";
  msg += (sensorToken.length() > 0 ? sensorToken : "(현재 미설정)");
  server.send(200, "text/plain", msg);
}

// 앱에서 POST /setToken 으로 호출
// Body 예시: {"sensorToken":"fbb8...1054"}
void handleSetToken() {
  if (server.method() != HTTP_POST) {
    server.send(405, "text/plain", "Use POST");
    return;
  }

  String body = server.arg("plain");  // raw body
  Serial.println("#ESP: === 토큰 설정 요청 도착 ===");
  Serial.println(body);

  // 1) JSON 형식에서 sensorToken 뽑기
  String token = "";

  // 아주 단순 파싱 (나중에 필요하면 ArduinoJson 쓰면 됨)
  const String key = "\"sensorToken\":\"";
  int idx = body.indexOf(key);
  if (idx >= 0) {
    idx += key.length();
    int end = body.indexOf("\"", idx);
    if (end > idx) {
      token = body.substring(idx, end);
    }
  }

  // 만약 JSON이 아니라 그냥 토큰만 온 경우도 처리
  if (token.length() == 0) {
    body.trim();
    token = body;  // raw 문자열을 토큰으로 간주
  }

  if (token.length() == 0) {
    server.send(400, "text/plain", "No sensorToken found");
    Serial.println("#ESP: sensorToken 파싱 실패");
    return;
  }

  if (sensorToken != token) {
    sensorToken = token;
    Serial.print("#ESP: 센서 토큰 업데이트: ");
    Serial.println(sensorToken);

    //토큰 업데이트 시에만 최초 센서 데이터 요청
    requestInitialSensorDataFromUno();
  }
    
  // TODO: 나중에 여기서 LittleFS/EEPROM에 저장하면, 전원 꺼져도 유지 가능

  server.send(200, "application/json", "{\"status\":\"ok\"}");
}

// 앱에서 받은 사료 배식 시간 UNO에 전송
void handleFeedTime() {
  if (server.method() != HTTP_POST) {
    server.send(405, "text/plain", "Use POST");
    return;
  }

  String body = server.arg("plain"); // raw JSON body 문자열 받기
  Serial.println("#ESP: === feedTime 설정 요청 도착 ===");
  Serial.println(body);

  // ---------- 1) totalSeconds 파싱 ----------
  long totalSeconds = -1;

  const String key = "\"totalSeconds\":";
  int idx = body.indexOf(key);
  if (idx >= 0) {
    idx += key.length();

    // 공백 스킵
    while (idx < (int)body.length() && 
           (body[idx] == ' ' || body[idx] == '\t')) {
      idx++;
    }

    // 숫자 부분만 추출
    String num = "";
    while (idx < (int)body.length() && isDigit(body[idx])) {
      num += body[idx];
      idx++;
    }

    if (num.length() > 0) {
      totalSeconds = num.toInt();
    }
  }

  // totalSeconds 못 찾았으면 hours/minutes로 재계산 시도
  if (totalSeconds <= 0) {
    long hours = 0;
    long minutes = 0;

    // hours
    int hIdx = body.indexOf("\"hours\":");
    if (hIdx >= 0) {
      hIdx += String("\"hours\":").length();
      while (hIdx < (int)body.length() && 
             (body[hIdx] == ' ' || body[hIdx] == '\t')) {
        hIdx++;
      }
      String hNum = "";
      while (hIdx < (int)body.length() && isDigit(body[hIdx])) {
        hNum += body[hIdx];
        hIdx++;
      }
      if (hNum.length() > 0) hours = hNum.toInt();
    }

    // minutes
    int mIdx = body.indexOf("\"minutes\":");
    if (mIdx >= 0) {
      mIdx += String("\"minutes\":").length();
      while (mIdx < (int)body.length() && 
             (body[mIdx] == ' ' || body[mIdx] == '\t')) {
        mIdx++;
      }
      String mNum = "";
      while (mIdx < (int)body.length() && isDigit(body[mIdx])) {
        mNum += body[mIdx];
        mIdx++;
      }
      if (mNum.length() > 0) minutes = mNum.toInt();
    }

    totalSeconds = hours * 3600L + minutes * 60L;
  }

  // 그래도 유효한 값이 없으면 에러 반환
  if (totalSeconds <= 0) {
    Serial.println("#ESP: totalSeconds 파싱 실패");
    server.send(400, "text/plain", "invalid totalSeconds");
    return;
  }

  // ---------- 2) ms 단위로 변환 ----------
  unsigned long intervalMs = (unsigned long)totalSeconds * 1000UL;

  // ---------- 3) UNO에게 FEED_INTERVAL:값 전송 ----------
  String cmd = "FEED_INTERVAL:";
  cmd += String(intervalMs);

  unoSerial.println(cmd);  // UNO 쪽에서 SoftwareSerial로 이걸 읽어서 파싱

  // 디버깅용 cmd 내용 확인
  Serial.print("#ESP: 최종 cmd 내용 = [");
  Serial.print(cmd);
  Serial.println("]");

  // ---------- 4) 앱에게 응답 ----------
  server.send(200, "application/json", "{\"status\":\"ok\"}");
}

// ====== 서버로 JSON 전송 함수 ======
void sendJsonToServer(const String& jsonBody, const char* url) {
  if (sensorToken.length() == 0) {
    Serial.println("#ESP: sensorToken 이 비어 있어서 전송하지 않음");
    return;
  }

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("#ESP: WiFi 끊김, 재연결 시도...");
    WiFi.disconnect();
    WiFi.begin(ssid, password);

    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < 10000) {
      delay(500);
      Serial.print(".");
    }
    Serial.println();
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("#ESP: 재연결 실패, 이번 전송은 건너뜀");
      return;
    }
  }

  WiFiClientSecure client;
  client.setInsecure();   // HTTPS 인증서 검사 비활성화

  HTTPClient http;

  Serial.print("#ESP: 서버에 POST 시도: ");
  Serial.println(url);
  Serial.print("#ESP: 보낼 바디: ");
  Serial.println(jsonBody);

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Authorization", "Sensor " + sensorToken);

  int httpCode = http.POST(jsonBody);

  if (httpCode > 0) {
    Serial.printf("#ESP: 응답 코드: %d\n", httpCode);
    String payload = http.getString();
    Serial.println("#ESP: 응답 바디:");
    Serial.println(payload);
  } else {
    Serial.printf("#ESP: POST 실패: %s\n",
                  http.errorToString(httpCode).c_str());
  }

  http.end();
  Serial.println("#ESP: ============================\n");
}

// ====== Wi-Fi 연결 & 서버 시작 ======
void setup() {
  Serial.begin(9600);
  unoSerial.begin(9600);
  delay(1000);

  Serial.println();
  Serial.println("#ESP: ESP8266 센서 노드 시작");

  // WiFi 연결
  WiFi.begin(ssid, password);
  Serial.print("#ESP: WiFi 연결 중");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("#ESP: WiFi 연결 완료! IP: ");
  Serial.println(WiFi.localIP());

  // HTTP 서버 라우트 등록
  server.on("/", HTTP_GET, handleRoot);
  server.on("/setToken", HTTP_POST, handleSetToken);
  server.on("/feedTime", HTTP_POST, handleFeedTime);
  server.begin();
  Serial.println("HTTP 서버 시작 (/setToken 대기 중)");
}

// ====== 메인 루프 ======
void loop() {
  // 1) 항상 HTTP 서버 요청 처리 (앱에서 토큰 설정 등)
  server.handleClient();

  // 2) UNO에서 온 JSON을 감지 → DB로 POST
  if (unoSerial.available()) {
    String line = unoSerial.readStringUntil('\n');
    line.trim();

    if (line.length() > 0) {
      Serial.print("#ESP: UNO로부터 수신: ");
      Serial.println(line);

      if (line[0] == '{') {
        // JSON 내용에 따라 분기
        if (line.indexOf("\"distance\"") >= 0 &&
            line.indexOf("\"temperature\"") < 0 &&
            line.indexOf("\"doValue\"")     < 0 &&
            line.indexOf("\"ph\"")          < 0) {

          Serial.println("#ESP: distance 전용 JSON 감지 → feedServerUrl로 전송");
          sendJsonToServer(line, feedServerUrl);   // /api/sensor/feed

        } else {
          Serial.println("#ESP: 일반 센서 JSON 감지 → senserServerUrl로 전송");
          sendJsonToServer(line, senserServerUrl); // /api/sensor/input
        }
      } else {
        Serial.println("#ESP: JSON 아님, 전송은 건너뜀");
      }
    }
  }
  delay(10);
}
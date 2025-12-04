#include <OneWire.h>
#include <DallasTemperature.h>
#include <RTClib.h>
#include <Servo.h>
#include <SoftwareSerial.h>
#include <math.h>  // pow()

// ---------------- 핀 설정 ----------------
const int PIN_TDS     = A0;  // SEN0244 TDS AOUT
const int PIN_DO      = A1;  // SEN0237 DO AOUT
const int PIN_DS18B20 = 2;   // DS18B20 DATA
const int PIN_TRIG    = 3;   // HC-SR04 TRIG
const int PIN_ECHO    = 4;   // HC-SR04 ECHO
const int PIN_SERVO   = 5;   // SG90 Signal

// UNO 기준: D10 = RX, D11 = TX  (TX 쪽은 반드시 분압해서 ESP RX(D6)로!)
SoftwareSerial espSerial(10, 11);  // (RX, TX)

// ---------------- DS18B20 ----------------
OneWire oneWire(PIN_DS18B20);
DallasTemperature tempSensor(&oneWire);

// ---------------- DS3231 ----------------
RTC_DS3231 rtc;
bool rtcAvailable = false;

// ---------------- 서보 ----------------
Servo feederServo;

// 측정 주기 (현재 2분)
const unsigned long MEASURE_INTERVAL_MS = 3600000UL;
unsigned long lastMeasureMillis = 0;

// ESP로부터 "REQ_FIRST"를 받았는지 여부
bool measurementStarted = false;

// -------- 배식(모터) 주기 --------
// FEED_INTERVAL(ms) 값, 0이면 자동 배식 비활성
unsigned long feedIntervalMs = 0;
unsigned long lastFeedMillis = 0;


// =================== DO(SEN0237) 계산용 상수/테이블 ===================
// UNO 5V 기준 (mV 단위)
#define DO_VREF_MV   5000      // 5.0V -> 5000mV
#define DO_ADC_RES   1024      // 10bit ADC

// Single-point / Two-point 보정 모드
#define TWO_POINT_CALIBRATION 0   // 0: 단일점 보정, 1: 2점 보정

// ★ 단일점 보정용 상수 (예시값)
//   실제로 포화 DO 용액에서 센서 전압/온도 재서 다시 넣어줘야 정확해짐
#define CAL1_V 1600   // 포화 DO 상태에서의 센서 출력 (mV) 예시
#define CAL1_T 25    // 그때의 수온(℃) 예시

// 2점 보정 쓰고 싶으면 아래 값도 실제 측정값으로 세팅
#define CAL2_V 1300   // 낮은 온도에서 포화 DO 전압 (mV) 예시
#define CAL2_T 15     // 그때의 수온(℃) 예시

// DO 포화 농도 테이블 (0~40℃, μg/L 단위, 14460 = 14.460 mg/L)
const uint16_t DO_Table[41] = {
  14460, 14220, 13820, 13440, 13090, 12740, 12420, 12110, 11810, 11530,
  11260, 11010, 10770, 10530, 10300, 10080, 9860, 9660, 9460, 9270,
  9080, 8900, 8730, 8570, 8410, 8250, 8110, 7960, 7820, 7690,
  7560, 7430, 7300, 7180, 7070, 6950, 6840, 6730, 6630, 6530, 6410
};

// DO 계산 함수 (μg/L 단위 리턴)
int16_t readDO(uint32_t voltage_mv, uint8_t temperature_c)
{
#if TWO_POINT_CALIBRATION == 0
  // 단일점 보정
  uint16_t V_saturation = (uint32_t)CAL1_V + (uint32_t)35 * temperature_c - (uint32_t)CAL1_T * 35;
  return (voltage_mv * DO_Table[temperature_c] / V_saturation);
#else
  // 2점 보정
  uint16_t V_saturation = (int16_t)((int8_t)temperature_c - CAL2_T) * ((uint16_t)CAL1_V - CAL2_V) / ((uint8_t)CAL1_T - CAL2_T) + CAL2_V;
  return (voltage_mv * DO_Table[temperature_c] / V_saturation);
#endif
}


// ====== HC-SR04 거리 측정 함수 ======
float measureUltrasonicDistance(bool printLog) {
  long duration;
  float distanceCm = -1.0;

  digitalWrite(PIN_TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(PIN_TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(PIN_TRIG, LOW);

  duration = pulseIn(PIN_ECHO, HIGH, 30000);  // 타임아웃 30ms

  if (duration == 0) {
    if (printLog) {
      Serial.println("[ULTRA] Echo 시간 없음 (배선/센서 확인 필요)");
    }
    distanceCm = -1.0;  // 측정 실패
  } else {
    distanceCm = duration * 0.0343 / 2.0;
    if (printLog) {
      Serial.print("[ULTRA] Distance = ");
      Serial.print(distanceCm, 1);
      Serial.println(" cm");
    }
  }
  return distanceCm;
}

// ====== 배식 + 거리 측정 + ESP로 JSON 전송 ======
void doFeedingAndSendDistance() {
  Serial.println("===== [FEED] 배식 시작 =====");

  // 1) 서보로 배식 동작
  feederServo.write(20);
  delay(1000);
  feederServo.write(60);     // 실제 먹이가 떨어지는 각도로 조정 (필요시 조절)
  delay(1000);               // 사료 떨어질 시간
  feederServo.write(20);
  delay(1000);

  Serial.println("[FEED] 서보 동작 완료, 거리 측정 시작");

  // 2) HC-SR04로 거리 측정
  float distanceCm = measureUltrasonicDistance(true);

  // 3) JSON 형태로 ESP에 전송: {"distance": value}
  if (distanceCm >= 0.0) {
    Serial.print("[TO ESP] 거리 JSON 전송: ");
    Serial.print("{\"distance\":");
    Serial.print(distanceCm, 1);
    Serial.println("}");

    espSerial.print("{\"distance\":");
    espSerial.print(distanceCm, 1);
    espSerial.println("}");
  } else {
    Serial.println("[FEED] 거리 측정 실패, JSON 전송 생략");
  }

  Serial.println("===== [FEED] 배식 + 거리 전송 완료 =====");
}

// ========== 센서 1회 측정 + ESP 전송 ==========
void measureAndSendOnce() {
  Serial.println("------------------------------------------------");

  // ----- DS18B20 (수온) -----
  tempSensor.requestTemperatures();
  float tempC = tempSensor.getTempCByIndex(0);
  Serial.print("[TEMP] DS18B20 = ");
  if (tempC == DEVICE_DISCONNECTED_C) {
    Serial.println("센서 연결 오류, TDS/DO 온도보정에 25℃ 사용");
    tempC = 25.0;   // 온도 센서 에러 시 기본값
  } else {
    Serial.print(tempC, 2);
    Serial.println(" °C");
  }

  // ----- TDS (SEN0244) -----
  int   tdsRaw     = analogRead(PIN_TDS);
  float tdsVoltage = tdsRaw * (5.0 / 1023.0);  // 0~5V

  // 온도 보정 계수 (약 2%/℃)
  float compensationCoefficient = 1.0 + 0.02 * (tempC - 25.0);
  float compensationVoltage     = tdsVoltage / compensationCoefficient;

  // DFRobot 예제 기반 근사식 (센서 보정 전, 대략적인 값)
  float tdsPPM = (133.42 * pow(compensationVoltage, 3)
                - 255.86 * pow(compensationVoltage, 2)
                + 857.39 * compensationVoltage) * 0.5;

  Serial.print("[TDS] raw=");
  Serial.print(tdsRaw);
  Serial.print("  V=");
  Serial.print(tdsVoltage, 3);
  Serial.print("  CompV=");
  Serial.print(compensationVoltage, 3);
  Serial.print("  TDS≈");
  Serial.print(tdsPPM, 1);
  Serial.println(" ppm");


  // ----- DO (SEN0237) 실제 측정 -----
  // DS18B20에서 읽은 tempC를 그대로 사용 (0~40도로 제한해서 테이블 인덱스로 사용)
  uint8_t doTempIndex = (uint8_t)constrain(tempC, 0.0, 40.0);

  uint16_t doRaw     = analogRead(PIN_DO);
  uint16_t doVoltage = (uint32_t)DO_VREF_MV * doRaw / DO_ADC_RES;  // mV 단위
  uint16_t doUgL     = readDO(doVoltage, doTempIndex);             // μg/L
  float    doValue   = doUgL / 1000.0;                             // mg/L 로 변환

  Serial.print("[DO] raw=");
  Serial.print(doRaw);
  Serial.print("  V(mV)=");
  Serial.print(doVoltage);
  Serial.print("  DO=");
  Serial.print(doValue, 2);
  Serial.println(" mg/L");

  // ----- DS3231 (RTC) -----
  // if (rtcAvailable) {
  //   DateTime now = rtc.now();
  //   Serial.print("[RTC] ");
  //   Serial.print(now.year());  Serial.print("-");
  //   Serial.print(now.month()); Serial.print("-");
  //   Serial.print(now.day());   Serial.print(" ");
  //   Serial.print(now.hour());  Serial.print(":");
  //   Serial.print(now.minute());Serial.print(":");
  //   Serial.println(now.second());
  // } else {
  //   Serial.println("[RTC] 사용 불가 (초기화 실패)");
  // }

  // ----- ESP로 보낼 JSON 만들기 & 전송 -----
  Serial.print("[TO ESP] ");
  Serial.print("{\"temperature\":");
  Serial.print(tempC, 2);
  Serial.print(",\"doValue\":");
  Serial.print(doValue, 2);   // DO mg/L
  Serial.print(",\"ph\":");
  Serial.print(tdsPPM, 0);    // 일단 TDS ppm을 ph 필드에 전송(추후 변수명 바꿔도 됨)
  Serial.println("}");

  espSerial.print("{\"temperature\":");
  espSerial.print(tempC, 2);
  espSerial.print(",\"doValue\":");
  espSerial.print(doValue, 2);
  espSerial.print(",\"ph\":");
  espSerial.print(tdsPPM, 0);
  espSerial.println("}");

  Serial.println("==== 이번 측정 및 ESP 전송 완료 ====");
}

// ========== ESP 명령 수신 ==========
void checkEspCommand() {
  if (espSerial.available()) {
    String cmd = espSerial.readStringUntil('\n');
    cmd.trim();
    if (cmd.length() == 0) return;

    Serial.print("[FROM ESP] ");
    Serial.println(cmd);

    // 2) 배식 주기 설정: FEED_INTERVAL:600000 (ms 단위)
    if (cmd != "REQ_FIRST") {

      Serial.println("===== [CMD] FEED_INTERVAL 명령 수신 =====");
      Serial.print("[CMD] 원본 문자열: ");
      Serial.println(cmd);
      
      String numStr = cmd.substring(String("FEED_INTERVAL:").length());
      numStr.trim();

      unsigned long newInterval = (unsigned long)numStr.toInt(); // ms 단위
      Serial.println("FEED_INTERVAL 수신 받음");
      if (newInterval > 0) {
        feedIntervalMs = newInterval;
        lastFeedMillis = millis();   // 새 주기로 다시 카운트 시작
        Serial.print("[CMD] 배식 주기 변경: ");
        Serial.print(feedIntervalMs);
        Serial.println(" ms");
      } else {
        Serial.println("[CMD] 잘못된 FEED_INTERVAL 값");
      }
      Serial.println("===== [CMD] FEED_INTERVAL 처리 완료 =====");
    }
    // 1) 최초 측정 시작 + 측정중 REQ_FIRST 들어오면 초기화 후 다시 진행
    else if (cmd == "REQ_FIRST") {
        measurementStarted = true;

        // REQ_FIRST 받자마자 바로 한 번 측정하게 타이머 조정
        lastMeasureMillis = millis() - MEASURE_INTERVAL_MS;
        lastFeedMillis    = millis();  // 배식 타이머도 이 시점부터 계산

        Serial.println("[CMD] REQ_FIRST 수신 - 측정/배식 타이머 초기화 후 다시 시작");
    }
    else {
      Serial.println("[CMD] 알 수 없는 명령 (무시)");
    }
  }
}

// ========== setup ==========
void setup() {
  Serial.begin(9600);
  espSerial.begin(9600);

  delay(1000);
  Serial.println(F("=== UNO START ==="));
  Serial.println(F("WAITING REQ_FIRST..."));

  tempSensor.begin();

  if (!rtc.begin()) {
    Serial.println(F("RTC ERROR"));
    rtcAvailable = false;
  } else {
    rtcAvailable = true;
    Serial.println(F("RTC OK"));
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }

  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);

  feederServo.attach(PIN_SERVO);
  feederServo.write(0);
  Serial.println(F("[SERVO] INIT 0deg READY"));

  lastMeasureMillis = millis();
  lastFeedMillis    = millis();
}


// ========== loop ==========
void loop() {
  unsigned long nowMs = millis();

  // 1) ESP에서 오는 명령(REQ_FIRST, FEED_INTERVAL 등) 처리
  checkEspCommand();

  // 2) REQ_FIRST를 받은 이후부터만 센서 측정 & 배식 로직 수행
  if (measurementStarted) {
    // 센서 측정 주기
    if (nowMs - lastMeasureMillis >= MEASURE_INTERVAL_MS) {
      lastMeasureMillis = nowMs;
      measureAndSendOnce();
    }

    // 배식 주기 (FEED_INTERVAL로 받은 시간 간격마다 실행)
    if (feedIntervalMs > 0 && nowMs - lastFeedMillis >= feedIntervalMs) {
      lastFeedMillis = nowMs;
      doFeedingAndSendDistance();
    }
  }

  delay(10);
}

# 어항 관리 지원 서비스앱 README
<img width="2880" height="1619" alt="undefined-" src="https://github.com/user-attachments/assets/6507453b-c320-43f1-ba62-026beeba6a26" />

## 프로젝트 소개
 - FishTankControlSystem은 물고기를 키울 때 변화하는 어항 환경을 하드웨어를 통해 모니터링하고 관리하여 키우는 물고기의 최상의 어항 환경을 유지할 수 있도록 돕는 어플리케이션입니다.
 - 본인이 키우는 어류를 직접 선택하고 해당 어류에 맞게 필요한 환경 변수들을 적절히 조절하여 최상의 어항 환경을 제공합니다.
 - 다양한 연령대가 접근하기 쉽게 귀여운 그림으로 인터페이스를 제공하고 호감도를 통해 본인의 물고기 캐릭터를 꾸밀 수 있습니다.
 - 데이터 통계를 통해 시간, 일, 주 단위로 어항의 환경 변화를 한눈으로 파악할 수 있게 제공합니다.
 - 사료 배식 시간 설정을 통해 자동으로 원하는 시간 단위로 물고기에게 사료를 배식할 수 있도록 설계되었습니다.

## 팀원 구성
<table>
  <tr>
    <th>임지성</th>
    <th>이승준</th>
    <th>유희수</th>
  </tr>
  <tr>
    <td align="center">
      <a href="https://github.com/ljsoung">@ljsoung</a>
    </td>
    <td align="center">
      <a href="https://github.com/SaMeL-dev">@SaMeL-dev</a>
    </td>
    <td align="center">
      <a href="https://github.com/Uhsoo02">@Uhsoo02</a>
    </td>
  </tr>
</table>

## 기술 스택
| 구분 | 기술 스택 |
|------|-----------|
| **언어** | Java(Spring Boot), Dart(Flutter), Python, Arduino |
| **모바일 앱** | Flutter, HTTP 통신, Custom UI/Widget |
| **백엔드** | Spring Boot 3.5.7, JPA, Spring Security(JWT), Lombok, Gradle |
| **API 연동** | REST API(JSON), Postman 테스트 |
| **DB** | MySQL, JPA |
| **하드웨어(IoT)** | SEN0244(TDS), DS18B20(Temperature), SEN0237(DO), Arduino UNO Board, SG-90, HC-SR04, ESP8266 NodeMCU V3(WIFI Module) |
| **네트워크** | REST API, WIFI, HTTP JSON 데이터 송수신 |
| **시각화** | Flutter Charts |
| **보안** | JWT 토큰 인증, BCryptPasswordEncoder, Spring Security 필터 체인 |
| **IDE / Tool** | IntelliJ IDEA, Android Studio, GitHub, Postman |

## 시스템 아키텍쳐
<img width="1589" height="726" alt="SystemArchitecture2" src="https://github.com/user-attachments/assets/1bae915b-eb4a-495c-9a18-db50a364716d" />


## 프로젝트 구조
### 1. Backend
```
backend/
└── src
    ├── main
    │   ├── java
    │   │   └── com.iotbigdata.fishtankproject
    │   │       ├── config/
    |   |       |   ├── FirebaseConfig.java
    │   │       │   └── SecurityConfig.java
    │   │       │
    │   │       ├── controller/
    │   │       │   ├── FishController.java
    │   │       │   ├── SensorController.java
    │   │       │   ├── SensorTokenController.java
    │   │       │   └── UserController.java
    │   │       │
    │   │       ├── domain/
    │   │       │   ├── AppUser.java
    │   │       │   ├── Role.java
    │   │       │   ├── Fish.java
    │   │       │   ├── Likability.java
    │   │       │   ├── SensorEntity.java
    │   │       │   ├── SensorToken.java
    │   │       │   ├── DissolvedOxygen.java
    │   │       │   ├── WaterQuality.java
    │   │       │   └── WaterTemperature.java
    │   │       │
    │   │       ├── dto/
    │   │       │   ├── PasswordResetDto.java
    │   │       │   ├── SensorInputDto.java
    │   │       │   ├── UserLoginDto.java
    │   │       │   ├── UserRegisterDto.java
    │   │       │   └── VerifyUserDto.java
    │   │       │
    │   │       ├── repository/
    │   │       │   ├── UserRepository.java
    │   │       │   ├── FishRepository.java
    │   │       │   ├── LikabilityRepository.java
    │   │       │   ├── SensorTokenRepository.java
    │   │       │   ├── DissolvedOxygenRepository.java
    │   │       │   ├── WaterQualityRepository.java
    │   │       │   └── WaterTemperatureRepository.java
    │   │       │
    │   │       ├── security/
    │   │       │   ├── JwtAuthenticationFilter.java
    │   │       │   └── JwtTokenProvider.java
    │   │       │
    │   │       └── service/
    |   |           ├── FcmService.java
    │   │           ├── LoginService.java
    │   │           ├── UserService.java
    │   │           ├── FishService.java
    │   │           ├── LikabilityService.java
    │   │           ├── SensorService.java
    │   │           └── SensorTokenService.java
    │   │
    │   └── resources
    │       ├── application.properties
    │       └── application-test.properties
    │
    └── test
        └── InsertTestSensorData.java # 테스트 데이터 삽입
```
### 2. Flutter 모바일 앱 구조
```
flutter_app/
├── assets/
│   ├── decoration_image/
│   └── fish_species/
│
├── lib/
│   ├── screens/
│   │   ├── change_password/
│   │   │   ├── change_password_api.dart
│   │   │   └── change_password_screen.dart
│   │   │
│   │   ├── datagraph/
│   │   │   └── sensor_detail_screen.dart
│   │   │
│   │   ├── fish/
│   │   │   ├── decoration_sheet.dart
│   │   │   ├── feed_time_picker.dart
│   │   │   └── select_fish_species.dart 
│   │   │
│   │   ├── login/
│   │   │   ├── login_api.dart
│   │   │   └── login_screen.dart
│   │   │
│   │   ├── main/
│   │   │   └── main_screen.dart
│   │   │
│   │   ├── resetpw/
│   │   │   ├── reset_password_api.dart
│   │   │   └── reset_password_screen.dart
│   │   │
│   │   └── signup/
│   │       ├── signup_api.dart
│   │       └── signup_screen.dart
│   │
│   ├── utils/
│   │   ├── feed_timer_manager.dart
│   │   └── response_handler.dart
│   │
│   ├── widgets/
│   │   └── animated_fish.dart
│   │
│   └── main.dart
│
├── android/
├── ios/
├── linux/
├── macos/
├── windows/
└── pubspec.yaml
```
## 역할 분담
### 🐠 임지성
 - **Backend**
   - DB/JPA
   - 로그인/회원가입 기능(JWT 토큰 인증/BCryptPasswordEncoder) 구현
   - 어류별 적합 환경 조사
   - 센서 데이터 POST 요청 응답 로직 구현
   - 메인화면에 가장 최근 센서 데이터 전송
   - 센서 전용 토큰 기능 추가
   - 데이터 시각화를 위한 센서 데이터 필터링 및 전송
   - 호감도 구현
   - Postman을 통한 테스트
   - 각종 예외들에 대한 예외 처리
   - Firebase Cloud Messaging을 활용하여 사료 부족 시 앱에 알림 전송 구현
  
 - **App**
   - 각 기능에 Spring Boot와 JSON을 통한 요청 및 응답 구현
   - 사료 배식 시간 설정 기능 추가
   - 사용자가 선택한 어류를 안전하게 전달
   - 호감도 표시 UI 및 호감도에 따른 물고기 꾸미기 기능 구현
   - 앱 알림 기능 구현
   - APK 추출
  
### 🐟 이승준
 - **Project Manage**
   - 요구사항 정리 및 우선순위 조정
   - 스마트어항 필요성 및 센서·하드웨어 조사
   - 센서 및 하드웨어 선정
   - 핵심 기능 범위 확정
   - 전체 시스템 아키텍처 설계
   - 워크플로우 및 구조 문서화
   - 애자일 단계 확립
   - 앱 UI 구조·화면 흐름 설계 및 구현
     
 - **Frontend**
   - 로그인 성공 시 메인화면 이동 구현 
   - 메인화면 UI 구현
   - 센서 데이터 시각화 기능 설계 및 구현
   - 앱 프론트 코드 영역 리팩토링
  
 - **IoT Hardware & Communication**
   - ESP8266 펌웨어 구현
   - 하드웨어-앱-서버 데이터 전송 구조 설계
   - 사료 배식시간 설정 기능의 네트워크 연동 구현
   - 자동 배식기 제작/구성
   - SEN0237(용존산소), DS18B20(수온), SEN0244(TDS), SG-90 센서 테스트
   - 센서 모듈 설치 및 동작 환경 구축
   - 통신 안정화를 위한 파이프라인 구축
   - 네트워크 및 통신 이슈 분석·개선

### 🐡 유희수
 - **Frontend**
   - 앱 기초 UI 프레임/레이아웃 설계 및 구현
   - 앱 로그인 화면 구현
   - 앱 회원가입 화면 구현
   - 앱 비밀번호 변경 화면 구현
   - 앱 UI 이미지 생성 및 구현
   - 메인화면 하단 메뉴 수정
   - 어종 선택 기능 UI 구현
   - 어종 선택 이미지 추가 및 적용
   - 꾸미기 기능 UI 구현
   - 꾸미기 기능 이미지 추가 및 적용
  
- **Hardware**
   - 프로젝트 필요 센서 품목 조사 및 구상
   - SEN0237(용존산소), DS18B20(수온), SEN0244(TDS), HC-SR04, SG-90 센서 테스트
   - 환경 측정 센서 연결 구성
   - 모터 및 초음파 부품 연결 및 동작 구성
   - ESP8266 통신 모듈 연결 및 전체 배선 담당
   - 센서 보관함/사료통 배식기 제작 초안 구상

## 개발 기간 및 작업 관리
### 개발 기간
 - 2025.09.01 ~ 2025.12.19

### 작업 관리
 - 카카오톡 등으로 TODO 리스트 정리하여 공유
 - Github로 코드 작성 후 Commit/Push하여 진행 상황 공유
 - 매일 1~2시간 가량 진도 체크 및 개발 진행

## 프로젝트 진행 중 이슈
TODO
## 앱 기능
### 1. 사용자 인증
 - JWT를 활용하여 안전하게 로그인이 가능하도록 구현
 - 비밀번호 분실을 대비한 비밀번호 찾기 및 재설정 기능 구현
 - 사용자 별로 센서 토큰을 생성하여 센서가 각각의 사용자에 맞게 안전하게 값을 저장할 수 있도록 구현

### 2. 어류 선택 및 맞춤 어항 설정
 - 사용자가 키우는 어종을 선택할 수 있도록 구현
 - 선택한 어종에 대해 적합한 환경을 적용하여 어항 환경을 조절할 수 있도록 제공

### 3. 실시간 센서 데이터 조회
 - 수온/수질/용존산소 센서를 활용하여 실시간으로 센서 데이터를 조회
 - 메인 화면 접속 시 실시간으로 어항 환경을 파악할 수 있도록 최신 센서 값 표시

### 4. 센서 데이터 그래프 시각화
 - 시간/일/주 및 수온/수질/용존산소에 대한 변화 그래프 제공

### 5. 사료 배식 타이머 제공
 - 원하는 시간 주기마다 자동으로 사료 공급
 - 초음파 센서를 통한 실시간 사료 부족 감지 -> 사용자에게 알림 전송

### 6. 호감도 시스템
 - 최적의 어항 환경 유지에 대한 호감도 점수 제공

### 7. 물고기 꾸미기 기능
 - 다양한 장식 아이템 선택
 - 호감도 조건에 다라 장식 아이템 장금 해제

## 화면 구성도
<img width="1353" height="855" alt="화면 구성도" src="https://github.com/user-attachments/assets/ef2cceee-78ba-47a4-b33d-2fad4f07cd06" />


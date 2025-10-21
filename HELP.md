# Getting Started

### Initial Setting
Flutter
---
## Spring Boot
- Project Name : FishTankProject
- package Name : com.iotbigdata.fishtankproject
- Spring Boot Version : 3.5.6
- JDK : 17.0.2
- Dependencies
  - Spring Web : REST API 제작
  - Spring data JPA : DB 관리
  - MySQL Driver : JPA와 DB 통신용 JDBC 드라이버
  - Lombok : `@Getter`, `@Setter` 등 코드 간결화
  - Validation : 클라이언트 요청 유효성 검사
  - Spring Boot DevTools : 자동 리스타트
  - Spring Security : 로그인 및 JWT 토큰 인증 보안 구현
 
---

# Todo List
4. 센서 측정 간격 1시간, 데이터 확인 시 시간 -> 1시간, 하루, 일주일(평균 내기)

4-2. 1시간으로 delay 걸어서 자동으로 주기마다 값이 들어올 수 있게 설정 -> 라즈베리파이에서 진행
   
4-3. 받은 값을 사용자가 1시간, 하루, 일주일 선택에 따라 값을 조정하고 앱에 리턴할 수 있는 기능 구현 -> 값 가져오기 성공. 값이 조정되는지 추후 확인 필요

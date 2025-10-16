# Getting Started

### Initial Setting
Flutter
---
## Spring Boot
- Project Name : FishTankProject
- package Name : com.iotbigdata.fishtankproject
- Spring Boot Version : 3.5.6
- JDK : 17
- Dependencies
  - Spring Web : REST API 제작
  - Spring data JPA : DB 관리
  - MySQL Driver : JPA와 DB 통신용 JDBC 드라이버
  - Lombok : `@Getter`, `@Setter` 등 코드 간결화
  - Validation : 클라이언트 요청 유효성 검사
  - Spring Boot DevTools : 자동 리스타트
  - Spring Security : 로그인 및 JWT 토큰 인증 보안 구현
 

#Todo List
## Sign In
(회원가입 기능)
1. 아이디 중복 검사 로직
2. 비번 확인 로직
exception 처리를 통해 안전하게 앱에 message 전달 해야 함

## DB
user 테이블에 fish_type 컬럼 추가
fish 테이블 생성
fish_type(PK), 적합 온도, TDS(수질), 적합 용존산소

# 프로젝트 시작을 위한 초기 설정
개발 가이드 및 실행 리뉴얼 작성

## Flutter

---
## Spring Boot
- Package Name : com.iotbigdata.fishtank
- Type : Gradle - Groovy
- JDK : 17
- dependency
  - spring web : REST API를 만들기 위한 기본 모듈
  - Spring Data JPA : DB를 객체지향적으로 관리
  - MySQL Driver : JPA가 DB와 통신할 수 있게 하는 JDBC 드라이버
  - Lombok : `@Getter`, `@Setter` 등 코드 간결화
  - Validation : 클라이언트 요청 유효성 검사
  - Spring Boot Devtools : 자동 리스타트 등을 위함
  - Spring Security : 로그인, JWT 토근 인증 등 보안 관련 구현

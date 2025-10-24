package com.iotbigdata.fishtankproject.controller;

import com.iotbigdata.fishtankproject.dto.PasswordResetDto;
import com.iotbigdata.fishtankproject.dto.UserLoginDto;
import com.iotbigdata.fishtankproject.dto.UserRegisterDto;
import com.iotbigdata.fishtankproject.dto.VerifyUserDto;
import com.iotbigdata.fishtankproject.service.LoginService;
import com.iotbigdata.fishtankproject.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController // Json 형태 변환 -> 앱 연동용
@RequestMapping("/api/user")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // 앱에서 서버 API 호출 허용 기능
public class UserController {

    private final UserService userService;
    private final LoginService loginService;

    // 회원 가입
    @PostMapping("/register") // 회원가입 버튼 누를 시 여기 실행
    public synchronized ResponseEntity<?> register(@Valid @RequestBody UserRegisterDto dto, BindingResult result) {
        if (result.hasErrors()) { // 에러 확인
            return ResponseEntity.badRequest().body(result.getAllErrors());
        }
        try {
            userService.register(dto); // 회원 가입
            return ResponseEntity.ok(Map.of("message", "회원가입 완료")); // 회원가입 완료 시 body 리턴
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 비밀번호 재설정 전 본인 확인
    @PostMapping("/verify")
    public ResponseEntity<?> verifyUser(@Valid @RequestBody VerifyUserDto dto, BindingResult result) {
        if (result.hasErrors()) return ResponseEntity.badRequest().body(result.getAllErrors());
        try {
            userService.verifyUser(dto);
            return ResponseEntity.ok(Map.of("message", "사용자 확인 완료"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 비밀번호 재설정
    @PostMapping("/reset")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody PasswordResetDto dto, BindingResult result) {
        if (result.hasErrors()) { // 에러 확인
            return ResponseEntity.badRequest().body(result.getAllErrors());
        }
        try {
            userService.resetPassword(dto);
            return ResponseEntity.ok(Map.of("message", "비밀번호 변경 완료"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }



    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody UserLoginDto dto, BindingResult result) {
        if (result.hasErrors()) return ResponseEntity.badRequest().body(result.getAllErrors());
        try {
            String token = loginService.login(dto);
            return ResponseEntity.ok(Map.of("message", "로그인 성공", "token", token));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}

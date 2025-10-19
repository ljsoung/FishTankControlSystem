package com.iotbigdata.fishtankproject.controller;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.dto.UserLoginDto;
import com.iotbigdata.fishtankproject.dto.UserRegisterDto;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import com.iotbigdata.fishtankproject.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@RestController // Json 형태 변환 -> 앱 연동용
@RequestMapping("/api/user")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // 앱에서 서버 API 호출 허용 기능
public class UserController {

    private final UserService userService;
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    @PostMapping("/register")
    public synchronized ResponseEntity<?> register(@Valid @RequestBody UserRegisterDto dto, BindingResult result) {
        if (result.hasErrors()) { // 에러 확인
            return ResponseEntity.badRequest().body(result.getAllErrors());
        }
        try {
            AppUser user = dto.toEntity(); // 유저 정보 받아 옴
            userService.register(user); // 회원 가입
            return ResponseEntity.ok("회원가입 완료"); // 회원가입 완료 시 body 리턴
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody UserLoginDto dto, BindingResult result) {
        if (result.hasErrors()) { // 유효성 검사
            return ResponseEntity.badRequest().body(result.getAllErrors());
        }
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(dto.getId(), dto.getPassword())
            );
            return ResponseEntity.ok("로그인 성공"); // 로그인 성공 시 body 리턴
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}

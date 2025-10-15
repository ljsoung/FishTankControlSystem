package com.iotbigdata.fishtankproject.controller;

import com.iotbigdata.fishtankproject.domain.User;
import com.iotbigdata.fishtankproject.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@RestController // Json 형태 변환 -> 앱 연동용
@RequestMapping("/api/user")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // 앱에서 서버 API 호출 허용 기능
public class UserController {

    private final UserService userService;

    @PostMapping("/register")
    // JSON -> Java 객체로 자동 변환됨
    public ResponseEntity<?> register(@Valid @RequestBody User user, BindingResult result) {
        if (result.hasErrors()) {
            return ResponseEntity.badRequest().body(result.getAllErrors());
        }

        try {
            User savedUser = userService.register(user);
            return ResponseEntity.ok(savedUser);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}

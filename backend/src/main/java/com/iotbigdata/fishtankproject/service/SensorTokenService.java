package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.SensorToken;
import com.iotbigdata.fishtankproject.repository.SensorTokenRepository;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SensorTokenService {

    private final SensorTokenRepository sensorTokenRepository;
    private final UserRepository userRepository;

    // 센서용 토큰 발급 (앱에서 1회 요청)
    public ResponseEntity<?> registerSensor(UserDetails userDetails) {
        String userId = userDetails.getUsername();

        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        // 이미 발급된 토큰이 있는지 확인
        if (sensorTokenRepository.existsByUser_Id(userId)) {
            return ResponseEntity.badRequest().body(Map.of(
                    "status", "FAILED",
                    "message", "이미 등록된 센서가 존재합니다."
            ));
        }

        String token = UUID.randomUUID().toString();

        SensorToken sensorToken = new SensorToken();
        sensorToken.setUser(user);
        sensorToken.setToken(token);
        sensorTokenRepository.save(sensorToken);

        return ResponseEntity.ok(Map.of(
                "status", "OK",
                "message", "센서 인증 토큰이 발급되었습니다.",
                "sensorToken", token
        ));
    }

    // 토큰으로 사용자 찾기
    public AppUser getUserBySensorToken(String token) {
        return sensorTokenRepository.findByToken(token)
                .map(SensorToken::getUser)
                .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 센서 토큰입니다."));
    }
}

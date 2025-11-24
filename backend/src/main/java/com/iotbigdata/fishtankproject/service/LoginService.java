package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.SensorToken;
import com.iotbigdata.fishtankproject.dto.UserLoginDto;
import com.iotbigdata.fishtankproject.repository.SensorTokenRepository;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import com.iotbigdata.fishtankproject.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LoginService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final SensorTokenRepository sensorTokenRepository;
    private final UserRepository userRepository;

    public Map<String, Object> login(UserLoginDto dto) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(dto.getId(), dto.getPassword())
            );
            String jwtToken = jwtTokenProvider.createToken(dto.getId(), "CUSTOMER");

            AppUser user = userRepository.findById(dto.getId())
                    .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

            String sensorToken = sensorTokenRepository.findByUser_Id(dto.getId())
                    .map(SensorToken::getToken)
                    .orElseGet(() -> {
                        // 새로운 sensor_token 생성
                        String newToken = UUID.randomUUID().toString();
                        SensorToken st = new SensorToken();
                        st.setUser(user);
                        st.setToken(newToken);
                        sensorTokenRepository.save(st);
                        return newToken;
                    });

            System.out.println(sensorToken + "전달 완료");

            return Map.of(
                    "message", "로그인 성공",
                    "token", jwtToken,
                    "sensorToken", sensorToken
            );
        } catch (Exception e) {
            throw new IllegalArgumentException("아이디 또는 비밀번호가 올바르지 않습니다.");
        }
    }
}
package com.iotbigdata.fishtankproject;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.iotbigdata.fishtankproject.domain.User;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@AutoConfigureMockMvc
class FishTankProjectApplicationTests {

    @Autowired
    private UserRepository userRepository;

    @Test
    @DisplayName("회원가입 API 테스트 - 성공 케이스")
    void registerUserSuccess() {
        // given: 테스트용 유저 객체 생성
        User user = new User();
        user.setId("testId1234");
        user.setPassword("testPassword1234!!");
        user.setName("testName");
        userRepository.save(user);
    }
}

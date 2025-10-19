package com.iotbigdata.fishtankproject;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class FishTankProjectApplicationTests {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper; // JSON 변환용

    @Test
    @DisplayName("회원가입 API 테스트 - 성공 케이스")
    void registerUserSuccess() {
        // given: 테스트용 유저 객체 생성
        AppUser user = new AppUser();
        user.setId("testId1234");
        user.setPassword("testPassword1234!!");
        user.setName("testName");
        userRepository.save(user);
    }

    @Test
    @DisplayName("회원가입 API - 정상 등록 시 200 OK 반환 및 DB 저장 확인")
    void registerUserSuccess2() throws Exception {
        String uniqueId = "testId" + System.currentTimeMillis();

        // given: 요청용 DTO 생성
        Map<String, Object> userRegisterDto = new HashMap<>();
        userRegisterDto.put("id", uniqueId);
        userRegisterDto.put("password", "testPassword1234!!");
        userRegisterDto.put("confirmPassword", "testPassword1234!!"); // 비밀번호 확인
        userRegisterDto.put("name", "테스트유저");

        // when & then
        mockMvc.perform(post("/api/user/register")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userRegisterDto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(uniqueId))
                .andExpect(jsonPath("$.name").value("테스트유저"));
    }

}

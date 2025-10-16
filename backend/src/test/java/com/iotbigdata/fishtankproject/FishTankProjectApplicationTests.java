package com.iotbigdata.fishtankproject;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.iotbigdata.fishtankproject.domain.User;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

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
        User user = new User();
        user.setId("testId1234");
        user.setPassword("testPassword1234!!");
        user.setName("testName");
        userRepository.save(user);
    }

    @Test
    @DisplayName("회원가입 API - 정상 등록 시 200 OK 반환 및 DB 저장 확인")
    void registerUserSuccess2() throws Exception {
        User user = new User();
        user.setId("testUser123");
        user.setPassword("testPassword1234!!");
        user.setName("테스트유저");

        mockMvc.perform(post("/api/user/register")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value("testUser123"))
                .andExpect(jsonPath("$.name").value("테스트유저"));
    }
}

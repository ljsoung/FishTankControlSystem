package com.iotbigdata.fishtankproject.config;

import com.iotbigdata.fishtankproject.security.JwtAuthenticationFilter;
import com.iotbigdata.fishtankproject.security.JwtTokenProvider;
import com.iotbigdata.fishtankproject.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, UserService userService) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/api/user/login", "/api/user/register").permitAll() // 공개 경로
                        .anyRequest().authenticated() // 나머지는 인증 필요
                )
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                // JwtAuthenticationFilter를 직접 생성해서 주입
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider, userService),
                        UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}

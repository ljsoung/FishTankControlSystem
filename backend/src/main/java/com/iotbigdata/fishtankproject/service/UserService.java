package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.Role;
import com.iotbigdata.fishtankproject.domain.User;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor // final 자동 생성자 주입
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public User register(User user) {



        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encodedPassword);

        // Default -> Customer
        if (user.getRole() == null) {
            user.setRole(Role.CUSTOMER);
        }
        return userRepository.save(user);
    }
}

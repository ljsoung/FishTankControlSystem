package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.User;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor // final 자동 생성자 주입
public class UserService {

    private final UserRepository userRepository;

    public User register(User user) {
        return userRepository.save(user);
    }
}

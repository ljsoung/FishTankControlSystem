package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.Role;
import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.dto.PasswordResetDto;
import com.iotbigdata.fishtankproject.dto.UserRegisterDto;
import com.iotbigdata.fishtankproject.dto.VerifyUserDto;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // 회원가입
    public AppUser register(UserRegisterDto dto) {
        if (userRepository.existsById(dto.getId())) {
            throw new IllegalArgumentException("이미 존재하는 사용자입니다.");
        }

        AppUser user = dto.toEntity();
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRole(Role.CUSTOMER);
        return userRepository.save(user);
    }

    // 사용자 인증 (비밀번호 변경)
    public void verifyUser(VerifyUserDto dto) {
        userRepository.findByIdAndName(dto.getId(), dto.getName())
                .orElseThrow(() -> new UsernameNotFoundException("아이디 또는 이름이 일치하지 않습니다."));
    }

    // 비밀번호 변경
    public void resetPassword(PasswordResetDto dto) {
        AppUser user = userRepository.findById(dto.getId())
                .orElseThrow(() -> new UsernameNotFoundException("존재하지 않는 사용자입니다."));

        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        userRepository.save(user);
    }

    /** Spring Security용 */
    @Override
    public UserDetails loadUserByUsername(String id) throws UsernameNotFoundException {
        AppUser appUser = userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다."));
        return new User(appUser.getId(), appUser.getPassword(),
                List.of(() -> "ROLE_" + appUser.getRole().name()));
    }
}
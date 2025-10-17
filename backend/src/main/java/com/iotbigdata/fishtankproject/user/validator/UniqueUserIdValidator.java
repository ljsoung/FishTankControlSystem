package com.iotbigdata.fishtankproject.user.validator;

import com.iotbigdata.fishtankproject.user.repository.UserRepository;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component // 스프링 빈 등록
@RequiredArgsConstructor
public class UniqueUserIdValidator implements ConstraintValidator<UniqueUserId, String> {

    private final UserRepository userRepository;

    @Override
    public boolean isValid(String id, ConstraintValidatorContext context) {
        if (id == null || id.isBlank()){
            return false; //default Message 리턴됨
        }
        return !userRepository.existsById(id); // 존재하면 false
    }
}

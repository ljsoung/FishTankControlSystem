package com.iotbigdata.fishtankproject.validator;

import com.iotbigdata.fishtankproject.dto.UserRegisterDto;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class ConfirmUserPasswordValidator implements ConstraintValidator<ConfirmUserPassword, UserRegisterDto> {

    /*@Override
    public boolean isValid(UserRegisterDto dto, ConstraintValidatorContext context) {
        if (dto.getPassword() == null || dto.getConfirmPassword() == null)
            return false;

        return dto.getPassword().equals(dto.getConfirmPassword());
    }

     */

    @Override
    public boolean isValid(UserRegisterDto dto, ConstraintValidatorContext context) {
        // 둘 중 하나라도 비어 있으면 비교하지 않음 (NotBlank 어노테이션이 대신 처리)
        if (!StringUtils.hasText(dto.getPassword()) || !StringUtils.hasText(dto.getConfirmPassword())) {
            return true;
        }

        // 둘 다 값이 있을 때만 비교
        return dto.getPassword().equals(dto.getConfirmPassword());
    }
}

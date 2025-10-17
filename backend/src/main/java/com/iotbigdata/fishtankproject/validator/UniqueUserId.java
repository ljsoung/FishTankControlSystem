package com.iotbigdata.fishtankproject.validator;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ ElementType.FIELD }) // 필드용
@Retention(RetentionPolicy.RUNTIME) // 런타임 중에도 어노테이션 유지
@Constraint(validatedBy = UniqueUserIdValidator.class)
// 아이디 중복 검증 사용자 정의 어노테이션
public @interface UniqueUserId {
    String message() default "이미 존재하는 아이디입니다."; // 검증 실패 시 반환 메시지
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

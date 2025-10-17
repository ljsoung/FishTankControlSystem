package com.iotbigdata.fishtankproject.user.domain;

import com.iotbigdata.fishtankproject.user.validator.ConfirmUserPassword;
import com.iotbigdata.fishtankproject.user.validator.UniqueUserId;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@ConfirmUserPassword
public class UserRegisterDto {

    @NotBlank(message = "아이디는 필수 입력 항목입니다.")
    @Size(min = 4, max = 20, message = "아이디는 4~20자 사이여야 합니다.")
    @UniqueUserId
    private String id;

    @NotBlank(message = "비밀번호는 필수 입력 항목입니다.")
    @Size(min = 8, max = 20, message = "비밀번호는 최소 8자 이상이어야 합니다.")
    @Pattern(
            regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=]).{8,}$",
            message = "비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다."
    )
    private String password;

    @NotBlank(message = "비밀번호 확인은 필수입니다.")
    private String confirmPassword;

    @NotBlank(message = "이름은 필수 입력 항목입니다.")
    @Size(max = 30, message = "이름은 최대 30자까지 가능합니다.")
    private String name;

    // DTO → Entity 변환 메서드
    public User toEntity() {
        User user = new User();
        user.setId(this.id);
        user.setPassword(this.password);
        user.setName(this.name);
        user.setRole(Role.CUSTOMER);
        return user;
    }

}
package com.iotbigdata.fishtankproject.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PasswordResetDto {

    @NotBlank
    public String id;

    @NotBlank(message = "새 비밀번호 입력은 필수입니다.")
    @Size(min = 8, max = 20, message = "비밀번호는 최소 8자 이상이어야 합니다.")
    @Pattern(
            regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=]).{8,}$",
            message = "비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다."
    )
    public String newPassword;

    @NotBlank(message = "새 비밀번호 입력 확인은 필수입니다.")
    public String confirmNewPassword;

}

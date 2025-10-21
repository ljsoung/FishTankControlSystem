package com.iotbigdata.fishtankproject.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PasswordResetDto {

    @NotBlank(message = "아이디를 입력해주세요.")
    public String id;

    @NotBlank(message = "이름을 입력해주세요.")
    public String name;

    @NotBlank(message = "새 비밀번호 입력은 필수입니다.")
    public String newPassword;

    @NotBlank(message = "새 비밀번호 입력 확인은 필수입니다.")
    public String confirmNewPassword;

}

package com.iotbigdata.fishtankproject.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VerifyUserDto {

    @NotBlank(message = "아이디를 입력해주세요.")
    public String id;

    @NotBlank(message = "이름을 입력해주세요.")
    public String name;
}

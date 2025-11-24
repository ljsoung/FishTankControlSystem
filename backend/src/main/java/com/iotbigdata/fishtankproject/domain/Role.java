package com.iotbigdata.fishtankproject.domain;

import lombok.Getter;

@Getter
public enum Role {
    ADMIN("ROLE_ADMIN"),
    CUSTOMER("ROLE_CUSTOMER"),;

    Role(String value) {
        this.value = value;
    }

    private String value;
}

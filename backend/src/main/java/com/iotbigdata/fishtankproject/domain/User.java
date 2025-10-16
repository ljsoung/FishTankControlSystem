package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "user")
public class User {

    @Id
    @Column(length = 20)
    private String id;

    private String password;

    private String name;

    @Enumerated(EnumType.STRING)
    private Role role;
}
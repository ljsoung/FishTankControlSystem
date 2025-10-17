package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "user")
public class User {

    @Id
    @Column(length = 20, unique = true)
    private String id;

    private String password;

    private String name;

    @Enumerated(EnumType.STRING)
    private Role role;
}
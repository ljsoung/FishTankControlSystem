package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "user")
public class AppUser {

    @Id
    @Column(length = 20, unique = true)
    private String id;

    private String password;

    private String name;

    /*
    // fish_type 테이블 완성 후 추가
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fish_type", nullable = true)  // user 테이블에 생성될 FK 컬럼명, 최초 회원가입 시 null
    private Fish fish_type;

     */

    @Enumerated(EnumType.STRING)
    private Role role;

}
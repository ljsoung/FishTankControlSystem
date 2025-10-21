package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "dissolved_oxygen")
public class DissolvedOxygen {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long number;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")  // 현재 테이블(FK) 컬럼명
    private AppUser user;

    private Long sensor_value;

    private LocalDateTime measure_at;

}

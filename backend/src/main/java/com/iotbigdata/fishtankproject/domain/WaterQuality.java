package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.apache.catalina.User;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "water_quality")
public class WaterQuality implements SensorEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int number;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")  // 현재 테이블(FK) 컬럼명
    private AppUser user;

    private Double sensor_value;

    private LocalDateTime measureAt;

    @Override
    public Double getSensorValue() {
        return sensor_value;
    }

    @Override
    public LocalDateTime getMeasureAt() {
        return measureAt;
    }
}

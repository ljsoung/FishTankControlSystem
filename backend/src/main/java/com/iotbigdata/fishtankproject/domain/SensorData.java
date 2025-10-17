package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Getter @Setter
@Table(name = "sensor_data", indexes = {
        @Index(name = "idx_sensor_data_created_at", columnList = "created_at")
})
public class SensorData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double temperature;       // °C
    private Double tds;               // ppm
    @Column(name = "dissolved_oxygen")
    private Double dissolvedOxygen;   // mg/L

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}

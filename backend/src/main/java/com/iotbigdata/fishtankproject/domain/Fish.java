package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "fish_type")
public class Fish {

    @Id
    @Column(name = "fish_type", length = 50, nullable = false, unique = true)
    private String fishType; // PK

    @Column(name = "good_temperature")
    private Double goodTemperature;

    @Column(name = "good_tds")
    private Double goodTds;

    @Column(name = "good_dissolved_oxygen")
    private Double goodDissolvedOxygen;
}

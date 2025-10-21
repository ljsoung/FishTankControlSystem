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

    @Column(name = "min_temperature")
    private Double minTemperature;

    @Column(name = "max_temperature")
    private Double maxTemperature;

    @Column(name = "min_tds")
    private Double minTds;

    @Column(name = "max_tds")
    private Double maxTds;

    @Column(name = "min_dissolved_oxygen")
    private Double minDissolvedOxygen;

    @Column(name = "max_disolved_oxygen")
    private Double maxDissolvedOxygen;
}

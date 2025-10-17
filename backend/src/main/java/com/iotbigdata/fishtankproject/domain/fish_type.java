package com.iotbigdata.fishtankproject.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter @Setter
@Table(name = "fish_type")
public class Fish {

    @Id
    @Column(name = "fish_type", length = 50)
    private String fishType; // PK

    @Column(name = "suitable_temperature")
    private Double suitableTemperature;

    @Column(name = "suitable_tds")
    private Double suitableTds;

    @Column(name = "suitable_dissolved_oxygen")
    private Double suitableDissolvedOxygen;
}

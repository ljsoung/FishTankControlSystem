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

    // 수온
    @Column(name = "min_temperature")
    private Double minTemp;

    @Column(name = "max_temperature")
    private Double maxTemp;

    // 수질
    @Column(name = "min_tds")
    private Double minTds;

    @Column(name = "max_tds")
    private Double maxTds;

    // 용존 산소
    @Column(name = "min_dissolved_oxygen")
    private Double minDo;

    @Column(name = "max_disolved_oxygen")
    private Double maxDo;
}

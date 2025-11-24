package com.iotbigdata.fishtankproject.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SensorInputDto {
    private Double temperature;
    private Double doValue;
    private Double ph;
}

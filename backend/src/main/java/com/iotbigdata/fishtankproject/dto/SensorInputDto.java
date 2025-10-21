package com.iotbigdata.fishtankproject.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SensorInputDto {
    private String userId;
    private Long temperature;
    private Long doValue;
    private Long ph;
}

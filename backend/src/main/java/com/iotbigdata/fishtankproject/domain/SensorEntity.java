package com.iotbigdata.fishtankproject.domain;

import java.time.LocalDateTime;

public interface SensorEntity {
    Double getSensorValue();
    LocalDateTime getMeasureAt();
}

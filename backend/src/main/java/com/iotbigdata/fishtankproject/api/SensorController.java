package com.iotbigdata.fishtankproject.api;

import com.iotbigdata.fishtankproject.domain.SensorData;
import com.iotbigdata.fishtankproject.dto.SensorAverages;
import com.iotbigdata.fishtankproject.service.SensorService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sensors")
@RequiredArgsConstructor
public class SensorController {

    private final SensorService sensorService;

    @GetMapping
    public Object getSensors(@RequestParam(defaultValue = "hour") String mode) {
        return switch (mode) {
            case "hour" -> sensorService.getLastHourRaw(S);
            case "day"  -> sensorService.getDayAverages();
            case "week" -> sensorService.getWeekAverages();
            default     -> sensorService.getLastHourRaw();
        };
    }
}

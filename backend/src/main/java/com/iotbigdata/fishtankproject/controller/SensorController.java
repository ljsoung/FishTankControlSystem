package com.iotbigdata.fishtankproject.controller;

import com.iotbigdata.fishtankproject.dto.SensorInputDto;
import com.iotbigdata.fishtankproject.service.SensorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sensor")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SensorController {

    private final SensorService sensorService;

    @PostMapping("/input")
    public ResponseEntity<?> receiveSensorData(@RequestBody SensorInputDto dto,
                                               @AuthenticationPrincipal UserDetails userDetails) {
        return sensorService.saveSensorData(dto, userDetails);
    }

    @GetMapping("/main")
    public ResponseEntity<?> getMainPageSensorData(@AuthenticationPrincipal UserDetails userDetails) {
        return sensorService.getMainPageSensorData(userDetails);
    }

    @GetMapping("/data")
    public ResponseEntity<?> getSensorData(@AuthenticationPrincipal UserDetails userDetails,
                                           @RequestParam(defaultValue = "1h") String range,
                                           @RequestParam(defaultValue = "10") int count) {
        return sensorService.getSensorData(userDetails, range, count);
    }
}

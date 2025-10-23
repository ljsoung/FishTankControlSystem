package com.iotbigdata.fishtankproject.controller;

import com.iotbigdata.fishtankproject.service.SensorTokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/device")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SensorTokenController {

    private final SensorTokenService sensorTokenService;

    @PostMapping("/register")
    public ResponseEntity<?> registerSensor(@AuthenticationPrincipal UserDetails userDetails) {
        return sensorTokenService.registerSensor(userDetails);
    }
}

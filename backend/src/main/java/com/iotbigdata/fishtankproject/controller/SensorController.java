package com.iotbigdata.fishtankproject.controller;

import com.iotbigdata.fishtankproject.domain.DissolvedOxygen;
import com.iotbigdata.fishtankproject.domain.WaterQuality;
import com.iotbigdata.fishtankproject.domain.WaterTemperature;
import com.iotbigdata.fishtankproject.dto.SensorInputDto;
import com.iotbigdata.fishtankproject.repository.DissolvedOxygenRepository;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import com.iotbigdata.fishtankproject.repository.WaterQualityRepository;
import com.iotbigdata.fishtankproject.repository.WaterTemperatureRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/sensor")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SensorController {

    private final WaterTemperatureRepository tempRepo;
    private final DissolvedOxygenRepository doRepo;
    private final WaterQualityRepository phRepo;
    private final UserRepository userRepository;

    // 센서값 받을 때 이쪽으로 POST 요청
    @PostMapping("/input")
    public ResponseEntity<?> receiveSensorData(@RequestBody SensorInputDto dto) {

        var user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        // 각각의 센서 테이블에 저장
        // 수온
        WaterTemperature temp = new WaterTemperature();
        temp.setUser(user);
        temp.setSensor_value(dto.getTemperature());
        temp.setMeasure_at(LocalDateTime.now());
        tempRepo.save(temp);

        // 용존 산소
        DissolvedOxygen oxygen = new DissolvedOxygen();
        oxygen.setUser(user);
        oxygen.setSensor_value(dto.getDoValue());
        oxygen.setMeasure_at(LocalDateTime.now());
        doRepo.save(oxygen);

        // 수질
        WaterQuality ph = new WaterQuality();
        ph.setUser(user);
        ph.setSensor_value(dto.getPh());
        ph.setMeasure_at(LocalDateTime.now());
        phRepo.save(ph);

        return ResponseEntity.ok(Map.of("message", "센서 데이터 저장 완료"));
    }
}

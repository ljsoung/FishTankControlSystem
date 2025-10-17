package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.SensorData;
import com.iotbigdata.fishtankproject.dto.SensorAverages;
import com.iotbigdata.fishtankproject.repository.SensorDataRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SensorService {
    private final SensorDataRepository sensorDataRepository;

    public List<SensorData> getLastHourRaw() {
        return sensorDataRepository.findByCreatedAtAfterOrderByCreatedAtDesc(
                LocalDateTime.now().minusHours(1));
    }

    public SensorAverages getDayAverages() {
        return sensorDataRepository.getDayAverages();
    }

    public SensorAverages getWeekAverages() {
        return sensorDataRepository.getWeekAverages();
    }
}

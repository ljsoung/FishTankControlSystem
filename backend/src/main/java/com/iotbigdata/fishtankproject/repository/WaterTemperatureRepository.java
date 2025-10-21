package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.WaterTemperature;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface WaterTemperatureRepository extends JpaRepository<WaterTemperature, String> {
    Optional<WaterTemperature> findTopByUserIdOrderByMeasureAtDesc(String userId);
    List<WaterTemperature> findAllByUserAndMeasureAtBetween(AppUser user, LocalDateTime startTime, LocalDateTime endTime);
}

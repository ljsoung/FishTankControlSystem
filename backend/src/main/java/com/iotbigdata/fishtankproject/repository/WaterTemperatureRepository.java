package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.WaterTemperature;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WaterTemperatureRepository extends JpaRepository<WaterTemperature, String> {
    Optional<WaterTemperature> findTopByUserIdOrderByTimestampDesc(Long userId);
}

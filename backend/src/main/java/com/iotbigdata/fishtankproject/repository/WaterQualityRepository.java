package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.WaterQuality;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WaterQualityRepository extends JpaRepository<WaterQuality, String> {
    Optional<WaterQuality> findTopByUserIdOrderByMeasureAtDesc(String userId);
}

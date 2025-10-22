package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.WaterQuality;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface WaterQualityRepository extends JpaRepository<WaterQuality, String> {
    Optional<WaterQuality> findTopByUserIdOrderByMeasureAtDesc(String userId);
    List<WaterQuality> findAllByUserAndMeasureAtBetween(AppUser user, LocalDateTime startTime, LocalDateTime endTime);
    Optional<WaterQuality> findTopByUserOrderByMeasureAtDesc(AppUser user);
}

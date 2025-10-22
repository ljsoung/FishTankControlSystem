package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.DissolvedOxygen;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface DissolvedOxygenRepository extends JpaRepository<DissolvedOxygen, String> {
    Optional<DissolvedOxygen> findTopByUserIdOrderByMeasureAtDesc(String userId);
    List<DissolvedOxygen> findAllByUserAndMeasureAtBetween(AppUser user, LocalDateTime startTime, LocalDateTime endTime);
    Optional<DissolvedOxygen> findTopByUserOrderByMeasureAtDesc(AppUser user);
}

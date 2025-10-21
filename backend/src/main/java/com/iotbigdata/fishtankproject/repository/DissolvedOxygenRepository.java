package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.DissolvedOxygen;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DissolvedOxygenRepository extends JpaRepository<DissolvedOxygen, String> {
    Optional<DissolvedOxygen> findTopByUserIdOrderByMeasureAtDesc(String userId);
}

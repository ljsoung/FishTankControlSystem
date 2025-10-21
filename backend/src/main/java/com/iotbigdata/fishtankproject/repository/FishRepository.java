package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.Fish;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FishRepository extends JpaRepository<Fish, String> {
    Optional<Fish> findByFishType(String fishType);
}

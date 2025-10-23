package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.SensorToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface SensorTokenRepository extends JpaRepository<SensorToken, Integer> {
    Optional<SensorToken> findByToken(String token);

    boolean existsByUser_Id(String userId);
}

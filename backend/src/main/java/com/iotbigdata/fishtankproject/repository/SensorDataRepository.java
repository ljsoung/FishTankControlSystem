package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.SensorData;
import com.iotbigdata.fishtankproject.dto.SensorAverages;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;

public interface SensorDataRepository extends JpaRepository<SensorData, Long> {

    List<SensorData> findByCreatedAtAfterOrderByCreatedAtDesc(LocalDateTime after);

    @Query(value = """
        SELECT AVG(temperature) AS avgTemperature,
               AVG(tds) AS avgTds,
               AVG(dissolved_oxygen) AS avgDissolvedOxygen
        FROM sensor_data
        WHERE created_at >= NOW() - INTERVAL 1 DAY
        """, nativeQuery = true)
    SensorAverages getDayAverages();

    @Query(value = """
        SELECT AVG(temperature) AS avgTemperature,
               AVG(tds) AS avgTds,
               AVG(dissolved_oxygen) AS avgDissolvedOxygen
        FROM sensor_data
        WHERE created_at >= NOW() - INTERVAL 7 DAY
        """, nativeQuery = true)
    SensorAverages getWeekAverages();
}

package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.Fish;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FishRepository extends JpaRepository<Fish, String> {
}

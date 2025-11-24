package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.Fish;
import com.iotbigdata.fishtankproject.domain.Likability;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LikabilityRepository extends JpaRepository<Likability,Integer> {
    Optional<Likability> findByUserAndFish(AppUser user, Fish fish);
}

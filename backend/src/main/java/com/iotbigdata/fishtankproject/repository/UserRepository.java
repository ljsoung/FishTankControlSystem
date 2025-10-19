package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<AppUser, String> {
    Optional<AppUser> findById(String username);
}

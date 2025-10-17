package com.iotbigdata.fishtankproject.user.repository;

import com.iotbigdata.fishtankproject.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, String> {
    boolean existsById(String id);
}

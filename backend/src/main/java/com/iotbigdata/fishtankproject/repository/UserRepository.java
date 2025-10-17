package com.iotbigdata.fishtankproject.repository;

import com.iotbigdata.fishtankproject.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, String> {
}

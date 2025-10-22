package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.Fish;
import com.iotbigdata.fishtankproject.repository.FishRepository;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FishService {

    private final FishRepository fishRepository;
    private final UserRepository userRepository;

    public ResponseEntity<?> getFishTypeList() {

        List<String> fishTypes = fishRepository.findAll()
                .stream()
                .map(Fish::getFishType) // Fish 엔티티에서 fishType만 추출
                .toList();

        return ResponseEntity.ok(Map.of(
                "data", fishTypes
        ));
    }

    public ResponseEntity<?> setUserFishType(UserDetails userDetails, String fishType) {
        String userId = userDetails.getUsername();

        // 사용자 조회
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        // 어종 조회
        Fish fish = fishRepository.findById(fishType)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 어종입니다."));

        // 사용자에게 어종 등록
        user.setFishType(fish);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "message", "어종이 성공적으로 등록되었습니다.",
                "userId", userId,
                "fishType", fish.getFishType()
        ));
    }
}

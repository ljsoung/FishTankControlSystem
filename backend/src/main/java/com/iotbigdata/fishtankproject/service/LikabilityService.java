package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.domain.Fish;
import com.iotbigdata.fishtankproject.domain.Likability;
import com.iotbigdata.fishtankproject.repository.FishRepository;
import com.iotbigdata.fishtankproject.repository.LikabilityRepository;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LikabilityService {

    private final UserRepository userRepository;
    private final FishRepository fishRepository;
    private final LikabilityRepository likabilityRepository;

    public void updateLikability(AppUser user, double temp, double tds, double doValue) {

        // 1. 사용자 선택 어종
        Fish fish = fishRepository.findById(user.getFishType().getFishType())
                .orElseThrow(() -> new RuntimeException("Fish type not found"));

        // 2. 기존 데이터 조회 (없으면 생성)
        Likability likability = likabilityRepository.findByUserAndFish(user, fish)
                .orElseGet(() -> {
                    Likability newRecord = new Likability();
                    newRecord.setUser(user);
                    newRecord.setFish(fish);
                    newRecord.setLikability(0);
                    return likabilityRepository.save(newRecord);
                });

        // 3. 정상/비정상 체크
        int abnormal = 0;

        if (temp < fish.getMinTemp() || temp > fish.getMaxTemp()) abnormal++;
        if (tds < fish.getMinTds() || tds > fish.getMaxTds()) abnormal++;
        if (doValue < fish.getMinDo() || doValue > fish.getMaxDo()) abnormal++;

        // 4. 변화량 계산
        int change = switch (abnormal) {
            case 0 -> 10;     // 모두 정상
            case 1 -> -50;    // 하나 비정상
            case 2 -> -100;   // 둘 비정상
            case 3 -> -200;   // 셋 다 비정상
            default -> 0;
        };

        // 5. 최종 점수 업데이트
        likability.setLikability(likability.getLikability() + change);

        likabilityRepository.save(likability);
    }
}

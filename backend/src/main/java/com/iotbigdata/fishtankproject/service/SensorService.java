package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.*;
import com.iotbigdata.fishtankproject.dto.SensorInputDto;
import com.iotbigdata.fishtankproject.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoField;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SensorService {

    private final WaterTemperatureRepository tempRepo;
    private final DissolvedOxygenRepository doRepo;
    private final WaterQualityRepository phRepo;
    private final UserRepository userRepository;
    private final SensorTokenService sensorTokenService;
    private final LikabilityService likabilityService;
    private final LikabilityRepository likabilityRepository;
    private final FcmService fcmService;

    public ResponseEntity<?> saveSensorData(SensorInputDto dto, String authHeader) {

        if (authHeader == null || !authHeader.startsWith("Sensor ")) {
            return ResponseEntity.status(401).body(Map.of("error", "Device token missing"));
        }

        String token = authHeader.substring(7);
        AppUser user = sensorTokenService.getUserBySensorToken(token);

        LocalDateTime now = LocalDateTime.now();

        double tempVal = safeValue(dto.getTemperature());
        double doVal   = safeValue(dto.getDoValue());
        double phVal   = safeValue(dto.getPh());

        // 수온 저장
        WaterTemperature temp = new WaterTemperature();
        temp.setUser(user);
        temp.setSensor_value(tempVal);
        temp.setMeasureAt(now);
        tempRepo.save(temp);

        // 용존 산소 저장
        DissolvedOxygen oxygen = new DissolvedOxygen();
        oxygen.setUser(user);
        oxygen.setSensor_value(doVal);
        oxygen.setMeasureAt(now);
        doRepo.save(oxygen);

        // 수질(TDS) 저장
        WaterQuality ph = new WaterQuality();
        ph.setUser(user);
        ph.setSensor_value(phVal);
        ph.setMeasureAt(now);
        phRepo.save(ph);

        // Likability 업데이트 호출
        likabilityService.updateLikability(
                user,
                tempVal,
                phVal,
                doVal
        );

        return ResponseEntity.ok(Map.of("message", "센서 데이터 저장 + 호감도 갱신 완료"));
    }



    // 메인화면 데이터 출력
    public ResponseEntity<?> getMainPageSensorData(UserDetails userDetails) {
        String userId = userDetails.getUsername();
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        // 최신 데이터 조회
        Optional<Double> tempValue = tempRepo.findTopByUserOrderByMeasureAtDesc(user)
                .map(WaterTemperature::getSensorValue);
        Optional<Double> doValue = doRepo.findTopByUserOrderByMeasureAtDesc(user)
                .map(DissolvedOxygen::getSensorValue);
        Optional<Double> phValue = phRepo.findTopByUserOrderByMeasureAtDesc(user)
                .map(WaterQuality::getSensorValue);

        // 모든 센서값이 존재하지 않으면 → 초기 요청 상태로 간주
        if (tempValue.isEmpty() && doValue.isEmpty() && phValue.isEmpty()) {
            return ResponseEntity.ok(Map.of(
                    "status", "NO_SENSOR_DATA",
                    "message", "해당 계정의 센서 데이터가 존재하지 않습니다. 초기 데이터 요청이 필요합니다."
            ));
        }

        // ✅ 센서값 데이터는 항상 구성 (어종 없어도 보이게)
        double t = tempValue.orElse(Double.NaN);
        double d = doValue.orElse(Double.NaN);
        double p = phValue.orElse(Double.NaN);

        Map<String, Object> data = Map.of(
                "temperature", Map.of("value", t),
                "dissolvedOxygen", Map.of("value", d),
                "tds", Map.of("value", p)
        );

        // ✅ 어종이 없는 경우에도 센서값을 포함해서 응답
        Fish fish = user.getFishType();

        // 호감도
        int likedValue = 0;

        if (fish != null) {
            // 🌟 유저 + 어류 조합으로 likability 조회
            Optional<Likability> likeOpt =
                    likabilityRepository.findByUserAndFish(user, fish);

            if (likeOpt.isPresent()) {
                likedValue = likeOpt.get().getLikability();
            }
        }

        if (fish == null) {
            return ResponseEntity.ok(Map.of(
                    "status", "NO_FISH_TYPE",
                    "message", "사용자에게 등록된 어종 정보가 없습니다. 어종을 먼저 등록해주세요.",
                    "likability", likedValue,    // 🔹 추가됨
                    "data", data
            ));
        }

        // 어종이 있을 경우 범위 검사
        boolean tempAlert = (t < fish.getMinTemp() || t > fish.getMaxTemp());
        boolean doAlert = (d < fish.getMinDo() || d > fish.getMaxDo());
        boolean tdsAlert = (p < fish.getMinTds() || p > fish.getMaxTds());

        List<String> abnormalItems = new ArrayList<>();
        if (tempAlert) abnormalItems.add("temperature");
        if (doAlert) abnormalItems.add("dissolvedOxygen");
        if (tdsAlert) abnormalItems.add("tds");

        String status = abnormalItems.isEmpty() ? "OK" : "WARNING";

        return ResponseEntity.ok(Map.of(
                "status", status,
                "fishType", fish.getFishType(),
                "abnormalItems", abnormalItems,
                "likability", likedValue,
                "data", data
        ));
    }


    public ResponseEntity<?> getSensorData(UserDetails userDetails, String range, int count) {
        String userId = userDetails.getUsername();
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        LocalDateTime endTime = LocalDateTime.now();
        LocalDateTime startTime;

        switch (range) {
            case "1h" -> startTime = endTime.minusHours(count);
            case "1d" -> startTime = endTime.minusDays(count - 1);
            case "1w" -> startTime = endTime.minusWeeks(count - 1);
            default -> {
                return ResponseEntity.badRequest().body(Map.of("error", "유효하지 않은 range 값"));
            }
        }

        // DB에서 모든 데이터 가져오기
        List<WaterTemperature> tempData = tempRepo.findAllByUserAndMeasureAtBetween(user, startTime, endTime);
        List<DissolvedOxygen> doData = doRepo.findAllByUserAndMeasureAtBetween(user, startTime, endTime);
        List<WaterQuality> phData = phRepo.findAllByUserAndMeasureAtBetween(user, startTime, endTime);

        // 단위별 그룹화 및 평균 계산
        Map<String, List<Map<String, Object>>> groupedData = new HashMap<>();

        groupedData.put("temperatureData", groupSensorData(tempData, range));
        groupedData.put("doData", groupSensorData(doData, range));
        groupedData.put("phData", groupSensorData(phData, range));

        return ResponseEntity.ok(Map.of(
                "startTime", startTime,
                "endTime", endTime,
                "data", groupedData
        ));
    }

    private <T extends SensorEntity> List<Map<String, Object>> groupSensorData(List<T> data, String range) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd HH:mm");

        if (data == null || data.isEmpty()) {
            return List.of();
        }

        // ✅ null 데이터 필터링
        List<T> filtered = data.stream()
                .filter(Objects::nonNull)
                .filter(d -> d.getMeasureAt() != null)
                .filter(d -> d.getSensorValue() != null)
                .toList();

        if (range.equals("1h")) {
            // 1시간 단위: 그대로 반환
            return filtered.stream()
                    .map(d -> {
                        Map<String, Object> map = new HashMap<>();
                        map.put("time", d.getMeasureAt().format(formatter));
                        map.put("value", String.format("%.1f", d.getSensorValue()));
                        return map;
                    })
                    .toList();

        } else if (range.equals("1d")) {
            // 1일 단위: 날짜별 평균
            return filtered.stream()
                    .collect(Collectors.groupingBy(d -> d.getMeasureAt().toLocalDate()))
                    .entrySet().stream()
                    .sorted(Map.Entry.comparingByKey())
                    .map(e -> {
                        double avg = e.getValue().stream()
                                .filter(Objects::nonNull)
                                .filter(d -> d.getSensorValue() != null)
                                .mapToDouble(SensorEntity::getSensorValue)
                                .average()
                                .orElse(0.0);
                        Map<String, Object> map = new HashMap<>();
                        map.put("time", e.getKey().toString());
                        map.put("value", String.format("%.2f", avg));
                        return map;
                    })
                    .toList();

        } else if (range.equals("1w")) {
            // 1주 단위: 주차별 평균
            return filtered.stream()
                    .collect(Collectors.groupingBy(d ->
                            d.getMeasureAt().getYear() + "-W" +
                                    d.getMeasureAt().get(ChronoField.ALIGNED_WEEK_OF_YEAR)))
                    .entrySet().stream()
                    .sorted(Map.Entry.comparingByKey())
                    .map(e -> {
                        double avg = e.getValue().stream()
                                .filter(Objects::nonNull)
                                .filter(d -> d.getSensorValue() != null)
                                .mapToDouble(SensorEntity::getSensorValue)
                                .average()
                                .orElse(0.0);
                        Map<String, Object> map = new HashMap<>();
                        map.put("time", e.getKey());
                        map.put("value", String.format("%.2f", avg));
                        return map;
                    })
                    .toList();
        }

        return List.of();
    }

    public ResponseEntity<?> processFeedLevel(Map<String, Number> body, String authHeader) {

        // 1) 센서 토큰 체크
        if (authHeader == null || !authHeader.startsWith("Sensor ")) {
            return ResponseEntity.status(401).body(Map.of("error", "Device token missing"));
        }

        String token = authHeader.substring(7);
        AppUser user = sensorTokenService.getUserBySensorToken(token);

        if (user == null) {
            return ResponseEntity.status(404).body(Map.of("error", "User not found for this sensor token"));
        }

        // 2) 초음파 센서 수치 받기
        Number num = body.get("distance");
        if (num == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "distance value missing"));
        }
        double distance = num.doubleValue();

        // 3) 사료 부족 기준값
        double threshold = 25.0;  // 기준 거리(값 높아질수록 사료 부족한 상태)

        boolean isLow = distance > threshold;

        // 4) 사료 부족 시 앱에 FCM 알림
        if (isLow) {
            fcmService.sendNotification(
                    user,
                    "사료 부족 알림",
                    "사료통의 사료가 부족합니다! 지금 채워주세요."
            );
        }

        // 5) DB 저장 없음 → 로직만 처리하고 응답
        return ResponseEntity.ok(Map.of(
                "message", "사료 상태 처리 완료(저장 없음)",
                "distance", distance,
                "isLow", isLow
        ));
    }


    private double safeValue(Double value) {
        return value != null ? value : 0.0;
    }

}


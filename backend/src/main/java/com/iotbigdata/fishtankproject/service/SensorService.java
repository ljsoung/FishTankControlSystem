package com.iotbigdata.fishtankproject.service;

import com.iotbigdata.fishtankproject.domain.*;
import com.iotbigdata.fishtankproject.dto.SensorInputDto;
import com.iotbigdata.fishtankproject.repository.DissolvedOxygenRepository;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import com.iotbigdata.fishtankproject.repository.WaterQualityRepository;
import com.iotbigdata.fishtankproject.repository.WaterTemperatureRepository;
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

    public ResponseEntity<?> saveSensorData(SensorInputDto dto, String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Sensor ")) {
            return ResponseEntity.status(401).body(Map.of("error", "Device token missing"));
        }

        String token = authHeader.substring(7);
        AppUser user = sensorTokenService.getUserBySensorToken(token);
        // 각각의 센서 테이블에 저장
        // 수온
        WaterTemperature temp = new WaterTemperature();
        temp.setUser(user);
        temp.setSensor_value(dto.getTemperature());
        temp.setMeasureAt(LocalDateTime.now());
        tempRepo.save(temp);

        // 용존 산소
        DissolvedOxygen oxygen = new DissolvedOxygen();
        oxygen.setUser(user);
        oxygen.setSensor_value(dto.getDoValue());
        oxygen.setMeasureAt(LocalDateTime.now());
        doRepo.save(oxygen);

        // 수질
        WaterQuality ph = new WaterQuality();
        ph.setUser(user);
        ph.setSensor_value(dto.getPh());
        ph.setMeasureAt(LocalDateTime.now());
        phRepo.save(ph);

        return ResponseEntity.ok(Map.of("message", "센서 데이터 저장 완료"));
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
            return ResponseEntity.status(404).body(Map.of(
                    "status", "NO_SENSOR_DATA",
                    "message", "해당 계정의 센서 데이터가 존재하지 않습니다. 초기 데이터 요청이 필요합니다."
            ));
        }

        Fish fish = user.getFishType();

        // 어종 없을 시
        if (fish == null) {
            return ResponseEntity.status(400).body(Map.of(
                    "status", "NO_FISH_TYPE",
                    "message", "사용자에게 등록된 어종 정보가 없습니다. 회원정보에서 어종을 먼저 등록해주세요."
            ));
        }

        double t = tempValue.orElse(Double.NaN);
        double d = doValue.orElse(Double.NaN);
        double p = phValue.orElse(Double.NaN);

        boolean tempAlert = (t < fish.getMinTemp() || t > fish.getMaxTemp());
        boolean doAlert = (d < fish.getMinDo() || d > fish.getMaxDo());
        boolean tdsAlert = (p < fish.getMinTds() || p > fish.getMaxTds());

        List<String> abnormalItems = new ArrayList<>();
        if (tempAlert) abnormalItems.add("temperature");
        if (doAlert) abnormalItems.add("dissolvedOxygen");
        if (tdsAlert) abnormalItems.add("tds");

        // 결과 구성
        Map<String, Object> data = Map.of(
                "temperature", Map.of(
                        "value", t
                ),
                "dissolvedOxygen", Map.of(
                        "value", d
                ),
                "tds", Map.of(
                        "value", p
                )
        );

        String status = abnormalItems.isEmpty() ? "OK" : "WARNING";

        // 최종 응답
        return ResponseEntity.ok(Map.of(
                "status", status,
                "fishType", fish.getFishType(),
                "abnormalItems", abnormalItems,
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
            case "1d" -> startTime = endTime.minusDays(count);
            case "1w" -> startTime = endTime.minusWeeks(count);
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
                "range", range,
                "count", count,
                "startTime", startTime,
                "endTime", endTime,
                "data", groupedData
        ));
    }

    private <T extends SensorEntity> List<Map<String, Object>> groupSensorData(List<T> data, String range) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd HH");

        if (range.equals("1h")) {
            // 1시간 단위: 그대로 반환
            return data.stream()
                    .map(d -> {
                        Map<String, Object> map = new HashMap<>();
                        map.put("time", d.getMeasureAt().format(formatter));
                        map.put("value", d.getSensorValue());
                        return map;
                    })
                    .toList();

        } else if (range.equals("1d")) {
            // 1일 단위: 날짜별 평균
            return data.stream()
                    .collect(Collectors.groupingBy(d -> d.getMeasureAt().toLocalDate()))
                    .entrySet().stream()
                    .sorted(Map.Entry.comparingByKey())
                    .map(e -> {
                        Map<String, Object> map = new HashMap<>();
                        map.put("date", e.getKey().toString());
                        map.put("value", e.getValue().stream()
                                .mapToDouble(SensorEntity::getSensorValue)
                                .average()
                                .orElse(0));
                        return map;
                    })
                    .toList();

        } else if (range.equals("1w")) {
            // 1주 단위: 주차별 평균
            return data.stream()
                    .collect(Collectors.groupingBy(d ->
                            d.getMeasureAt().getYear() + "-W" +
                                    d.getMeasureAt().get(ChronoField.ALIGNED_WEEK_OF_YEAR)))
                    .entrySet().stream()
                    .sorted(Map.Entry.comparingByKey())
                    .map(e -> {
                        Map<String, Object> map = new HashMap<>();
                        map.put("week", e.getKey());
                        map.put("value", e.getValue().stream()
                                .mapToDouble(SensorEntity::getSensorValue)
                                .average()
                                .orElse(0));
                        return map;
                    })
                    .toList();
        }

        return List.of();
    }
}


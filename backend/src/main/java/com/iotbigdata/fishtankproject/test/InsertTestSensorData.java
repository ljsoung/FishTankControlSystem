package com.iotbigdata.fishtankproject.test;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

public class InsertTestSensorData {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/sensor?useSSL=false&serverTimezone=Asia/Seoul";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "jwejweiya"; // ← 본인 MySQL 비밀번호로 변경

    private static final String USER_ID = "prod02-1"; // 실제 user 테이블에 존재하는 ID로 변경
    private static final Random random = new Random();

    public static void main(String[] args) {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ DB 연결 성공");

            LocalDateTime start = LocalDateTime.of(2025, 10, 30, 0, 0);
            LocalDateTime end = LocalDateTime.of(2025, 10, 30, 16, 0);

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

            // ✅ 1시간 단위로 데이터 삽입
            LocalDateTime current = start;
            while (!current.isAfter(end)) {

                double temperature = 25.0 + random.nextDouble() * 2 - 1;     // 24~26°C
                double doValue = 8.0 + random.nextDouble() * 0.5 - 0.25;     // 7.75~8.25 mg/L
                double ph = 7.0 + random.nextDouble() * 0.4 - 0.2;           // 6.8~7.2

                insertData(conn, "water_temperature", USER_ID, temperature, current);
                insertData(conn, "dissolved_oxygen", USER_ID, doValue, current);
                insertData(conn, "water_quality", USER_ID, ph, current);

                current = current.plusHours(1);
            }

            System.out.println("✅ 테스트 데이터 삽입 완료");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void insertData(Connection conn, String table, String userId, double value, LocalDateTime time) throws SQLException {
        String sql = "INSERT INTO " + table + " (user_id, sensor_value, measure_at) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userId);
            pstmt.setDouble(2, Math.round(value * 10.0) / 10.0); // 소수점 1자리
            pstmt.setTimestamp(3, Timestamp.valueOf(time));
            pstmt.executeUpdate();
        }
    }
}

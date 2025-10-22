package com.iotbigdata.fishtankproject.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtTokenProvider {

    // 예시용
    private static final String SECRET_KEY = "YourSecretKeyForJwtExampleYourSecretKeyForJwtExample"; // 32자 이상
    private static final long EXPIRATION_TIME = Long.MAX_VALUE;

    private final Key key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());

    //  토큰 생성
    public String createToken(String userId, String role) {
        Date now = new Date();
        return Jwts.builder()
                .setSubject(userId) // 사용자 식별자
                .claim("role", role) // 사용자 권한
                .setIssuedAt(now) // 발급 시각
                .setExpiration(new Date(now.getTime() + EXPIRATION_TIME)) // 만료 시각
                .signWith(key, SignatureAlgorithm.HS256) // 서명
                .compact();
    }

    // 토큰 유효성 검증
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    // 토큰에서 사용자 ID 추출
    public String getUserId(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }
}

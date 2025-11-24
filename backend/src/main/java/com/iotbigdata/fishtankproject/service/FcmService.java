package com.iotbigdata.fishtankproject.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.iotbigdata.fishtankproject.domain.AppUser;
import com.iotbigdata.fishtankproject.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FcmService {

    private final UserRepository userRepository;

    public void sendNotification(AppUser user, String title, String body) {

        if (user.getFcmToken() == null) {
            System.out.println("⚠ 이 사용자에게 등록된 FCM 토큰 없음");
            return;
        }

        Message message = Message.builder()
                .setToken(user.getFcmToken())
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build()
                )
                .build();

        try {
            String response = FirebaseMessaging.getInstance().send(message);
            System.out.println("FCM 알림 전송 성공: " + response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}


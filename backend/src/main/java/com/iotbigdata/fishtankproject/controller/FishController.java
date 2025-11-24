package com.iotbigdata.fishtankproject.controller;

import com.iotbigdata.fishtankproject.service.FishService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/fish")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FishController {

    private final FishService fishService;

    @GetMapping("/list")
    public ResponseEntity<?> getFishTypeList() {
        return fishService.getFishTypeList();
    }

    @PostMapping("/select")
    public ResponseEntity<?> selectFishType(
            @RequestParam String fishType,
            @AuthenticationPrincipal UserDetails userDetails) {
        return fishService.setUserFishType(userDetails, fishType);
    }
}

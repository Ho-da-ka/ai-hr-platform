package com.company.hr.module.auth.controller;

import com.company.hr.common.dto.Result;
import com.company.hr.module.auth.dto.LoginRequest;
import com.company.hr.module.auth.dto.LoginResponse;
import com.company.hr.module.auth.entity.User;
import com.company.hr.module.auth.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return Result.ok(response);
    }

    @PostMapping("/logout")
    public Result<Void> logout(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        authService.logout(token);
        return Result.ok();
    }

    @GetMapping("/info")
    public Result<User> getCurrentUser() {
        User user = authService.getCurrentUser();
        return Result.ok(user);
    }
}

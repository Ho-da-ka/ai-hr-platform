package com.company.hr.module.auth.service;

import com.company.hr.module.auth.dto.LoginRequest;
import com.company.hr.module.auth.dto.LoginResponse;
import com.company.hr.module.auth.entity.User;

public interface AuthService {

    LoginResponse login(LoginRequest request);

    void logout(String token);

    User getCurrentUser();
}

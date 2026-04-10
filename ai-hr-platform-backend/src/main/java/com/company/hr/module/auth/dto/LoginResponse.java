package com.company.hr.module.auth.dto;

import lombok.Data;

@Data
public class LoginResponse {
    private String token;
    private String username;
    private String realName;
    private String role;

    public LoginResponse(String token, String username, String realName, String role) {
        this.token = token;
        this.username = username;
        this.realName = realName;
        this.role = role;
    }
}

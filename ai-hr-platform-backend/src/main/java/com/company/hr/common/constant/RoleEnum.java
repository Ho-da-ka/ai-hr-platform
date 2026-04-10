package com.company.hr.common.constant;

import lombok.Getter;

@Getter
public enum RoleEnum {
    HR("HR", "普通HR"),
    HR_MANAGER("HR_MANAGER", "HR主管");

    private final String code;
    private final String desc;

    RoleEnum(String code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public static RoleEnum fromCode(String code) {
        for (RoleEnum role : values()) {
            if (role.code.equals(code)) {
                return role;
            }
        }
        throw new IllegalArgumentException("Unknown role code: " + code);
    }
}

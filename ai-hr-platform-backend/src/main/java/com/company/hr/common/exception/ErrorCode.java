package com.company.hr.common.exception;

import lombok.Getter;

@Getter
public enum ErrorCode {
    SUCCESS(200, "操作成功"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未认证"),
    FORBIDDEN(403, "无权限"),
    NOT_FOUND(404, "资源不存在"),
    INTERNAL_ERROR(500, "服务器内部错误"),

    USER_NOT_FOUND(1001, "用户不存在"),
    USER_ALREADY_EXISTS(1002, "用户名已存在"),
    PASSWORD_ERROR(1003, "密码错误"),
    USER_DISABLED(1004, "用户已禁用"),

    JD_NOT_FOUND(2001, "JD不存在"),
    CANDIDATE_NOT_FOUND(2002, "候选人不存在"),
    STAGE_TRANSITION_INVALID(2003, "状态流转不合法"),
    FILE_UPLOAD_FAILED(2004, "文件上传失败"),
    RESUME_PARSE_FAILED(2005, "简历解析失败"),
    AI_CALL_FAILED(2006, "AI服务调用失败"),
    AI_TIMEOUT(2007, "AI服务超时"),

    EMPLOYEE_NOT_FOUND(3001, "员工不存在"),
    EMPLOYEE_NO_EXISTS(3002, "工号已存在"),
    SALARY_ALREADY_EXISTS(3003, "该月薪酬记录已存在");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}

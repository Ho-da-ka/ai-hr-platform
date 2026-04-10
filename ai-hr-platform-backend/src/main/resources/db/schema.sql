CREATE DATABASE IF NOT EXISTS ai_hr_platform
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE ai_hr_platform;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `real_name` VARCHAR(50) NOT NULL,
    `role` VARCHAR(20) NOT NULL DEFAULT 'HR' COMMENT 'HR, HR_MANAGER',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '0-禁用, 1-启用',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- JD 表
CREATE TABLE IF NOT EXISTS `job_description` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(100) NOT NULL,
    `department` VARCHAR(50) NOT NULL,
    `requirements` TEXT,
    `responsibilities` TEXT,
    `salary_range_min` DECIMAL(10,2),
    `salary_range_max` DECIMAL(10,2),
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '0-关闭, 1-招聘中',
    `creator_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_department` (`department`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 候选人表
CREATE TABLE IF NOT EXISTS `candidate` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    `phone` VARCHAR(20),
    `email` VARCHAR(100),
    `resume_file_path` VARCHAR(255),
    `source` VARCHAR(50) NOT NULL DEFAULT 'UPLOAD' COMMENT 'UPLOAD, BOSS, LIEPIN, REFERRAL, OTHER',
    `current_stage` VARCHAR(30) NOT NULL DEFAULT 'RESUME_SCREENING',
    `jd_id` BIGINT NOT NULL,
    `created_by` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_jd_id` (`jd_id`),
    INDEX `idx_current_stage` (`current_stage`),
    INDEX `idx_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 候选人流程记录表
CREATE TABLE IF NOT EXISTS `candidate_stage` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `candidate_id` BIGINT NOT NULL,
    `stage` VARCHAR(30) NOT NULL,
    `status` TINYINT NOT NULL DEFAULT 2 COMMENT '0-未通过, 1-通过, 2-进行中',
    `operator_id` BIGINT NOT NULL,
    `notes` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_candidate_id` (`candidate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 简历结构化数据表
CREATE TABLE IF NOT EXISTS `resume_data` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `candidate_id` BIGINT NOT NULL UNIQUE,
    `parsed_json` JSON,
    `ai_score` INT COMMENT '0-100',
    `ai_analysis` TEXT,
    `parse_status` TINYINT NOT NULL DEFAULT 0 COMMENT '0-失败, 1-成功, 2-需人工处理',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_candidate_id` (`candidate_id`),
    INDEX `idx_ai_score` (`ai_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 面试记录表
CREATE TABLE IF NOT EXISTS `interview_record` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `candidate_id` BIGINT NOT NULL,
    `stage` VARCHAR(30) NOT NULL,
    `interviewer_id` BIGINT NOT NULL,
    `feedback` TEXT,
    `rating` INT COMMENT '1-5',
    `ai_questions` JSON,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_candidate_id` (`candidate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- AI 建议记录表
CREATE TABLE IF NOT EXISTS `ai_suggestion` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `candidate_id` BIGINT NOT NULL,
    `suggestion_type` VARCHAR(30) NOT NULL COMMENT 'MATCH_SCORE, INTERVIEW_QUESTIONS, COMMUNICATION_SCRIPT, OFFER_ADVICE',
    `content` JSON NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_candidate_id` (`candidate_id`),
    INDEX `idx_suggestion_type` (`suggestion_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 员工表
CREATE TABLE IF NOT EXISTS `employee` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    `employee_no` VARCHAR(20) NOT NULL UNIQUE,
    `department` VARCHAR(50) NOT NULL,
    `position` VARCHAR(50) NOT NULL,
    `entry_date` DATE NOT NULL,
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '0-离职, 1-在职',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_department` (`department`),
    INDEX `idx_employee_no` (`employee_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 薪酬记录表
CREATE TABLE IF NOT EXISTS `salary` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `employee_id` BIGINT NOT NULL,
    `base_salary` DECIMAL(10,2) NOT NULL,
    `month` VARCHAR(7) NOT NULL COMMENT '2026-04',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '0-草稿, 1-已确认',
    `created_by` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_employee_id` (`employee_id`),
    INDEX `idx_month` (`month`),
    UNIQUE KEY `uk_employee_month` (`employee_id`, `month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 审计日志表
CREATE TABLE IF NOT EXISTS `audit_log` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `entity_type` VARCHAR(50) NOT NULL,
    `entity_id` BIGINT NOT NULL,
    `old_value` JSON,
    `new_value` JSON,
    `ip` VARCHAR(50),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_entity` (`entity_type`, `entity_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

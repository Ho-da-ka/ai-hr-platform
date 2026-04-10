USE ai_hr_platform;

-- 密码均为 123456 (BCrypt hash)
INSERT INTO `user` (`username`, `password_hash`, `real_name`, `role`, `status`) VALUES
('hr', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '张小花', 'HR', 1),
('hr_manager', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '李大明', 'HR_MANAGER', 1);

-- 示例 JD
INSERT INTO `job_description` (`title`, `department`, `requirements`, `responsibilities`, `salary_range_min`, `salary_range_max`, `status`, `creator_id`) VALUES
('高级 Java 开发工程师', '技术部', '1. 5年以上Java开发经验\n2. 精通Spring Boot、MyBatis\n3. 熟悉MySQL、Redis\n4. 有分布式系统经验优先', '1. 负责后端核心业务模块开发\n2. 参与系统架构设计\n3. 编写技术文档', 15000.00, 25000.00, 1, 2),
('前端开发工程师', '技术部', '1. 3年以上前端开发经验\n2. 精通React、TypeScript\n3. 熟悉Ant Design、Redux\n4. 有性能优化经验优先', '1. 负责前端页面开发\n2. 参与技术方案评审\n3. 配合后端联调接口', 12000.00, 20000.00, 1, 2);

-- 示例员工
INSERT INTO `employee` (`name`, `employee_no`, `department`, `position`, `entry_date`, `status`) VALUES
('王五', 'EMP001', '技术部', '高级Java工程师', '2024-03-01', 1),
('赵六', 'EMP002', '技术部', '前端工程师', '2024-06-15', 1),
('钱七', 'EMP003', '市场部', '市场专员', '2023-09-01', 1);

-- 示例薪酬
INSERT INTO `salary` (`employee_id`, `base_salary`, `month`, `status`, `created_by`) VALUES
(1, 20000.00, '2026-03', 1, 2),
(2, 15000.00, '2026-03', 1, 2),
(3, 10000.00, '2026-03', 1, 2),
(1, 20000.00, '2026-04', 0, 2),
(2, 15000.00, '2026-04', 0, 2),
(3, 10000.00, '2026-04', 0, 2);

-- 注意：上面的 BCrypt hash 是示例占位值，实际密码 hash 需要在 Task 4（认证模块）运行时通过程序生成并替换到 data.sql 中。
-- 临时 main 方法示例：System.out.println(new BCryptPasswordEncoder().encode("123456"));

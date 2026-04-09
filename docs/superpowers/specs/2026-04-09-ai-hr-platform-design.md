# AI 人事系统 MVP 设计文档

## 1. 项目概述

### 1.1 背景

公司现有人事系统在候选人筛选、薪酬核算等环节存在重复录入、人工判断不一致、业务流转分散的问题。本项目建设一个 AI 人事系统 MVP，作为内部数字化工具的候选方案。

### 1.2 业务范围

- **主攻方向**：招聘评估与候选人筛选（完整端到端闭环）
- **辅助方向**：薪酬与绩效管理（最小可用功能：员工管理 + 固定薪酬录入查看）

### 1.3 核心决策摘要

| 决策项 | 选择 | 理由 |
|--------|------|------|
| 架构模式 | 单体应用 + 内嵌 AI 服务 | 2 个月 MVP，独立开发，优先可运行 |
| 后端框架 | Java / Spring Boot 3.2.x | 企业级语言，团队技术栈匹配 |
| 前端框架 | React 18 + TypeScript | 生态成熟，组件库丰富 |
| AI 实现 | 外部 LLM API + 预留本地模型接口 | MVP 阶段优先可用性 |
| 用户角色 | 普通 HR + HR 主管 | 多层级，含审批流 |
| 候选人流程 | 标准流程（10+ 状态） | 含多轮面试、背调、审批 |
| 简历导入 | 文件上传 + 外部平台接口预留 | MVP 先做上传，不实现自动化抓取 |

---

## 2. 整体架构

### 2.1 架构图

```
┌─────────────────────────────────────┐
│   React 前端 (SPA)                   │
│   - 路由: React Router               │
│   - 状态: Redux Toolkit              │
│   - UI: Ant Design                   │
│   - HTTP: Axios                      │
└──────────────┬──────────────────────┘
               │ REST API (JSON)
┌──────────────▼──────────────────────┐
│   Spring Boot 后端                   │
│   ┌─────────────────────────────┐   │
│   │ Controller 层 (REST API)    │   │
│   └──────────┬──────────────────┘   │
│   ┌──────────▼──────────────────┐   │
│   │ Service 层 (业务逻辑)       │   │
│   │  - 招聘服务                 │   │
│   │  - AI 服务 (适配器模式)     │   │
│   │  - 薪酬服务 (简化版)        │   │
│   │  - 权限服务                 │   │
│   └──────────┬──────────────────┘   │
│   ┌──────────▼──────────────────┐   │
│   │ Repository 层 (数据访问)    │   │
│   │  - MyBatis-Plus             │   │
│   └──────────┬──────────────────┘   │
└──────────────┼──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   MySQL 8.0 + Redis 7.x             │
│   + 文件存储 (本地/MinIO)            │
│   + 外部 LLM API                     │
└──────────────────────────────────────┘
```

### 2.2 核心模块

1. **用户权限模块**：登录、角色管理（普通 HR、HR 主管）、权限控制
2. **招聘管理模块**（主）：JD 管理、候选人管理、流程状态、面试记录
3. **AI 助手模块**（主）：简历解析、匹配评分、面试问题生成、沟通话术、offer 建议
4. **薪酬管理模块**（简化）：员工信息、固定薪酬录入和查看
5. **审计日志模块**：操作记录、数据变更追踪

---

## 3. 数据模型

### 3.1 用户权限域

**User（用户表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| username | VARCHAR(50) | 用户名，唯一 |
| password_hash | VARCHAR(255) | 密码哈希 |
| real_name | VARCHAR(50) | 真实姓名 |
| role | ENUM('HR','HR_MANAGER') | 角色 |
| status | TINYINT | 状态（0-禁用，1-启用） |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

### 3.2 招聘域（核心）

**JobDescription（JD 表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| title | VARCHAR(100) | 职位名称 |
| department | VARCHAR(50) | 所属部门 |
| requirements | TEXT | 岗位要求 |
| responsibilities | TEXT | 岗位职责 |
| salary_range_min | DECIMAL(10,2) | 薪资下限 |
| salary_range_max | DECIMAL(10,2) | 薪资上限 |
| status | TINYINT | 状态（0-关闭，1-招聘中） |
| creator_id | BIGINT FK | 创建人 |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

**Candidate（候选人表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| name | VARCHAR(50) | 姓名 |
| phone | VARCHAR(20) | 手机号（加密存储） |
| email | VARCHAR(100) | 邮箱 |
| resume_file_path | VARCHAR(255) | 简历文件路径 |
| source | VARCHAR(50) | 来源（上传/Boss直聘/猎聘等） |
| current_stage | VARCHAR(30) | 当前阶段 |
| jd_id | BIGINT FK | 关联 JD |
| created_by | BIGINT FK | 创建人 |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

**CandidateStage（候选人流程记录表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| candidate_id | BIGINT FK | 候选人 |
| stage | VARCHAR(30) | 阶段枚举 |
| status | TINYINT | 状态（0-未通过，1-通过，2-进行中） |
| operator_id | BIGINT FK | 操作人 |
| notes | TEXT | 备注 |
| created_at | DATETIME | 创建时间 |

**ResumeData（简历结构化数据表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| candidate_id | BIGINT FK | 候选人 |
| parsed_json | JSON | AI 解析的结构化数据 |
| ai_score | INT | AI 匹配分数（0-100） |
| ai_analysis | TEXT | AI 匹配分析 |
| parse_status | TINYINT | 解析状态（0-失败，1-成功，2-需人工处理） |
| created_at | DATETIME | 创建时间 |

**InterviewRecord（面试记录表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| candidate_id | BIGINT FK | 候选人 |
| stage | VARCHAR(30) | 面试轮次 |
| interviewer_id | BIGINT FK | 面试官 |
| feedback | TEXT | 面试反馈 |
| rating | INT | 面试评分（1-5） |
| ai_questions | JSON | AI 生成的面试问题 |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

**AiSuggestion（AI 建议记录表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| candidate_id | BIGINT FK | 候选人 |
| suggestion_type | VARCHAR(30) | 类型（MATCH_SCORE/INTERVIEW_QUESTIONS/COMMUNICATION_SCRIPT/OFFER_ADVICE） |
| content | JSON | AI 生成内容 |
| created_at | DATETIME | 创建时间 |

### 3.3 薪酬域（简化）

**Employee（员工表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| name | VARCHAR(50) | 姓名 |
| employee_no | VARCHAR(20) | 工号，唯一 |
| department | VARCHAR(50) | 部门 |
| position | VARCHAR(50) | 职位 |
| entry_date | DATE | 入职日期 |
| status | TINYINT | 状态（0-离职，1-在职） |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

**Salary（薪酬记录表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| employee_id | BIGINT FK | 员工 |
| base_salary | DECIMAL(10,2) | 基本工资 |
| month | VARCHAR(7) | 薪酬月份（2026-04） |
| status | TINYINT | 状态（0-草稿，1-已确认） |
| created_by | BIGINT FK | 创建人 |
| created_at | DATETIME | 创建时间 |

### 3.4 审计域

**AuditLog（审计日志表）**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 主键 |
| user_id | BIGINT FK | 操作人 |
| action | VARCHAR(50) | 操作类型 |
| entity_type | VARCHAR(50) | 实体类型 |
| entity_id | BIGINT | 实体 ID |
| old_value | JSON | 变更前值 |
| new_value | JSON | 变更后值 |
| ip | VARCHAR(50) | 操作 IP |
| created_at | DATETIME | 创建时间 |

---

## 4. AI 能力设计

### 4.1 架构（适配器模式）

```
AiService (业务接口)
    │
AiProvider (抽象接口)
    ├── ClaudeAiProvider   (主，Claude API)
    └── LocalModelProvider (预留)
```

配置切换：`ai.provider=claude`，通过 Spring 配置文件指定使用哪个 Provider。

### 4.2 功能清单

#### 4.2.1 简历解析 (parseResume)

- **输入**：PDF/Word 文件
- **输出**：结构化 JSON（姓名、联系方式、教育背景、工作经历、技能、项目经验）
- **提示词策略**：明确字段定义 + JSON Schema 约束
- **兜底**：解析失败返回原文 + 错误标记（parse_status=2，需人工处理）

#### 4.2.2 候选人匹配评分 (scoreCandidate)

- **输入**：简历结构化数据 + JD 要求
- **输出**：匹配分数（0-100）+ 匹配原因 + 优劣势分析
- **评分维度**：技能匹配度、经验匹配度、教育背景、稳定性
- **校验**：分数 0-100，原因不能为空

#### 4.2.3 面试问题生成 (generateInterviewQuestions)

- **输入**：候选人简历 + JD + 面试轮次
- **输出**：5-10 个结构化问题（问题、考察点、参考答案）
- **分类**：技术问题、行为问题、场景问题
- **校验**：至少 3 个问题，每个问题有考察点

#### 4.2.4 沟通话术生成 (generateCommunicationScript)

- **输入**：场景类型（邀约面试、拒绝、offer 沟通）+ 候选人信息
- **输出**：话术模板 + 关键要点
- **校验**：话术长度 50-500 字

#### 4.2.5 Offer 建议 (generateOfferAdvice)

- **输入**：候选人信息 + 面试反馈 + 市场薪酬范围
- **输出**：薪酬建议 + 谈判策略 + 风险提示
- **校验**：薪酬建议在 JD 薪资范围内

### 4.3 质量保障

- 所有 AI 输出必须结构化（JSON）
- 超时设置：30 秒
- 错误重试：最多 2 次
- 结果缓存：Redis，24 小时
- 人工复核标记：AI 建议不自动执行，需 HR 确认
- 评估指标：解析准确率、评分一致性、问题质量人工评分

---

## 5. 招聘流程与权限控制

### 5.1 候选人标准流程（10 个状态）

```
新建候选人
    ↓
简历筛选 (RESUME_SCREENING)
    ↓ (AI 初筛 + HR 复核)
电话面试 (PHONE_INTERVIEW)
    ↓
一面 (FIRST_INTERVIEW)
    ↓
二面 (SECOND_INTERVIEW)
    ↓
终面 (FINAL_INTERVIEW)
    ↓
背调 (BACKGROUND_CHECK)
    ↓
Offer 审批 (OFFER_APPROVAL) ← HR 主管审批
    ↓
Offer 发放 (OFFER_SENT)
    ↓
入职 (ONBOARDING)

任意阶段可转 → 淘汰 (REJECTED)
```

### 5.2 状态流转规则

- 普通 HR：可操作简历筛选 → 终面的所有环节
- HR 主管：可操作所有环节 + 审批 Offer
- 每次状态变更记录到 CandidateStage 表
- 淘汰后不可恢复（恢复需要 HR 主管权限）

### 5.3 权限矩阵

| 功能 | 普通 HR | HR 主管 |
|------|---------|---------|
| 创建/编辑 JD | ✓ | ✓ |
| 导入候选人 | ✓ | ✓ |
| 查看候选人详情 | ✓ | ✓ |
| 推进流程（简历筛选 → 终面） | ✓ | ✓ |
| 淘汰候选人 | ✓ | ✓ |
| Offer 审批 | ✗ | ✓ |
| 查看薪酬数据 | ✗ | ✓ |
| 查看审计日志 | ✗ | ✓ |
| 用户管理 | ✗ | ✓ |

### 5.4 数据脱敏

- 普通 HR 查看候选人时，手机号显示为 `138****5678`
- 薪酬数据仅 HR 主管可见
- 审计日志记录所有敏感操作

---

## 6. 技术选型

### 6.1 后端

| 组件 | 选型 | 理由 |
|------|------|------|
| 框架 | Spring Boot 3.2.x | 生态成熟，快速开发 |
| 数据访问 | MyBatis-Plus + Druid | 灵活查询，SQL 可控 |
| 安全 | Spring Security + JWT | 无状态认证，前后端分离友好 |
| 校验 | Hibernate Validator | 声明式参数校验 |
| 文档 | Knife4j | Swagger UI 增强 |
| 日志 | Logback + SLF4J | 标准日志方案 |
| 工具 | Lombok, Hutool | 减少样板代码 |

### 6.2 前端

| 组件 | 选型 | 理由 |
|------|------|------|
| 框架 | React 18 + TypeScript | 类型安全，生态丰富 |
| 路由 | React Router v6 | 标准路由方案 |
| 状态管理 | Redux Toolkit + RTK Query | API 缓存自动化 |
| UI 组件 | Ant Design 5.x | 企业级 UI 库 |
| HTTP 客户端 | Axios | 拦截器、请求取消支持 |
| 表单 | React Hook Form | 高性能表单处理 |
| 构建工具 | Vite | 极快的 HMR |

### 6.3 基础设施

| 组件 | 选型 |
|------|------|
| 数据库 | MySQL 8.0 |
| 缓存 | Redis 7.x |
| 文件存储 | 本地文件系统（可切换 MinIO） |
| AI 接口 | Claude API（Anthropic SDK for Java） |

### 6.4 关键技术决策

1. **MyBatis-Plus vs JPA**：选 MyBatis-Plus。复杂查询更灵活，性能可控，SQL 可见。
2. **JWT vs Session**：选 JWT。无状态，前后端分离友好，Redis 存储黑名单支持登出。
3. **文件存储**：本地文件系统。MVP 阶段简化部署，通过接口抽象后期可切换 MinIO/OSS。
4. **AI SDK 封装**：定义 AiProvider 接口，实现 ClaudeAiProvider，配置文件切换 Provider。

---

## 7. 项目结构

### 7.1 后端

```
ai-hr-platform-backend/
├── src/main/java/com/company/hr/
│   ├── HrApplication.java
│   ├── common/
│   │   ├── config/
│   │   │   ├── SecurityConfig.java
│   │   │   ├── RedisConfig.java
│   │   │   ├── MyBatisPlusConfig.java
│   │   │   └── AiConfig.java
│   │   ├── exception/
│   │   │   ├── GlobalExceptionHandler.java
│   │   │   ├── BusinessException.java
│   │   │   └── ErrorCode.java
│   │   ├── util/
│   │   │   ├── JwtUtil.java
│   │   │   ├── FileUtil.java
│   │   │   └── EncryptUtil.java
│   │   └── constant/
│   │       ├── RoleEnum.java
│   │       ├── CandidateStageEnum.java
│   │       └── AiSuggestionTypeEnum.java
│   ├── module/
│   │   ├── auth/
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── entity/
│   │   │   └── dto/
│   │   ├── recruitment/
│   │   │   ├── controller/
│   │   │   │   ├── JobDescriptionController.java
│   │   │   │   ├── CandidateController.java
│   │   │   │   └── InterviewController.java
│   │   │   ├── service/
│   │   │   │   ├── JobDescriptionService.java
│   │   │   │   ├── CandidateService.java
│   │   │   │   └── InterviewService.java
│   │   │   ├── entity/
│   │   │   │   ├── JobDescription.java
│   │   │   │   ├── Candidate.java
│   │   │   │   ├── CandidateStage.java
│   │   │   │   ├── ResumeData.java
│   │   │   │   └── InterviewRecord.java
│   │   │   ├── mapper/
│   │   │   └── dto/
│   │   ├── ai/
│   │   │   ├── service/
│   │   │   │   ├── AiService.java
│   │   │   │   └── impl/
│   │   │   │       └── AiServiceImpl.java
│   │   │   ├── provider/
│   │   │   │   ├── AiProvider.java
│   │   │   │   ├── ClaudeAiProvider.java
│   │   │   │   └── LocalModelProvider.java
│   │   │   ├── entity/
│   │   │   │   └── AiSuggestion.java
│   │   │   ├── mapper/
│   │   │   └── dto/
│   │   │       ├── ResumeParseResult.java
│   │   │       ├── CandidateScoreResult.java
│   │   │       └── InterviewQuestionsResult.java
│   │   ├── salary/
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── entity/
│   │   │   │   ├── Employee.java
│   │   │   │   └── Salary.java
│   │   │   ├── mapper/
│   │   │   └── dto/
│   │   └── audit/
│   │       ├── service/
│   │       ├── entity/
│   │       │   └── AuditLog.java
│   │       └── mapper/
├── src/main/resources/
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-prod.yml
│   ├── mapper/
│   └── db/
│       ├── schema.sql
│       └── data.sql
└── pom.xml
```

### 7.2 前端

```
ai-hr-platform-frontend/
├── src/
│   ├── main.tsx
│   ├── App.tsx
│   ├── routes/
│   │   └── index.tsx
│   ├── layouts/
│   │   ├── MainLayout.tsx
│   │   └── AuthLayout.tsx
│   ├── pages/
│   │   ├── Login/
│   │   ├── Dashboard/
│   │   ├── Recruitment/
│   │   │   ├── JobList/
│   │   │   ├── JobDetail/
│   │   │   ├── CandidateList/
│   │   │   ├── CandidateDetail/
│   │   │   └── InterviewManage/
│   │   └── Salary/
│   │       ├── EmployeeList/
│   │       └── SalaryList/
│   ├── components/
│   │   ├── AiSuggestionCard/
│   │   ├── CandidateStageTimeline/
│   │   ├── ResumeViewer/
│   │   └── PermissionGuard/
│   ├── store/
│   │   ├── index.ts
│   │   ├── slices/
│   │   │   ├── authSlice.ts
│   │   │   └── recruitmentSlice.ts
│   │   └── api/
│   │       ├── authApi.ts
│   │       ├── recruitmentApi.ts
│   │       └── salaryApi.ts
│   ├── utils/
│   │   ├── request.ts
│   │   ├── auth.ts
│   │   └── permission.ts
│   ├── types/
│   │   ├── user.ts
│   │   ├── recruitment.ts
│   │   └── salary.ts
│   └── styles/
│       └── global.css
├── public/
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

---

## 8. 核心业务流程

### 8.1 候选人导入与 AI 初筛

```
1. HR 上传简历文件（PDF/Word）
2. 后端保存文件，创建 Candidate 记录（状态：RESUME_SCREENING）
3. 调用 AiService.parseResume() 解析简历
4. 保存结构化数据到 ResumeData 表
5. 调用 AiService.scoreCandidate() 匹配评分
6. 保存评分结果到 AiSuggestion 表
7. 前端展示候选人列表，显示 AI 评分和匹配原因
8. HR 复核后决定：通过 → 推进到电话面试 / 拒绝 → REJECTED
```

### 8.2 面试安排与 AI 辅助

```
1. HR 选择候选人，点击"安排面试"
2. 调用 AiService.generateInterviewQuestions() 生成面试问题
3. 前端展示 AI 生成的问题，HR 可编辑或补充
4. 创建 InterviewRecord 记录（包含 AI 问题）
5. 面试官填写面试反馈和评分
6. HR 根据反馈决定：通过 → 下一轮 / 拒绝 → REJECTED
```

### 8.3 Offer 审批

```
1. 候选人通过终面，HR 点击"发起 Offer"
2. 调用 AiService.generateOfferAdvice() 获取薪酬建议
3. HR 填写 Offer 信息（薪酬、入职日期等）
4. 提交审批，候选人状态变更为 OFFER_APPROVAL
5. HR 主管审批：通过 → OFFER_SENT / 拒绝 → 回退修改
6. Offer 发放后：候选人接受 → ONBOARDING / 拒绝 → REJECTED
```

### 8.4 沟通话术生成

```
1. HR 在候选人详情页点击"生成沟通话术"
2. 选择场景（邀约面试/拒绝/Offer 沟通）
3. 调用 AiService.generateCommunicationScript()
4. 前端展示话术，HR 可复制或编辑
5. 记录到 AiSuggestion 表
```

### 8.5 异常处理

- AI 调用超时：返回默认提示，记录错误日志
- 简历解析失败：保存原文件路径，标记"需人工处理"（parse_status=2）
- 文件上传失败：前端重试 3 次，失败后提示用户
- 权限不足：返回 403，前端跳转无权限页面

---

## 9. 测试策略

- **单元测试**：Service 层核心逻辑，使用 JUnit 5 + Mockito
- **集成测试**：Controller 层 API，使用 Spring Boot Test + MockMvc
- **AI 功能测试**：预置测试简历和 JD，验证输出结构化格式和校验规则
- **前端测试**：核心组件测试，使用 React Testing Library

---

## 10. 部署方案

- **开发环境**：本地 Docker Compose（MySQL + Redis + 应用）
- **演示环境**：单机部署，Nginx 反向代理前端，Java -jar 运行后端
- **初始化**：schema.sql 建表 + data.sql 填充 Demo 数据（Demo 账号 + 示例 JD + 示例候选人）

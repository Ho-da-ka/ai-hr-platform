# AI 人事系统 MVP

基于 AI 辅助的招聘管理系统，覆盖从简历解析到 Offer 发放的完整端到端闭环，并提供员工薪酬管理的最小可用能力。

## 技术栈

| 层 | 技术 |
|---|------|
| 后端 | Java 17 / Spring Boot 3.2 / MyBatis-Plus / Spring Security / JWT |
| 前端 | React 18 / TypeScript / Ant Design 5 / Redux Toolkit / Vite |
| 数据库 | MySQL 8.0 / Redis 7.x |
| AI | Claude API（Anthropic），预留本地模型切换接口 |
| 部署 | Docker Compose / Nginx |

## 核心功能

### 招聘管理（完整闭环）

- **JD 管理**：创建、编辑、发布岗位描述
- **候选人管理**：手动录入 + 简历上传（PDF/Word）
- **AI 简历解析**：结构化提取教育、经历、技能等信息
- **AI 匹配评分**：0-100 分评分 + 优劣势分析 + 推荐建议
- **AI 面试问题生成**：按轮次生成技术/行为/场景问题
- **AI 沟通话术**：邀约面试、拒绝、Offer 沟通三种场景
- **AI Offer 建议**：薪酬建议 + 谈判策略 + 风险提示
- **10 状态标准流程**：简历筛选 → 电话面试 → 一面 → 二面 → 终面 → 背调 → Offer 审批 → 发放 → 入职
- **Offer 审批**：HR 提交，HR 主管审批

### 薪酬管理（最小可用）

- 员工信息 CRUD
- 固定薪酬按月录入（草稿/已确认）
- 薪酬记录查看

### 通用能力

- 角色权限：普通 HR / HR 主管
- 数据脱敏：手机号按角色脱敏显示
- 操作审计日志
- JWT 无状态认证

## 项目结构

```
ai-hr-platform/
├── ai-hr-platform-backend/         # Spring Boot 后端
│   └── src/main/java/com/company/hr/
│       ├── common/                  # 配置、异常、工具、常量
│       └── module/
│           ├── auth/                # 认证与权限
│           ├── recruitment/         # 招聘管理（JD、候选人、面试）
│           ├── ai/                  # AI 助手（Provider 适配器模式）
│           ├── salary/              # 薪酬管理
│           └── audit/               # 审计日志
├── ai-hr-platform-frontend/        # React 前端
│   └── src/
│       ├── pages/                   # 页面组件
│       ├── store/                   # Redux Store + RTK Query
│       ├── components/              # 通用组件
│       └── utils/                   # 工具函数
├── docs/                            # 设计文档与计划
│   ├── superpowers/specs/           # 设计文档
│   ├── superpowers/plans/           # 实现计划
│   └── week1/                       # 第1周交付物
├── docker-compose.yml               # Docker 部署
├── PRD.md                           # 产品需求文档
└── README.md
```

## 快速启动

### 前置条件

- JDK 17+
- Maven 3.8+
- Node.js 18+
- MySQL 8.0
- Redis 7.x
- Docker & Docker Compose（可选，用于一键部署）

### 方式一：Docker Compose（推荐）

```bash
# 1. 构建后端
cd ai-hr-platform-backend
mvn clean package -DskipTests

# 2. 构建前端
cd ../ai-hr-platform-frontend
npm install && npm run build

# 3. 设置 AI API Key
export CLAUDE_API_KEY=your-api-key

# 4. 启动
cd ..
docker-compose up -d

# 5. 访问
# 前端: http://localhost
# 后端 API: http://localhost:8080/api
```

### 方式二：本地开发

```bash
# 1. 启动 MySQL 和 Redis
# 执行建表脚本
mysql -u root -p < ai-hr-platform-backend/src/main/resources/db/schema.sql
mysql -u root -p < ai-hr-platform-backend/src/main/resources/db/data.sql

# 2. 启动后端
cd ai-hr-platform-backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 3. 启动前端
cd ../ai-hr-platform-frontend
npm install && npm run dev
```

## Demo 账号

| 角色 | 用户名 | 密码 | 权限范围 |
|------|--------|------|----------|
| HR 主管 | hr_manager | 123456 | 全部功能（含薪酬、审计、用户管理、Offer 审批） |
| 普通 HR | hr | 123456 | 招聘管理（JD、候选人、面试，手机号脱敏） |

## AI 能力架构

```
AiService（业务层）
    │
AiProvider（抽象接口）
    ├── ClaudeAiProvider    ← 当前使用
    └── LocalModelProvider  ← 预留
```

- 所有 AI 输出结构化（JSON）
- 超时 30 秒，失败重试 2 次
- Redis 缓存 24 小时
- AI 只生成建议，不自动执行业务操作

## 文档清单

| 文档 | 说明 |
|------|------|
| [PRD.md](PRD.md) | 产品需求文档 |
| [docs/week1/requirements-clarification.md](docs/week1/requirements-clarification.md) | 需求澄清问题清单 |
| [docs/week1/business-boundary.md](docs/week1/business-boundary.md) | 业务边界判断 |
| [docs/week1/mvp-scope.md](docs/week1/mvp-scope.md) | MVP 范围定义 |
| [docs/superpowers/specs/2026-04-09-ai-hr-platform-design.md](docs/superpowers/specs/2026-04-09-ai-hr-platform-design.md) | 系统设计文档 |
| [docs/superpowers/plans/2026-04-09-ai-hr-platform.md](docs/superpowers/plans/2026-04-09-ai-hr-platform.md) | 实现计划（14 Tasks / 120 Steps） |

## 开发进度

- [x] 需求分析与 PRD
- [x] 架构设计与技术选型
- [x] 数据库设计
- [x] 实现计划
- [ ] 后端开发
- [ ] 前端开发
- [ ] AI 功能集成
- [ ] 测试与部署

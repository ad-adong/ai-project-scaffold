---
name: project-standards
description: 项目级别规范：Monorepo 结构，dev.sh 启停脚本，数据库双模式，.gitignore 配置
glob: "**/*"
alwaysApply: true
---

# 项目全局规范

## 项目结构（Monorepo）

```
ai-project-scaffold/
├── dev.sh                          # 开发环境管理（start / stop）
├── install.sh                      # 一键安装脚本（零基础用户唯一入口）
├── setup.sh                        # 环境安装（Homebrew/JDK/Node/MySQL）
├── .gitignore
├── backend/                        # Spring Boot 3.x 后端
│   ├── pom.xml                     # Maven 依赖
│   ├── mvnw                        # Maven Wrapper
│   └── src/main/
│       ├── java/com/scaffold/demo/
│       └── resources/
│           ├── application.yml       # 默认 H2 数据库
│           ├── application-mysql.yml # MySQL profile
│           ├── schema-h2.sql         # H2 建表脚本
│           └── schema-mysql.sql      # MySQL 建表脚本
├── frontend/                       # React 18 前端
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
│       ├── main.tsx                # 入口（引入 reset.css）
│       ├── styles/reset.css        # 全局样式重置
│       ├── router/index.tsx        # 路由配置
│       └── pages/                  # 页面组件 + CSS Module
└── .qoder/
    ├── rules/                      # 编码规范
    └── skills/                     # Agent 技能
```

## 零基础用户使用方式

项目上传 GitHub 后，零基础用户只需在终端粘贴一条命令：

```bash
curl -fsSL https://raw.githubusercontent.com/用户名/仓库名/main/install.sh | bash
```

**这条命令自动完成：**
1. 下载项目到 `~/ai-project-scaffold`
2. 安装 Homebrew → JDK 17 → Node.js 18
3. 编译启动后端 Spring Boot
4. 安装前端依赖 + 启动 Vite
5. 自动打开浏览器到欢迎页

**以后重复使用：**
```bash
cd ~/ai-project-scaffold
./dev.sh start    # 启动
./dev.sh stop     # 停止
```

**上传 GitHub 前需修改 `install.sh` 顶部配置：**
```bash
GITHUB_REPO="YOUR_USERNAME/ai-project-scaffold"   # 替换为实际仓库
```

## 开发环境管理（dev.sh）

- 统一使用 `./dev.sh start` / `./dev.sh stop` 管理服务
- 启动顺序：清理端口 → 数据库 → 后端 → 等待后端就绪 → 前端
- 停止顺序：前端 → 后端 → 数据库
- 数据库模式通过脚本顶部 `DB_MODE` 变量切换：`h2`（默认）或 `mysql`
- 任何情况下不得绕过 dev.sh 直接启动前后端（除非开发调试）

## 数据库双模式

| 模式 | 设置 | 说明 |
|------|------|------|
| H2（默认） | `DB_MODE="h2"` | 内存数据库，无需安装，重启数据丢失 |
| MySQL | `DB_MODE="mysql"` | 本地 MySQL，数据持久化 |

**新增数据表时，必须同时更新 `schema-h2.sql` 和 `schema-mysql.sql` 两份建表脚本。**

## Git 管理

- `.gitignore` 已完整配置，覆盖前端 / 后端 / IDE / OS / 日志 / 敏感配置
- Maven Wrapper jar 和前端 node_modules 均被忽略
- 敏感文件（.env、application-local.yml 等）被忽略

## 技术栈总览

| 层级 | 技术 | 版本 |
|------|------|------|
| 后端框架 | Spring Boot | 3.4.x |
| ORM | MyBatis-Plus | 3.5.x |
| 数据库（默认） | H2 | runtime |
| 数据库（可选） | MySQL | 8.x |
| 构建工具 | Maven Wrapper | 3.9.x |
| 前端框架 | React | 18.x |
| UI 组件库 | Ant Design | 5.x |
| 构建工具 | Vite | 6.x |
| 路由 | React Router | 6.x |
| 语言 | TypeScript | 5.x |
| JDK | Java | 17+ |
| Node.js | Node | 18+ |

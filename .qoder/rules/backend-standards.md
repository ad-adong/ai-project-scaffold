---
name: backend-coding-standards
description: Spring Boot 后端编码规范：H2/MySQL 双数据库支持，MyBatis-Plus ORM，Maven Wrapper 构建，CORS 配置
glob: backend/**
alwaysApply: true
---

# 后端编码规范

## 数据库

### 双数据库支持（通过 Spring Profiles）

项目默认使用 **H2 内存数据库**，可通过 profile 切换到 MySQL。

**配置结构：**
- `application.yml`：默认 H2 配置（内存库，开箱即用）
- `application-mysql.yml`：MySQL profile（覆盖 datasource 和 sql.init）
- `schema-h2.sql`：H2 兼容的建表脚本
- `schema-mysql.sql`：MySQL 兼容的建表脚本

**切换方式：** 设置 `SPRING_PROFILES_ACTIVE=mysql`（或 `dev.sh` 中 `DB_MODE="mysql"`）

### 建表脚本规范

两份 schema 文件需保持表结构一致，语法差异如下：

| 特性 | H2 (`schema-h2.sql`) | MySQL (`schema-mysql.sql`) |
|------|---------------------|---------------------------|
| 插入幂等 | `MERGE INTO ... KEY(...) VALUES(...)` | `INSERT ... ON DUPLICATE KEY UPDATE` |
| 表注释 | 不支持 `COMMENT` | `COMMENT='xxx'` |
| 引擎 | 无需指定 | `ENGINE=InnoDB` |
| 字符集 | 无需指定 | `CHARSET=utf8mb4` |

## ORM

- 必须使用 **MyBatis-Plus 3.5.x**（非 JPA）
- Mapper 接口继承 `BaseMapper<T>`
- Service 继承 `IService<T>` + `ServiceImpl<M, T>`
- 使用 Lombok 简化代码（`@Data`、`@NoArgsConstructor` 等）

## API 规范

- 所有 API 路径以 `/api` 开头
- Controller 加 `@RestController` + `@RequestMapping("/api")`
- 跨域由 `CorsConfig.java` 统一处理，不要在 Controller 中单独加 `@CrossOrigin`

## 构建规范

- 使用 **Maven Wrapper**（`./mvnw`），不依赖全局 Maven
- JDK 版本：17+
- Spring Boot 版本：3.4.x

## 项目结构

```
backend/src/main/java/com/scaffold/demo/
├── DemoApplication.java          # 启动类
├── config/                        # 配置类（CORS、MyBatis-Plus 等）
├── controller/                    # 控制器
├── service/                       # 服务层
│   └── impl/                      # 服务实现
├── mapper/                        # MyBatis-Plus Mapper
└── entity/                        # 实体类
```

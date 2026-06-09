---
name: dev-project
description: 管理项目开发环境。当用户说"启动项目"、"运行项目"、"跑起来"、"start"时执行 dev.sh start；当用户说"停止"、"停掉"、"关闭"、"stop"时执行 dev.sh stop。
---

# 开发环境管理

## 触发条件

### 启动意图 → `./dev.sh start`
- "启动项目" / "运行项目" / "把项目跑起来"
- "启动一下" / "跑一下" / "运行一下"
- "start" / "run the project"

### 停止意图 → `./dev.sh stop`
- "停止项目" / "停掉服务" / "关掉" / "关闭项目"
- "stop" / "shutdown"
- 任何意图停止开发环境的表达

## 执行步骤

1. 确认当前在项目根目录

### 启动

```bash
./dev.sh start
```

告知用户：前端 http://localhost:3000 | 后端 http://localhost:8080 | 停止用 `./dev.sh stop`

### 停止

```bash
./dev.sh stop
```

告知用户：所有服务（前端 → 后端 → MySQL）已停止。

## 启动流程

`./dev.sh start` **严格按顺序**执行，前一步失败则整体退出：

| 步骤 | 内容 | 说明 |
|------|------|------|
| `[0/5]` | 清理残留端口 | 杀掉 8080、3000 上的旧进程 |
| `[1/5]` | 检测 Java / Node.js | 不满足直接退出 |
| `[2/5]` | 数据库 | H2 模式直接跳过；MySQL 模式启动 mysqld |
| `[3/5]` | 前端依赖 | 首次自动 `npm install` |
| `[4/5]` | **启动后端 + 等待就绪** | 轮询 `/api/hello`，最多等 4 分钟，后端不起来不继续 |
| `[5/5]` | **后端就绪后**启动前端 | Vite dev server 最后启动 |

## 停止流程

`./dev.sh stop` 按顺序执行：
1. 停止前端 (kill 3000 端口)
2. 停止后端 (kill 8080 端口)
3. 停止 MySQL (brew services stop / mysql.server stop)

## 注意事项

- 首次启动时 Maven 会自动下载依赖，后端可能较慢（1-3 分钟）
- 需预装 JDK 17+、Node.js 18+、MySQL
- **环境缺失时**：引导用户执行 `./setup.sh install` 一键安装环境，安装后再重新启动

### 如 `./dev.sh start` 因环境缺失失败

**不要尝试手动安装**，直接告诉用户：

> 检测到环境缺失，请先运行 `./setup.sh install` 一键安装，安装后重试启动。

### 零基础用户首次使用

如果用户还没有下载项目、没有任何开发环境，引导使用一键安装：

> 打开终端，粘贴运行这条命令，等待几分钟即可：
> 
> ```bash
> curl -fsSL https://raw.githubusercontent.com/用户名/仓库名/main/install.sh | bash
> ```
> 
> 这条命令会自动完成下载、环境安装、项目启动全部流程。

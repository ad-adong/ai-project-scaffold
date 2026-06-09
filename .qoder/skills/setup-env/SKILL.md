---
name: setup-env
description: 安装项目开发所需的前置环境（Homebrew、JDK 17+、Node.js 18+、MySQL）。当用户说"安装环境"、"配置环境"、"装一下依赖"、"setup environment"时触发。
---

# 环境安装

## 触发条件

- "安装环境" / "配置环境" / "装环境" / "搭建环境"
- "装一下依赖" / "安装前置环境" / "安装开发环境"
- "setup" / "install environment" / "env setup"

## 执行步骤

```bash
./setup.sh install
```

告知用户：安装完成后需执行 `source ~/.zshrc` 刷新环境变量，然后 `./dev.sh start` 启动项目。

## 安装内容

`./setup.sh install` 按顺序安装：

| 步骤 | 内容 | 说明 |
|------|------|------|
| 检测 | 检查所有环境 | 列出已安装 / 缺失项 |
| [1/4] | Homebrew | macOS 包管理器（如未安装） |
| [2/4] | JDK 17+ | OpenJDK 17，配置 JAVA_HOME |
| [3/4] | Node.js 18+ | 含 npm，配置 PATH |
| [4/4] | MySQL | 关系型数据库（可选，仅 H2 模式不需要） |

### 已有环境跳过
如果某个组件已安装且版本满足要求，自动跳过。

## 注意事项

- macOS 专用（依赖 Homebrew）
- 安装 JDK 需 sudo 权限（创建符号链接到 /Library/Java）
- 安装完成后 **必须执行** `source ~/.zshrc` 刷新环境变量
- MySQL 为可选安装，H2 模式不需要

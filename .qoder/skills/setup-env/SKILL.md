---
name: setup-env
description: 安装项目开发所需的前置环境。当用户说"安装环境"、"配置环境"、"装一下依赖"、"setup environment"时触发。macOS 使用 setup.sh + Homebrew，Windows 使用 setup.bat + winget。
---

# 环境安装

## 触发条件

- "安装环境" / "配置环境" / "装环境" / "搭建环境"
- "装一下依赖" / "安装前置环境" / "安装开发环境"
- "setup" / "install environment" / "env setup"

## 执行步骤

### 1. 判断操作系统

- **macOS**：执行 `./setup.sh install`
- **Windows**：执行 `setup.bat`

### 2. 执行安装

**macOS：**
```bash
./setup.sh install
```
安装完成后需执行 `source ~/.zshrc` 刷新环境变量，然后 `./dev.sh start` 启动项目。

**Windows：**
```bat
setup.bat
```
安装完成后需重新打开命令行窗口，然后 `dev.bat start` 启动项目。

## 安装内容

| 步骤 | macOS | Windows |
|------|-------|---------|
| 包管理器 | Homebrew | winget（Win10/11 自带） |
| JDK 17+ | `brew install openjdk@17` | `winget install EclipseAdoptium.Temurin.17.JDK` |
| Node.js 18+ | `brew install node@22` | `winget install OpenJS.NodeJS.LTS` |
| MySQL | `brew install mysql`（可选） | `winget install Oracle.MySQL`（可选） |

### 已有环境跳过
如果某个组件已安装且版本满足要求，自动跳过。

## 注意事项

- macOS 依赖 Homebrew，安装 JDK 需 sudo 权限
- Windows 依赖 winget（Win10 1809+ 自带），JDK/Node 通过 winget 静默安装
- MySQL 为可选安装，H2 模式不需要
- 安装完成后 macOS 需 `source ~/.zshrc`，Windows 需重新打开命令行窗口

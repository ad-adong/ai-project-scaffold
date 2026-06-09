#!/bin/bash
# ============================================
# AI 项目脚手架 - 环境安装脚本
#
# 自动检测并安装项目所需的所有前置环境：
#   Homebrew → JDK 17+ → Node.js 18+ → MySQL
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OS="$(uname -s)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  🔧 AI 项目脚手架 - 环境安装${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

MISSING_ANY=false

# ===========================================
# Homebrew
# ===========================================
check_brew() {
    if command -v brew &> /dev/null; then
        echo -e "  ✅ Homebrew: ${GREEN}$(brew --version | head -n 1)${NC}"
        return 0
    fi
    echo -e "  ${YELLOW}⚠️  Homebrew 未安装${NC}"
    MISSING_ANY=true
    return 1
}

install_brew() {
    echo -e "${YELLOW}[1/4] 安装 Homebrew...${NC}"
    if [ "$OS" = "Darwin" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon 需要额外路径
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo -e "  ${RED}❌ 非 macOS 系统，请手动安装 Homebrew${NC}"
        return 1
    fi
    echo -e "  ${GREEN}✅ Homebrew 安装完成${NC}"
}

# ===========================================
# JDK
# ===========================================
check_jdk() {
    if command -v java &> /dev/null; then
        local ver=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | cut -d'.' -f1)
        if [ "$ver" -ge 17 ] 2>/dev/null; then
            echo -e "  ✅ Java: ${GREEN}$(java -version 2>&1 | head -n 1)${NC}"
            return 0
        fi
    fi
    echo -e "  ${YELLOW}⚠️  JDK 17+ 未安装${NC}"
    MISSING_ANY=true
    return 1
}

install_jdk() {
    echo -e "${YELLOW}[2/4] 安装 JDK 17...${NC}"
    if command -v brew &> /dev/null; then
        brew install openjdk@17
        # 创建符号链接
        local jdk_path="$(brew --prefix openjdk@17)/libexec/openjdk.jdk"
        if [ -d "$jdk_path" ]; then
            sudo ln -sfn "$jdk_path" /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
        fi
        echo 'export PATH="$(brew --prefix openjdk@17)/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
        export PATH="$(brew --prefix openjdk@17)/bin:$PATH"
        echo -e "  ${GREEN}✅ JDK 17 安装完成 (brew)${NC}"
    else
        echo -e "  ${RED}❌ 请手动安装 JDK 17+: https://adoptium.net/${NC}"
        return 1
    fi
}

# ===========================================
# Node.js
# ===========================================
check_node() {
    if command -v node &> /dev/null; then
        local ver=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$ver" -ge 18 ] 2>/dev/null; then
            echo -e "  ✅ Node.js: ${GREEN}$(node -v)${NC}"
            echo -e "  ✅ npm: ${GREEN}v$(npm -v)${NC}"
            return 0
        fi
    fi
    echo -e "  ${YELLOW}⚠️  Node.js 18+ 未安装${NC}"
    MISSING_ANY=true
    return 1
}

install_node() {
    echo -e "${YELLOW}[3/4] 安装 Node.js 18...${NC}"
    if command -v brew &> /dev/null; then
        brew install node@18
        echo 'export PATH="$(brew --prefix node@18)/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
        export PATH="$(brew --prefix node@18)/bin:$PATH"
        echo -e "  ${GREEN}✅ Node.js 安装完成 (brew)${NC}"
    elif command -v nvm &> /dev/null; then
        nvm install 18
        nvm use 18
        echo -e "  ${GREEN}✅ Node.js 安装完成 (nvm)${NC}"
    else
        echo -e "  ${RED}❌ 请手动安装 Node.js 18+: https://nodejs.org/${NC}"
        return 1
    fi
}

# ===========================================
# MySQL
# ===========================================
check_mysql() {
    if command -v mysql &> /dev/null || [ -f "/usr/local/mysql/bin/mysql" ]; then
        echo -e "  ✅ MySQL: ${GREEN}$(mysql --version 2>/dev/null | head -n 1 || echo '已安装')${NC}"
        return 0
    fi
    echo -e "  ${YELLOW}⚠️  MySQL 未安装（可选，H2 模式不需要）${NC}"
    return 1
}

install_mysql() {
    echo -e "${YELLOW}[4/4] 安装 MySQL...${NC}"
    if command -v brew &> /dev/null; then
        brew install mysql
        brew services start mysql
        echo -e "  ${GREEN}✅ MySQL 安装完成 (brew)${NC}"
    else
        echo -e "  ${YELLOW}⚠️  请手动安装 MySQL: https://dev.mysql.com/downloads/mysql/${NC}"
        return 1
    fi
}

# ===========================================
# 汇总检查
# ===========================================
check_all() {
    echo -e "${BLUE}检查环境状态...${NC}"
    echo ""

    local brew_ok=false jdk_ok=false node_ok=false mysql_ok=false

    check_brew && brew_ok=true
    check_jdk && jdk_ok=true
    check_node && node_ok=true
    check_mysql && mysql_ok=true
    echo ""
}

# ===========================================
# 交互式安装
# ===========================================
install_all() {
    check_all

    if [ "$MISSING_ANY" = false ]; then
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}  ✅ 所有环境已就绪，无需安装${NC}"
        echo -e "${GREEN}========================================${NC}"
        return 0
    fi

    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  以下组件需要安装：${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""

    if ! command -v brew &> /dev/null; then
        echo -e "  - Homebrew（macOS 包管理器）"
    fi
    if ! command -v java &> /dev/null || [ "$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | cut -d'.' -f1)" -lt 17 ] 2>/dev/null; then
        echo -e "  - JDK 17+"
    fi
    if ! command -v node &> /dev/null || [ "$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" -lt 18 ] 2>/dev/null; then
        echo -e "  - Node.js 18+"
    fi
    if ! command -v mysql &> /dev/null && [ ! -f "/usr/local/mysql/bin/mysql" ]; then
        echo -e "  - MySQL（可选，H2 模式不需要）"
    fi
    echo ""

    # 自动安装（非交互）
    if ! command -v brew &> /dev/null; then
        install_brew
        echo ""
    fi

    if ! command -v brew &> /dev/null; then
        echo -e "${RED}❌ Homebrew 安装失败，无法继续${NC}"
        exit 1
    fi

    if ! command -v java &> /dev/null || [ "$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | cut -d'.' -f1)" -lt 17 ] 2>/dev/null; then
        install_jdk
        echo ""
    fi

    if ! command -v node &> /dev/null || [ "$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" -lt 18 ] 2>/dev/null; then
        install_node
        echo ""
    fi

    if ! command -v mysql &> /dev/null && [ ! -f "/usr/local/mysql/bin/mysql" ]; then
        install_mysql
        echo ""
    fi

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  🎉 环境安装完成！${NC}"
    echo -e "${GREEN}  请执行: source ~/.zshrc  （刷新环境变量）${NC}"
    echo -e "${GREEN}  然后: ./dev.sh start     （启动项目）${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# ===========================================
# 入口
# ===========================================
case "${1:-}" in
    install)
        install_all
        ;;
    check)
        check_all
        ;;
    *)
        echo -e "${BLUE}AI 项目脚手架 - 环境管理${NC}"
        echo ""
        echo "用法:  ./setup.sh <命令>"
        echo ""
        echo "命令:"
        echo "  install   检测并安装缺失的环境"
        echo "  check     仅检测环境状态"
        echo ""
        echo "前置环境列表:"
        echo "  Homebrew    macOS 包管理器"
        echo "  JDK 17+     Java 开发工具包"
        echo "  Node.js 18+ JavaScript 运行时"
        echo "  MySQL       关系型数据库（可选）"
        ;;
esac

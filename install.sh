#!/bin/bash
# ============================================
# AI 项目脚手架 - 一键安装脚本
#
# 零基础用户唯一入口（无需 git，无需任何开发环境）
#
# 用法：
#   curl -fsSL https://你的CDN域名/install.sh | bash
#   或手动下载后：sh install.sh
#
# 流程：下载项目 ZIP → 安装环境 → 启动服务
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ===================== 配置（上传 CDN 前修改）=====================
# GitHub 仓库地址（ZIP 下载源，也支持 CDN）
GITHUB_REPO="ad-adong/ai-project-scaffold"
GITHUB_BRANCH="main"
# CDN 基础地址（可选，保留 GitHub 默认即可）
CDN_BASE="https://github.com/${GITHUB_REPO}/archive/refs/heads"
PROJECT_ZIP="${GITHUB_BRANCH}.zip"
# 安装到的目标目录
PROJECT_DIR="$HOME/ai-project-scaffold"
# =================================================================

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🚀 AI 项目脚手架 - 一键安装        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# ============================================
# 1. 下载项目（纯 curl + unzip，不依赖 git）
# ============================================
download_project() {
    echo -e "${BLUE}━━━  1/4 下载项目  ━━━${NC}"
    echo ""

    # 如果已在项目目录内，跳过下载
    if [ -f "./dev.sh" ] && [ -f "./setup.sh" ]; then
        echo -e "  ${GREEN}✅ 已在项目目录中，跳过下载${NC}"
        echo ""
        return
    fi

    # 如果目录已存在，询问覆盖
    if [ -d "$PROJECT_DIR" ] && [ -f "$PROJECT_DIR/dev.sh" ]; then
        echo -e "  ${YELLOW}项目目录已存在: ${PROJECT_DIR}${NC}"
        echo -e "  ${YELLOW}跳过下载，直接使用已有项目${NC}"
        cd "$PROJECT_DIR"
        echo ""
        return
    fi

    local zip_url="${CDN_BASE}/${PROJECT_ZIP}"
    local tmp_zip="/tmp/ai-scaffold-dl-$$.zip"
    local tmp_extract="/tmp/ai-scaffold-extract-$$"

    echo -e "  从 CDN 下载项目..."
    echo -e "  ${YELLOW}  ${zip_url}${NC}"
    echo ""

    if ! curl -fsSL --progress-bar -o "$tmp_zip" "$zip_url"; then
        echo ""
        echo -e "  ${RED}❌ 下载失败，请检查 CDN 地址是否正确${NC}"
        echo -e "  ${RED}   ${zip_url}${NC}"
        rm -f "$tmp_zip"
        exit 1
    fi
    echo ""

    # 解压
    echo -e "  正在解压..."
    mkdir -p "$tmp_extract"
    unzip -qo "$tmp_zip" -d "$tmp_extract"

    # 处理可能的目录嵌套（ZIP 内可能是文件夹/直接是文件）
    if [ -f "$tmp_extract/dev.sh" ]; then
        mkdir -p "$PROJECT_DIR"
        cp -R "$tmp_extract"/* "$PROJECT_DIR/" 2>/dev/null || true
    else
        # 找第一层子目录
        local inner_dir=$(ls -d "$tmp_extract"/*/ 2>/dev/null | head -n 1)
        if [ -d "$inner_dir" ] && [ -f "$inner_dir/dev.sh" ]; then
            mkdir -p "$PROJECT_DIR"
            cp -R "$inner_dir"/* "$PROJECT_DIR/" 2>/dev/null || true
        else
            mkdir -p "$PROJECT_DIR"
            cp -R "$tmp_extract"/* "$PROJECT_DIR/" 2>/dev/null || true
        fi
    fi

    rm -rf "$tmp_zip" "$tmp_extract"

    cd "$PROJECT_DIR"
    chmod +x dev.sh setup.sh install.sh 2>/dev/null || true

    echo -e "  ${GREEN}✅ 项目下载完成 → ${PROJECT_DIR}${NC}"
    echo ""
}

# ============================================
# 2. 安装环境（Homebrew → JDK 17 → Node.js 18）
# ============================================
install_env() {
    echo -e "${BLUE}━━━  2/4 安装开发环境  ━━━${NC}"
    echo ""

    # --- Homebrew ---
    if ! command -v brew &> /dev/null; then
        echo -e "  ${YELLOW}安装 Homebrew（macOS 包管理器）...${NC}"
        echo -e "  ${YELLOW}（出现提示时输入开机密码）${NC}"
        echo ""
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
        # Apple Silicon
        [ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
        # Intel
        [ -f "/usr/local/bin/brew" ] && eval "$(/usr/local/bin/brew shellenv)"
        echo ""
        echo -e "  ${GREEN}✅ Homebrew 安装完成${NC}"
    else
        echo -e "  ${GREEN}✅ Homebrew 已安装${NC}"
    fi

    # --- JDK 17 ---
    if command -v java &> /dev/null; then
        local java_ver=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | cut -d'.' -f1)
    else
        local java_ver=0
    fi
    if [ "$java_ver" -ge 17 ] 2>/dev/null; then
        echo -e "  ${GREEN}✅ Java $(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}') 已安装${NC}"
    else
        echo -e "  ${YELLOW}安装 JDK 17（可能需要几分钟）...${NC}"
        brew install openjdk@17 2>/dev/null || {
            echo -e "  ${RED}❌ JDK 安装失败，请检查网络${NC}"
            exit 1
        }
        local jdk_home="$(brew --prefix openjdk@17 2>/dev/null)"
        local jdk_path="${jdk_home}/libexec/openjdk.jdk"
        [ -d "$jdk_path" ] && sudo ln -sfn "$jdk_path" /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
        echo 'export PATH="$(brew --prefix openjdk@17)/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
        export PATH="${jdk_home}/bin:$PATH"
        echo -e "  ${GREEN}✅ JDK 17 安装完成${NC}"
    fi

    # --- Node.js 18 ---
    if command -v node &> /dev/null; then
        local node_ver=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    else
        local node_ver=0
    fi
    if [ "$node_ver" -ge 18 ] 2>/dev/null; then
        echo -e "  ${GREEN}✅ Node.js $(node -v) 已安装${NC}"
        echo -e "  ${GREEN}✅ npm $(npm -v)${NC}"
    else
        echo -e "  ${YELLOW}安装 Node.js 18（可能需要几分钟）...${NC}"
        brew install node@18 2>/dev/null || brew install node 2>/dev/null || {
            echo -e "  ${RED}❌ Node.js 安装失败，请检查网络${NC}"
            exit 1
        }
        local node_home="$(brew --prefix node@18 2>/dev/null || brew --prefix node 2>/dev/null)"
        [ -n "$node_home" ] && echo "export PATH=\"${node_home}/bin:\$PATH\"" >> ~/.zshrc 2>/dev/null || true
        [ -n "$node_home" ] && export PATH="${node_home}/bin:$PATH"
        echo -e "  ${GREEN}✅ Node.js 安装完成${NC}"
    fi

    echo ""
}

# ============================================
# 3. 启动项目
# ============================================
start_project() {
    echo -e "${BLUE}━━━  3/4 启动项目  ━━━${NC}"
    echo ""

    # 清理残留端口
    lsof -ti :8080 2>/dev/null | xargs kill 2>/dev/null || true
    lsof -ti :3000 2>/dev/null | xargs kill 2>/dev/null || true
    sleep 1

    # 后端
    echo -e "  启动后端（首次需下载 Maven 依赖，可能较慢）..."
    cd backend
    chmod +x mvnw 2>/dev/null || true
    ./mvnw spring-boot:run -q &
    BACKEND_PID=$!
    cd "$PROJECT_DIR" 2>/dev/null || cd - > /dev/null

    echo -n "  等待后端就绪"
    local ready=false
    for i in $(seq 1 120); do
        if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
            echo ""
            echo -e "  ${YELLOW}Maven 依赖下载中，请稍候...${NC}"
            cd backend && ./mvnw spring-boot:run -q &
            BACKEND_PID=$!
            cd "$PROJECT_DIR" 2>/dev/null || cd - > /dev/null
            sleep 15
            continue
        fi
        if curl -s http://localhost:8080/api/hello > /dev/null 2>&1; then
            echo ""
            echo -e "  ${GREEN}✅ 后端就绪 (8080)${NC}"
            ready=true
            break
        fi
        echo -n "."
        sleep 2
    done
    echo ""

    if [ "$ready" = false ]; then
        echo -e "  ${RED}❌ 后端启动超时，请关闭终端重试${NC}"
        kill "$BACKEND_PID" 2>/dev/null
        exit 1
    fi

    # 前端
    echo -e "  启动前端..."
    cd frontend
    if [ ! -d "node_modules" ]; then
        echo -e "  ${YELLOW}安装前端依赖...${NC}"
        npm install --silent 2>/dev/null
    fi
    npm run dev &
    FRONTEND_PID=$!
    cd "$PROJECT_DIR" 2>/dev/null || cd - > /dev/null
    sleep 3
    echo ""

    # 打开浏览器
    echo -e "${BLUE}━━━  4/4 打开浏览器  ━━━${NC}"
    echo ""
    open http://localhost:3000 2>/dev/null || true

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ 全部启动完成！                   ║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║  前端: http://localhost:3000           ${NC}"
    echo -e "${GREEN}║  后端: http://localhost:8080           ${NC}"
    echo -e "${GREEN}║                                         ${NC}"
    echo -e "${GREEN}║  下次使用:                             ${NC}"
    echo -e "${GREEN}║    cd ~/ai-project-scaffold            ${NC}"
    echo -e "${GREEN}║    ./dev.sh start                      ${NC}"
    echo -e "${GREEN}║    ./dev.sh stop                       ${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    wait
}

# ============================================
main() {
    download_project
    install_env
    start_project
}

main

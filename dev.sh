#!/bin/bash
# ============================================
# AI 项目脚手架 - 开发环境管理脚本
#
# 用法:
#   ./dev.sh start   启动所有服务
#   ./dev.sh stop    停止所有服务
#
# 配置:
#   DB_MODE="h2"     使用 H2 内存数据库（默认，无需安装）
#   DB_MODE="mysql"  使用本地 MySQL
# ============================================

set -e

# ==================== 配置区 ====================
# 数据库模式: h2（默认） | mysql
DB_MODE="h2"
# =================================================

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

BACKEND_PID=""
FRONTEND_PID=""
MYSQL_NEEDED=false

# ===========================================
# 工具函数
# ===========================================

# 启动 MySQL
start_mysql() {
    if ! command -v mysql &> /dev/null && [ ! -f "/usr/local/mysql/bin/mysql" ]; then
        echo -e "  ${YELLOW}⚠️  未检测到 MySQL，跳过${NC}"
        return 1
    fi

    if mysqladmin ping -u root --silent 2>/dev/null; then
        echo -e "  ${GREEN}✅ MySQL 已在运行中${NC}"
        return 0
    fi

    echo -n "  正在启动 MySQL..."
    if command -v brew &> /dev/null && brew services list 2>/dev/null | grep -q mysql; then
        brew services start mysql 2>/dev/null && echo "" && echo -e "  ${GREEN}✅ MySQL 已启动${NC}" && return 0
    elif command -v mysql.server &> /dev/null; then
        mysql.server start 2>/dev/null && echo "" && echo -e "  ${GREEN}✅ MySQL 已启动${NC}" && return 0
    elif command -v mysqld_safe &> /dev/null; then
        mysqld_safe --skip-grant-tables &> /dev/null &
        sleep 3
        echo "" && echo -e "  ${GREEN}✅ MySQL 已启动${NC}" && return 0
    fi
    echo ""
    echo -e "  ${RED}❌ 无法自动启动 MySQL，请手动启动${NC}"
    return 1
}

# 停止 MySQL
stop_mysql() {
    if ! command -v mysql &> /dev/null && [ ! -f "/usr/local/mysql/bin/mysql" ]; then
        echo -e "  ${YELLOW}⚠️  未检测到 MySQL，跳过${NC}"
        return 0
    fi

    if ! mysqladmin ping -u root --silent 2>/dev/null; then
        echo -e "  ${YELLOW}⚠️  MySQL 未在运行${NC}"
        return 0
    fi

    if command -v brew &> /dev/null && brew services list 2>/dev/null | grep -q mysql; then
        brew services stop mysql 2>/dev/null && echo -e "  ${GREEN}✅ MySQL 已停止${NC}"
    elif command -v mysql.server &> /dev/null; then
        mysql.server stop 2>/dev/null && echo -e "  ${GREEN}✅ MySQL 已停止${NC}"
    elif command -v mysqladmin &> /dev/null; then
        mysqladmin -u root shutdown 2>/dev/null && echo -e "  ${GREEN}✅ MySQL 已停止${NC}"
    else
        echo -e "  ${RED}❌ 无法自动停止 MySQL，请手动停止${NC}"
    fi
}

# 停止前后端进程
kill_by_port() {
    local port=$1
    local name=$2
    local pids=$(lsof -ti :"$port" 2>/dev/null)
    if [ -n "$pids" ]; then
        echo "$pids" | xargs kill 2>/dev/null
        echo -e "  ${GREEN}✅ ${name}已停止${NC}"
    else
        echo -e "  ${YELLOW}⚠️  ${name}未在运行${NC}"
    fi
}

# ===========================================
# start - 启动所有服务
# ===========================================
cmd_start() {
    MYSQL_NEEDED=false
    [ "$DB_MODE" = "mysql" ] && MYSQL_NEEDED=true

    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  🚀 启动开发环境${NC}"
    echo -e "  数据库: ${GREEN}${DB_MODE}${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # 0. 清理残留端口
    echo -e "${YELLOW}[0/5] 清理残留进程...${NC}"
    local old_8080=$(lsof -ti :8080 2>/dev/null)
    local old_3000=$(lsof -ti :3000 2>/dev/null)
    if [ -n "$old_8080" ] || [ -n "$old_3000" ]; then
        [ -n "$old_8080" ] && echo "$old_8080" | xargs kill 2>/dev/null && echo -e "  ✅ 已清理 8080 端口残留"
        [ -n "$old_3000" ] && echo "$old_3000" | xargs kill 2>/dev/null && echo -e "  ✅ 已清理 3000 端口残留"
        sleep 2
    else
        echo -e "  ✅ 端口空闲"
    fi
    echo ""

    # 1. 环境检测
    echo -e "${YELLOW}[1/5] 检测运行环境...${NC}"

    if command -v java &> /dev/null; then
        echo -e "  ✅ Java: ${GREEN}$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')${NC}"
    else
        echo ""
        echo -e "  ${RED}❌ 未检测到 Java，请安装 JDK 17+${NC}"
        echo -e "  ${YELLOW}  一键安装: ./setup.sh install${NC}"
        exit 1
    fi

    if command -v node &> /dev/null; then
        echo -e "  ✅ Node.js: ${GREEN}$(node -v)${NC}"
    else
        echo ""
        echo -e "  ${RED}❌ 未检测到 Node.js，请安装 Node.js 18+${NC}"
        echo -e "  ${YELLOW}  一键安装: ./setup.sh install${NC}"
        exit 1
    fi
    echo ""

    # 2. MySQL（仅 mysql 模式）
    if [ "$MYSQL_NEEDED" = true ]; then
        echo -e "${YELLOW}[2/5] 启动 MySQL...${NC}"
        start_mysql
    else
        echo -e "${YELLOW}[2/5] 数据库: ${GREEN}H2 内存数据库（无需额外服务）${NC}"
    fi
    echo ""

    # 3. 前端依赖
    echo -e "${YELLOW}[3/5] 检查前端依赖...${NC}"
    cd "$FRONTEND_DIR"
    if [ ! -d "node_modules" ]; then
        echo -e "  正在安装前端依赖..."
        npm install
        echo -e "  ${GREEN}✅ 前端依赖安装完成${NC}"
    else
        echo -e "  ${GREEN}✅ 前端依赖已存在${NC}"
    fi
    cd "$SCRIPT_DIR"
    echo ""

    # 4. 后端（先启动，等待就绪后才启动前端）
    echo -e "${YELLOW}[4/5] 启动后端服务...${NC}"
    cd "$BACKEND_DIR"
    chmod +x mvnw 2>/dev/null || true

    local MVN_CMD="./mvnw spring-boot:run -q"
    if [ "$MYSQL_NEEDED" = true ]; then
        MVN_CMD="SPRING_PROFILES_ACTIVE=mysql $MVN_CMD"
    fi

    $MVN_CMD &
    BACKEND_PID=$!
    echo -e "  后端 PID: $BACKEND_PID"
    cd "$SCRIPT_DIR"

    echo -n "  等待后端就绪"
    local backend_ready=false
    for i in $(seq 1 120); do
        # 先检查进程是否还活着
        if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
            echo ""
            echo -e "  ${RED}❌ 后端进程异常退出，请检查错误日志${NC}"
            exit 1
        fi
        if curl -s http://localhost:8080/api/hello > /dev/null 2>&1; then
            echo ""
            echo -e "  ${GREEN}✅ 后端就绪！${NC}"
            backend_ready=true
            break
        fi
        echo -n "."
        sleep 2
    done
    echo ""

    if [ "$backend_ready" = false ]; then
        echo -e "  ${RED}❌ 后端启动超时，请检查日志${NC}"
        kill "$BACKEND_PID" 2>/dev/null
        exit 1
    fi

    # 5. 前端
    echo -e "${YELLOW}[5/5] 启动前端服务...${NC}"
    cd "$FRONTEND_DIR"
    npm run dev &
    FRONTEND_PID=$!
    echo -e "  前端 PID: $FRONTEND_PID"
    cd "$SCRIPT_DIR"

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✅ 全部启动完成！${NC}"
    echo -e "${GREEN}  前端: http://localhost:3000${NC}"
    echo -e "${GREEN}  后端: http://localhost:8080${NC}"
    [ "$MYSQL_NEEDED" = false ] && echo -e "${GREEN}  H2 控制台: http://localhost:8080/h2-console${NC}"
    echo -e "${GREEN}  按 Ctrl+C 停止前后端${NC}"
    echo -e "${GREEN}  停止所有: ./dev.sh stop${NC}"
    echo -e "${GREEN}========================================${NC}"

    cleanup_start() {
        echo ""
        echo -e "${YELLOW}正在停止前后端...${NC}"
        [ -n "$FRONTEND_PID" ] && kill -0 "$FRONTEND_PID" 2>/dev/null && kill "$FRONTEND_PID" 2>/dev/null
        [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null && kill "$BACKEND_PID" 2>/dev/null
        echo -e "${GREEN}已停止（MySQL 仍在运行）${NC}"
        exit 0
    }
    trap cleanup_start SIGINT SIGTERM

    wait
}

# ===========================================
# stop - 停止所有服务
# ===========================================
cmd_stop() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  🛑 停止开发环境${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    echo -e "${YELLOW}[1/3] 停止前端...${NC}"
    kill_by_port 3000 "前端 (3000)"

    echo -e "${YELLOW}[2/3] 停止后端...${NC}"
    kill_by_port 8080 "后端 (8080)"

    if [ "$MYSQL_NEEDED" = true ]; then
        echo -e "${YELLOW}[3/3] 停止 MySQL...${NC}"
        stop_mysql
    else
        echo -e "${YELLOW}[3/3] H2 内存数据库无需停止${NC}"
    fi

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✅ 所有服务已停止${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# ===========================================
# 入口
# ===========================================
case "${1:-}" in
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    *)
        echo -e "${BLUE}AI 项目脚手架 - 开发环境管理${NC}"
        echo ""
        echo "用法:  ./dev.sh <命令>"
        echo ""
        echo "命令:"
        echo "  start    启动所有服务（当前数据库模式: ${DB_MODE}）"
        echo "  stop     停止所有服务"
        echo ""
        echo "配置（编辑 dev.sh 顶部）:"
        echo "  DB_MODE=\"h2\"     默认，H2 内存数据库，无需安装"
        echo "  DB_MODE=\"mysql\"  使用本地 MySQL"
        echo ""
        echo "示例:"
        echo "  ./dev.sh start"
        echo "  ./dev.sh stop"
        ;;
esac

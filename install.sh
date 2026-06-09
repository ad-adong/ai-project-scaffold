#!/bin/bash
# ============================================
# AI 项目脚手架 - 项目下载脚本
#
# 唯一功能：从远端拉取项目到本地
#
# 用法：
#   curl -fsSL https://你的CDN域名/install.sh | bash
#   或手动下载后：sh install.sh
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ===================== 配置 =====================
GITHUB_REPO="ad-adong/ai-project-scaffold"
GITHUB_BRANCH="main"
ZIP_URL="https://github.com/${GITHUB_REPO}/archive/refs/heads/${GITHUB_BRANCH}.zip"
TARGET_DIR="$HOME/ai-project-scaffold"
# =================================================

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   📦 AI 项目脚手架 - 下载项目        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# 如果已在项目目录内，跳过
if [ -f "./dev.sh" ] && [ -f "./backend/mvnw" ]; then
    echo -e "${GREEN}✅ 已在项目目录中，跳过下载${NC}"
    echo -e "  当前目录: $(pwd)"
    echo ""
    exit 0
fi

# 如果目标目录已有项目，跳过
if [ -d "$TARGET_DIR" ] && [ -f "$TARGET_DIR/dev.sh" ]; then
    echo -e "${YELLOW}项目已存在: ${TARGET_DIR}${NC}"
    echo -e "${YELLOW}如需重新下载，请先删除该目录${NC}"
    echo ""
    exit 0
fi

echo -e "  下载地址: ${YELLOW}${ZIP_URL}${NC}"
echo ""

# 下载
local tmp_zip="/tmp/ai-scaffold-dl-$$.zip"
local tmp_extract="/tmp/ai-scaffold-extract-$$"

if ! curl -fsSL --progress-bar -o "$tmp_zip" "$ZIP_URL"; then
    echo ""
    echo -e "  ${RED}❌ 下载失败，请检查网络或链接${NC}"
    echo -e "  ${RED}   ${ZIP_URL}${NC}"
    rm -f "$tmp_zip"
    exit 1
fi
echo ""

# 解压
echo -n "  正在解压..."
mkdir -p "$tmp_extract"
unzip -qo "$tmp_zip" -d "$tmp_extract"
echo -e " ${GREEN}完成${NC}"

# 处理嵌套目录 + 拷贝（dotglob 确保 .mvn .qoder 等隐藏文件不丢失）
shopt -s dotglob
mkdir -p "$TARGET_DIR"

if [ -f "$tmp_extract/dev.sh" ]; then
    cp -R "$tmp_extract"/* "$TARGET_DIR/" 2>/dev/null || true
else
    local inner_dir=$(ls -d "$tmp_extract"/*/ 2>/dev/null | head -n 1)
    if [ -d "$inner_dir" ] && [ -f "$inner_dir/dev.sh" ]; then
        cp -R "$inner_dir"/* "$TARGET_DIR/" 2>/dev/null || true
    else
        cp -R "$tmp_extract"/* "$TARGET_DIR/" 2>/dev/null || true
    fi
fi
shopt -u dotglob

rm -rf "$tmp_zip" "$tmp_extract"

# 加可执行权限
chmod +x "$TARGET_DIR/dev.sh" 2>/dev/null || true
chmod +x "$TARGET_DIR/setup.sh" 2>/dev/null || true
chmod +x "$TARGET_DIR/install.sh" 2>/dev/null || true
chmod +x "$TARGET_DIR/backend/mvnw" 2>/dev/null || true

echo ""

# 验证关键文件
local ok=true
for f in "dev.sh" "backend/mvnw" "backend/.mvn/wrapper/maven-wrapper.jar" "frontend/package.json"; do
    if [ ! -f "$TARGET_DIR/$f" ]; then
        echo -e "  ${RED}❌ 缺少: $f${NC}"
        ok=false
    fi
done

if [ "$ok" = false ]; then
    echo ""
    echo -e "  ${RED}下载不完整，请重试${NC}"
    rm -rf "$TARGET_DIR"
    exit 1
fi

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ 项目下载完成！                   ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  目录: ${TARGET_DIR}${NC}"
echo -e "${GREEN}║                                         ${NC}"
echo -e "${GREEN}║  下一步:                               ${NC}"
echo -e "${GREEN}║    cd ${TARGET_DIR}${NC}"
echo -e "${GREEN}║    ./dev.sh start                      ${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

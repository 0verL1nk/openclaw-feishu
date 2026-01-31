#!/bin/bash

# OpenClaw Feishu Plugin 一键发布脚本
# 用途：自动执行版本升级、提交、发布、同步镜像的完整流程

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 检查当前目录
if [ ! -f "package.json" ]; then
    error "请在项目根目录下运行此脚本"
fi

if [ ! -f "openclaw.plugin.json" ]; then
    error "找不到 openclaw.plugin.json 文件"
fi

# 读取当前版本
CURRENT_VERSION=$(node -p "require('./package.json').version")
info "当前版本: ${CURRENT_VERSION}"

# 检查是否有未提交的改动
if [ -n "$(git status --porcelain)" ]; then
    warn "检测到未提交的改动:"
    git status --short
    read -p "是否继续? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "用户取消发布"
    fi
fi

# 询问版本升级类型
echo ""
echo "请选择版本升级类型:"
echo "  1) patch (0.1.5 -> 0.1.6) - 修复 bug"
echo "  2) minor (0.1.5 -> 0.2.0) - 新功能"
echo "  3) major (0.1.5 -> 1.0.0) - 重大变更"
echo "  4) 自定义版本号"
echo "  5) 跳过版本升级（使用当前版本）"
read -p "请选择 (1-5): " choice

case $choice in
    1)
        VERSION_TYPE="patch"
        ;;
    2)
        VERSION_TYPE="minor"
        ;;
    3)
        VERSION_TYPE="major"
        ;;
    4)
        read -p "请输入新版本号: " NEW_VERSION
        if [ -z "$NEW_VERSION" ]; then
            error "版本号不能为空"
        fi
        VERSION_TYPE="custom"
        ;;
    5)
        VERSION_TYPE="skip"
        NEW_VERSION=$CURRENT_VERSION
        ;;
    *)
        error "无效的选择"
        ;;
esac

# 升级版本号
if [ "$VERSION_TYPE" != "skip" ]; then
    if [ "$VERSION_TYPE" = "custom" ]; then
        info "设置版本为: ${NEW_VERSION}"
        npm version "$NEW_VERSION" --no-git-tag-version
    else
        info "升级版本类型: ${VERSION_TYPE}"
        npm version "$VERSION_TYPE" --no-git-tag-version
        NEW_VERSION=$(node -p "require('./package.json').version")
    fi
    success "版本已升级: ${CURRENT_VERSION} -> ${NEW_VERSION}"
    
    # 更新 README 中的版本号
    info "更新 README 中的版本号..."
    sed -i "s/${CURRENT_VERSION}/${NEW_VERSION}/g" README.md README_EN.md 2>/dev/null || true
else
    info "跳过版本升级，使用当前版本: ${CURRENT_VERSION}"
    NEW_VERSION=$CURRENT_VERSION
fi

# 运行类型检查
info "运行类型检查..."
if npm run --silent check 2>/dev/null || npx tsc --noEmit 2>/dev/null; then
    success "类型检查通过"
else
    warn "类型检查失败或未配置，继续发布..."
fi

# 询问 changelog
echo ""
read -p "请输入本次发布的改动说明 (changelog): " CHANGELOG
if [ -z "$CHANGELOG" ]; then
    CHANGELOG="Release version ${NEW_VERSION}"
fi

# Git 提交
if [ "$VERSION_TYPE" != "skip" ] || [ -n "$(git status --porcelain)" ]; then
    info "提交改动到 Git..."
    git add package.json package-lock.json README.md README_EN.md 2>/dev/null || git add package.json README.md README_EN.md
    
    # 如果有改动才提交
    if [ -n "$(git diff --cached)" ]; then
        git commit -m "chore: release v${NEW_VERSION}

${CHANGELOG}"
        success "Git 提交完成"
    else
        info "没有需要提交的改动"
    fi
fi

# 推送到远程仓库
info "推送到 GitHub..."
git push
success "代码已推送到远程仓库"

# 发布到 npm
echo ""
read -p "是否发布到 npm? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    warn "跳过 npm 发布"
else
    info "发布到 npm..."
    npm publish --access public
    success "已发布到 npm: @overlink/openclaw-feishu@${NEW_VERSION}"
    
    # 等待几秒让 npm 同步
    sleep 3
    
    # 同步到 npmmirror
    info "触发 npmmirror 同步..."
    SYNC_RESULT=$(curl -s -X PUT https://registry.npmmirror.com/@overlink/openclaw-feishu/sync)
    if echo "$SYNC_RESULT" | grep -q '"ok":true'; then
        success "npmmirror 同步请求已发送"
    else
        warn "npmmirror 同步请求失败: $SYNC_RESULT"
    fi
fi

# 创建 Git Tag
echo ""
read -p "是否创建 Git Tag? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    info "创建 Git Tag: v${NEW_VERSION}"
    git tag -a "v${NEW_VERSION}" -m "${CHANGELOG}"
    git push origin "v${NEW_VERSION}"
    success "Git Tag 已创建并推送"
fi

# 完成
echo ""
success "=========================================="
success "🎉 发布完成！"
success "=========================================="
echo ""
info "版本: ${NEW_VERSION}"
info "npm: https://www.npmjs.com/package/@overlink/openclaw-feishu"
info "镜像: https://npmmirror.com/package/@overlink/openclaw-feishu"
info "GitHub: https://github.com/overlink/openclaw-feishu"
echo ""
info "用户现在可以通过以下命令安装:"
echo "  openclaw plugins install @overlink/openclaw-feishu"
echo ""

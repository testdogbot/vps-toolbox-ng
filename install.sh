#!/usr/bin/env bash
# vps-toolbox 安装脚本
# 支持两种方式：本地目录安装 / 配置 REPO_URL 后从 GitHub 安装
set -euo pipefail

REPO_URL=""          # 发布后填写，例如 https://github.com/your-name/vps-toolbox
BRANCH="main"
INSTALL_DIR="/opt/vps-toolbox"
MARKER=".vps-toolbox-install"

if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 运行: sudo bash install.sh"
    exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR=""

if [ -f "$SRC_DIR/vps-toolbox.sh" ]; then
    SRC="$SRC_DIR"
elif [ -n "$REPO_URL" ]; then
    TMP_DIR="$(mktemp -d)"
    curl -fsSL "$REPO_URL/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMP_DIR" --strip-components=1
    SRC="$TMP_DIR"
else
    echo "未找到本地源码，且未配置 REPO_URL。"
    echo "请在脚本顶部填写你的仓库地址，或进入项目目录后运行本脚本。"
    exit 1
fi

if [ -d "$INSTALL_DIR" ] && [ ! -f "$INSTALL_DIR/$MARKER" ]; then
    echo "拒绝覆盖非本安装器管理的目录: $INSTALL_DIR"
    echo "如确认要替换，请先手动备份并移走该目录。"
    exit 1
fi

if [ "$SRC" = "$INSTALL_DIR" ]; then
    echo "当前已经在安装目录内，请从源码目录运行安装脚本。"
    exit 1
fi

if [ -d "$INSTALL_DIR" ]; then
    BACKUP="${INSTALL_DIR}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$INSTALL_DIR" "$BACKUP"
    echo "旧版本已备份到: $BACKUP"
fi

mkdir -p "$INSTALL_DIR"
cp -a "$SRC"/. "$INSTALL_DIR"/
rm -rf "$INSTALL_DIR/.git"
touch "$INSTALL_DIR/$MARKER"
chmod +x "$INSTALL_DIR/vps-toolbox.sh" "$INSTALL_DIR/install.sh"
if [ -d "$INSTALL_DIR/scripts" ]; then
    find "$INSTALL_DIR/scripts" -name '*.sh' -exec chmod +x {} \;
fi

ln -sf "$INSTALL_DIR/vps-toolbox.sh" /usr/local/bin/vps-toolbox
ln -sf "$INSTALL_DIR/vps-toolbox.sh" /usr/local/bin/vps
ln -sf "$INSTALL_DIR/vps-toolbox.sh" /usr/local/bin/vpst

if [ -n "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
fi

echo "安装完成: $INSTALL_DIR"
echo "运行命令: vps (或 vpst / vps-toolbox)"

if [ -t 0 ]; then
    exec bash "$INSTALL_DIR/vps-toolbox.sh"
fi

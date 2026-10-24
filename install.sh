#!/usr/bin/env bash
# vps-toolbox 安装脚本
# 支持两种方式：本地目录安装 / 配置 REPO_URL 后从 GitHub 安装
set -euo pipefail

REPO_URL="https://github.com/testdogbot/vps-toolbox-ng"
BRANCH="main"
MARKER=".vps-toolbox-install"
DEFAULT_INSTALL_DIR="/opt/vps-toolbox"

if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 运行: sudo bash install.sh"
    exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR=""
PRESERVE_DIR=""
BACKUP=""

cleanup() {
    if [ -n "$TMP_DIR" ]; then rm -rf "$TMP_DIR"; fi
    if [ -n "$PRESERVE_DIR" ]; then rm -rf "$PRESERVE_DIR"; fi
}
trap cleanup EXIT

if [ -f "$SRC_DIR/vps-toolbox.sh" ]; then
    SRC="$SRC_DIR"
elif [ -n "$REPO_URL" ]; then
    TMP_DIR="$(mktemp -d)"
    if ! curl -fsSL "$REPO_URL/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMP_DIR" --strip-components=1; then
        echo "下载安装包失败，请检查网络。"
        exit 1
    fi
    SRC="$TMP_DIR"
else
    echo "未找到本地源码，且未配置 REPO_URL。"
    echo "请在脚本顶部填写你的仓库地址，或进入项目目录后运行本脚本。"
    exit 1
fi

INSTALL_DIR="$DEFAULT_INSTALL_DIR"
if [ -f "$SRC/lib/branding.sh" ]; then
    configured_dir=$(grep -m1 '^PROJECT_INSTALL_DIR=' "$SRC/lib/branding.sh" | cut -d'"' -f2 || true)
    [ -n "$configured_dir" ] && INSTALL_DIR="$configured_dir"
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

# 保留已安装版本的本地 brand 配置（仓库地址、快捷命令、统计位置等）
if [ -f "$INSTALL_DIR/lib/branding.sh" ]; then
    PRESERVE_DIR="$(mktemp -d)"
    cp -f "$INSTALL_DIR/lib/branding.sh" "$PRESERVE_DIR/branding.sh"
fi

if [ -d "$INSTALL_DIR" ]; then
    BACKUP="${INSTALL_DIR}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$INSTALL_DIR" "$BACKUP"
    echo "旧版本已备份到: $BACKUP"
fi

rollback_install() {
    rm -rf "$INSTALL_DIR"
    if [ -n "$BACKUP" ] && [ -d "$BACKUP" ]; then
        mv "$BACKUP" "$INSTALL_DIR"
        echo "安装失败，已回滚到旧版本: $INSTALL_DIR"
    else
        echo "安装失败，未留下半成品目录。"
    fi
}

install_tree() {
    mkdir -p "$INSTALL_DIR" || return 1
    cp -a "$SRC"/. "$INSTALL_DIR"/ || return 1
    rm -rf "$INSTALL_DIR/.git" || return 1
    touch "$INSTALL_DIR/$MARKER" || return 1
    chmod +x "$INSTALL_DIR/vps-toolbox.sh" "$INSTALL_DIR/install.sh" || return 1
    if [ -d "$INSTALL_DIR/scripts" ]; then
        find "$INSTALL_DIR/scripts" -name '*.sh' -exec chmod +x {} \; || return 1
    fi
    return 0
}

merge_missing_keys() {
    local target="$1" defaults="$2" line key
    [ -f "$target" ] && [ -f "$defaults" ] || return 0
    [ -n "$(tail -c 1 "$target" 2>/dev/null)" ] && printf '\n' >> "$target"
    while IFS= read -r line; do
        [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)= ]] || continue
        key="${BASH_REMATCH[1]}"
        if ! grep -qE "^[[:space:]]*(export[[:space:]]+)?${key}=" "$target"; then
            printf '%s\n' "$line" >> "$target"
        fi
    done < "$defaults"
}

restore_branding() {
    local new_version
    [ -n "$PRESERVE_DIR" ] && [ -f "$PRESERVE_DIR/branding.sh" ] || return 0
    cp -f "$PRESERVE_DIR/branding.sh" "$INSTALL_DIR/lib/branding.sh" || return 1
    merge_missing_keys "$INSTALL_DIR/lib/branding.sh" "$SRC/lib/branding.sh"
    new_version=$(grep -m1 '^PROJECT_VERSION=' "$SRC/lib/branding.sh" | cut -d'"' -f2 || true)
    if [ -n "$new_version" ]; then
        sed -i "s|^PROJECT_VERSION=.*|PROJECT_VERSION=\"${new_version}\"|" "$INSTALL_DIR/lib/branding.sh"
    fi
    return 0
}

if ! install_tree || ! restore_branding; then
    rollback_install
    exit 1
fi

link_command() {
    local link_path="$1" existing
    if [ -L "$link_path" ]; then
        existing=$(readlink "$link_path" 2>/dev/null || true)
        case "$existing" in
            "$INSTALL_DIR"/*|*/vps-toolbox.sh) ln -sfn "$INSTALL_DIR/vps-toolbox.sh" "$link_path" ;;
            *) echo "跳过 $link_path：已指向其他程序（$existing）" ;;
        esac
    elif [ -e "$link_path" ]; then
        echo "跳过 $link_path：已存在同名文件或目录"
    else
        ln -sfn "$INSTALL_DIR/vps-toolbox.sh" "$link_path"
    fi
}

link_command /usr/local/bin/vps-toolbox
link_command /usr/local/bin/vps
link_command /usr/local/bin/vpst

echo "安装完成: $INSTALL_DIR"
echo "运行命令: vps (或 vpst / vps-toolbox)"

if [ -t 0 ]; then
    exec bash "$INSTALL_DIR/vps-toolbox.sh"
fi

#!/usr/bin/env bash
# vps-toolbox 安装脚本
# 支持两种方式：本地目录安装 / 配置 REPO_URL 后从 GitHub 安装
set -euo pipefail

REPO_URL="${VPS_TOOLBOX_REPO_URL:-https://github.com/testdogbot/vps-toolbox-ng}"
BRANCH="${VPS_TOOLBOX_BRANCH:-main}"
GH_PROXY="${VPS_TOOLBOX_GH_PROXY-https://ghfast.top}"
CONNECT_TIMEOUT="${VPS_TOOLBOX_CONNECT_TIMEOUT:-10}"
DOWNLOAD_TIMEOUT="${VPS_TOOLBOX_DOWNLOAD_TIMEOUT:-60}"
SLOW_SECONDS="${VPS_TOOLBOX_SLOW_SECONDS:-20}"
MARKER=".vps-toolbox-install"
DEFAULT_INSTALL_DIR="/opt/vps-toolbox"
REPO_URL="${REPO_URL%/}"
GH_PROXY="${GH_PROXY%/}"
DOWNLOAD_SECONDS=0

if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 运行: sudo bash install.sh"
    exit 1
fi

curl_hint() {
    case "$1" in
        6)  echo "DNS 解析失败" ;;
        7)  echo "无法连接（被拒绝或网络不通）" ;;
        22) echo "请求被中断或返回错误" ;;
        28) echo "超时" ;;
        35) echo "TLS 握手失败（可能被干扰）" ;;
        56) echo "连接被重置" ;;
        *)  echo "curl 退出码 $1" ;;
    esac
}

download_source() {
    local archive="$1" base label rc start elapsed total=0
    local bases=("$REPO_URL")
    if [ -n "$GH_PROXY" ]; then
        bases+=("${GH_PROXY}/${REPO_URL}")
    fi
    for base in "${bases[@]}"; do
        if [ "$base" = "$REPO_URL" ]; then
            label="GitHub 直连"
        else
            label="镜像 ${GH_PROXY}"
        fi
        echo "正在从 ${label} 下载安装包..."
        start=$SECONDS
        rc=0
        curl -fsSL --connect-timeout "$CONNECT_TIMEOUT" --max-time "$DOWNLOAD_TIMEOUT" \
            -o "${archive}.part" "${base}/archive/refs/heads/${BRANCH}.tar.gz" || rc=$?
        elapsed=$((SECONDS - start))
        total=$((total + elapsed))
        if [ "$rc" -eq 0 ] && [ -s "${archive}.part" ]; then
            rm -rf "${TMP_DIR}/src"
            mkdir -p "${TMP_DIR}/src"
            if tar -xzf "${archive}.part" -C "${TMP_DIR}/src" --strip-components=1 2>/dev/null && [ -f "${TMP_DIR}/src/vps-toolbox.sh" ]; then
                mv -f "${archive}.part" "$archive"
                if [ "$elapsed" -ge "$SLOW_SECONDS" ]; then
                    echo "提示：${label} 耗时 ${elapsed} 秒，网络较慢。"
                fi
                DOWNLOAD_SECONDS=$total
                return 0
            fi
            echo "提示：${label} 返回的安装包不完整或无法解压。"
        else
            if [ "$rc" -eq 28 ]; then
                echo "提示：${label} 下载超时（上限 ${DOWNLOAD_TIMEOUT} 秒）"
            else
                echo "提示：${label} 下载失败：$(curl_hint "$rc")（耗时 ${elapsed} 秒）"
            fi
        fi
        rm -f "${archive}.part"
    done
    DOWNLOAD_SECONDS=$total
    return 1
}

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
    if ! download_source "${TMP_DIR}/src.tar.gz"; then
        echo ""
        echo "下载安装包失败：GitHub 直连与镜像均不可达或响应超时。"
        echo "可能原因：服务器无法访问 GitHub（国内节点常见）、DNS 异常或没有出网。"
        echo "可尝试："
        echo "  1) 换镜像：VPS_TOOLBOX_GH_PROXY=https://你的镜像 bash install.sh"
        echo "  2) 使用代理：export https_proxy=http://127.0.0.1:端口 后重试"
        echo "  3) 无外网：把源码目录上传到服务器后，直接运行其中的 install.sh"
        exit 1
    fi
    if [ "$DOWNLOAD_SECONDS" -ge 30 ]; then
        echo "提示：本次下载共耗时 ${DOWNLOAD_SECONDS} 秒，网络较慢，建议配置镜像或代理。"
    fi
    SRC="${TMP_DIR}/src"
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

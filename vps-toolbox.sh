#!/usr/bin/env bash
# VPS 工具箱入口
# 用法: sudo bash vps-toolbox.sh [info|update|version|help]

VPS_TOOLBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export VPS_TOOLBOX_ROOT

source "${VPS_TOOLBOX_ROOT}/lib/branding.sh"
source "${VPS_TOOLBOX_ROOT}/lib/colors.sh"

usage() {
    cat <<EOF
${PROJECT_TITLE} v${PROJECT_VERSION}

用法: vps [命令]

  info       查看系统信息（无需 root）
  update     检查并安装更新（需要 root）
  version    查看版本
  help       显示本帮助

不带参数运行启动交互菜单（需要 root）。
EOF
}

load_toolbox() {
    source "${VPS_TOOLBOX_ROOT}/lib/common.sh"
    source "${VPS_TOOLBOX_ROOT}/lib/components.sh"
    source "${VPS_TOOLBOX_ROOT}/lib/ldnmp.sh"
    source "${VPS_TOOLBOX_ROOT}/lib/shortcut.sh"
    source "${VPS_TOOLBOX_ROOT}/lib/stats.sh"

    local module
    for module in "${VPS_TOOLBOX_ROOT}"/modules/*.sh; do
        source "$module"
    done

    source "${VPS_TOOLBOX_ROOT}/lib/menu.sh"
}

case "${1:-}" in
    version|-v|--version)
        echo "${PROJECT_TITLE} v${PROJECT_VERSION}"
        exit 0
        ;;
    help|-h|--help)
        usage
        exit 0
        ;;
esac

# 只读命令允许非 root 运行
if [ "${1:-}" = "info" ]; then
    load_toolbox
    menu_system_info
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo -e "${red}注意: 请在root用户下运行脚本${re}"
    echo ""
    usage
    exit 1
fi

load_toolbox

if [ "${1:-}" = "update" ]; then
    VPS_TOOLBOX_CLI=1 menu_update_self
    exit $?
fi

if [ "${ENABLE_STATS}" = "1" ]; then
    sum_run_times
fi

create_shortcut
main_loop

#!/usr/bin/env bash
# VPS 工具箱入口
# 用法: sudo bash vps-toolbox.sh

VPS_TOOLBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export VPS_TOOLBOX_ROOT

source "${VPS_TOOLBOX_ROOT}/lib/branding.sh"
source "${VPS_TOOLBOX_ROOT}/lib/colors.sh"

if [ "$EUID" -ne 0 ]; then
    echo -e "${red}注意: 请在root用户下运行脚本${re}"
    sleep 1
    exit 1
fi

source "${VPS_TOOLBOX_ROOT}/lib/common.sh"
source "${VPS_TOOLBOX_ROOT}/lib/components.sh"
source "${VPS_TOOLBOX_ROOT}/lib/ldnmp.sh"
source "${VPS_TOOLBOX_ROOT}/lib/shortcut.sh"
source "${VPS_TOOLBOX_ROOT}/lib/stats.sh"

for module in "${VPS_TOOLBOX_ROOT}"/modules/*.sh; do
    source "$module"
done

source "${VPS_TOOLBOX_ROOT}/lib/menu.sh"

if [ "${ENABLE_STATS}" = "1" ]; then
    sum_run_times
fi

create_shortcut
main_loop

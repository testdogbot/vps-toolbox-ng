#!/usr/bin/env bash
# 创建快捷命令：/usr/local/bin/<PROJECT_NAME>.sh 包装器 + 短命令软链接

create_shortcut() {
    local script_path="${SHORTCUT_TARGET}"
    local wrapper_content

    if [ -n "${PROJECT_RAW_URL}" ]; then
        wrapper_content="#!/bin/bash
# 在线获取最新脚本并执行
SCRIPT_URL=\"${PROJECT_RAW_URL}\"
TEMP_SCRIPT=\"/tmp/${PROJECT_NAME}-latest.sh\"

if curl -fsSL \"\$SCRIPT_URL\" -o \"\$TEMP_SCRIPT\" >/dev/null 2>&1; then
    chmod +x \"\$TEMP_SCRIPT\" >/dev/null 2>&1
    bash \"\$TEMP_SCRIPT\" \"\$@\"
    rm -f \"\$TEMP_SCRIPT\" >/dev/null 2>&1
else
    echo \"无法在线获取脚本，请检查网络连接\"
    exit 1
fi"
    else
        wrapper_content="#!/bin/bash
# 本地安装模式：直接执行安装目录内的入口脚本
exec bash \"${VPS_TOOLBOX_ENTRY}\" \"\$@\""
    fi

    echo "$wrapper_content" > "$script_path" 2>/dev/null || return 0
    chmod +x "$script_path" 2>/dev/null

    local link_name link_path
    for link_name in "${SHORTCUT_NAMES[@]}"; do
        link_path="/usr/local/bin/$link_name"
        if [ ! -L "$link_path" ] || [ "$(readlink "$link_path")" != "$script_path" ]; then
            ln -sf "$script_path" "$link_path" >/dev/null 2>&1
        fi
    done
    hash -r >/dev/null 2>&1
}

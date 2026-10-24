#!/usr/bin/env bash
# vps-toolbox 模块：脚本更新
# 原分支从 eooce/ssh_tool 拉取更新日志，这里改为读取本项目自身的更新日志；
# 配置了 PROJECT_RAW_URL 时从你自己的仓库拉取。

menu_update_self() {
    clear
    local base
    base="${PROJECT_RAW_URL%/*}"
    if [ -n "${PROJECT_RAW_URL}" ] && [ -n "${base}" ]; then
        local tmp
        tmp="$(mktemp)"
        if curl -fsSL "${base}/update_log.sh" -o "${tmp}"; then
            bash "${tmp}"
            rm -f "${tmp}"
        else
            rm -f "${tmp}"
            echo -e "${red}更新日志获取失败，请检查 PROJECT_RAW_URL 或网络${re}"
        fi
    elif [ -f "${VPS_TOOLBOX_ROOT}/CHANGELOG.md" ]; then
        cat "${VPS_TOOLBOX_ROOT}/CHANGELOG.md"
    else
        echo -e "${yellow}未配置更新源（lib/branding.sh 中的 PROJECT_RAW_URL）${re}"
    fi
    echo ""
    echo -e "${green}当前版本：${PROJECT_VERSION}${re}"
}

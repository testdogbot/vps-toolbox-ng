#!/usr/bin/env bash
# vps-toolbox 模块：系统更新
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_system_update() {
    clear
    update_system() {
        if command -v apt &>/dev/null; then
            DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -y
        elif command -v dnf &>/dev/null; then
            dnf check-update && dnf upgrade -y
        elif command -v yum &>/dev/null; then
            yum check-update && yum upgrade -y
        elif command -v apk &>/dev/null; then
            apk update && apk upgrade
        else
            echo -e "${red}不支持的Linux发行版${re}"
            return 1
        fi
        return 0
    }

    update_system
}

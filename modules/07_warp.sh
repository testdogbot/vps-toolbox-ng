#!/usr/bin/env bash
# vps-toolbox 模块：WARP 管理
# WARP 菜单脚本来自第三方项目，运行时下载并执行；本项目不内置、不分发其代码

menu_warp() {
    clear
    local url="https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh"
    install wget || return 1
    echo "WARP 菜单脚本来源: ${url}"
    echo -e "${yellow}该脚本为第三方代码，将以 root 权限在本机执行${re}"
    confirm_action "确认下载并运行 WARP 管理脚本？" || { echo -e "${yellow}已取消${re}"; return 0; }
    if ! wget -q -O menu.sh "$url"; then
        echo -e "${red}WARP 脚本下载失败${re}"
        return 1
    fi
    if ! bash -n menu.sh 2>/dev/null; then
        rm -f menu.sh
        echo -e "${red}WARP 脚本校验失败，已删除${re}"
        return 1
    fi
    bash menu.sh
}

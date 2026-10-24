#!/usr/bin/env bash
# vps-toolbox 模块：WARP 管理
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_warp() {
    clear
    install wget
    wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh [option] [lisence/url/token]
}

#!/usr/bin/env bash
# vps-toolbox 模块：BBR 管理
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_bbr() {
    clear
    install wget
    wget --no-check-certificate -O tcpx.sh https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh && chmod +x tcpx.sh && ./tcpx.sh
    rm tcpx.sh
    break_end
    main_menu
}

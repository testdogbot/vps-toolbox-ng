#!/usr/bin/env bash
# vps-toolbox 模块：系统清理
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_system_clean() {
    clear
        clean_system() {

            if command -v apt &>/dev/null; then
                apt autoremove --purge -y && apt clean -y && apt autoclean -y
                apt remove --purge $(dpkg -l | awk '/^rc/ {print $2}') -y
                # 清理包配置文件
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                apt remove --purge $(dpkg -l | awk '/^ii linux-(image|headers)-[^ ]+/{print $2}' | grep -v $(uname -r | sed 's/-.*//') | xargs) -y
            elif command -v yum &>/dev/null; then
                yum autoremove -y && yum clean all
                # 清理日志
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                yum remove $(rpm -q kernel | grep -v $(uname -r)) -y
            elif command -v dnf &>/dev/null; then
                dnf autoremove -y && dnf clean all
                # 清理日志
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                dnf remove $(rpm -q kernel | grep -v $(uname -r)) -y
            elif command -v apk &>/dev/null; then
                apk autoremove -y
                apk clean
                # 清理包配置文件
                apk del $(apk info -e | grep '^r' | awk '{print $1}') -y
                # 清理日志文件
                journalctl --vacuum-time=1s
                journalctl --vacuum-size=50M
                # 移除不再需要的内核
                apk del $(apk info -vv | grep -E 'linux-[0-9]' | grep -v $(uname -r) | awk '{print $1}') -y
            else
                echo -e "${red}暂不支持你的系统！${re}"
                exit 1
            fi
        }
        clean_system
}

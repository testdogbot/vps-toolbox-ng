#!/usr/bin/env bash
# vps-toolbox 模块：游戏开服脚本合集
# 开服脚本为第三方脚本，运行时下载并校验后执行，下载地址可在 lib/branding.sh 中修改

GAMES_SCRIPT_BASE="${GAMES_SCRIPT_BASE:-https://raw.githubusercontent.com/kejilion/sh/main}"

games_run_script() {
    local name="$1" url="$2" target="$HOME/$1" tmp
    if ! command -v curl >/dev/null 2>&1; then
        install curl || return 1
    fi
    echo -e "${yellow}正在下载 ${name} ...${re}"
    tmp="$(mktemp "${target}.XXXXXX" 2>/dev/null)" || return 1
    if ! curl -fsSL --max-time 60 "$url" -o "$tmp"; then
        rm -f "$tmp"
        echo -e "${red}下载失败，请检查网络或 ${url}${re}"
        return 1
    fi
    if [ ! -s "$tmp" ] || ! bash -n "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        echo -e "${red}脚本校验失败，已删除${re}"
        return 1
    fi
    chmod +x "$tmp"
    mv -f "$tmp" "$target"
    echo "脚本来源: ${url}"
    echo "本地文件: ${target}"
    echo -e "${yellow}该脚本为第三方代码，将以 root 权限执行${re}"
    confirm_action "确认运行 ${name}？" || { echo -e "${yellow}已取消（文件已保留，可自行检查）${re}"; return 0; }
    bash "$target"
}

menu_games() {
    while true; do
        clear
        echo "▶ 游戏开服脚本"
        echo "开服脚本来自第三方仓库，下载到 ~ 目录后会显示来源并请求确认"
        echo "------------------------"
        echo "1. 幻兽帕鲁开服脚本"
        echo "2. 我的世界开服脚本"
        echo "------------------------"
        echo -e "${skyblue}0. 返回主菜单${re}"
        echo "------------------------"
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice || return 0

        case "$sub_choice" in
            0) main_menu ;;
            1) clear; games_run_script "palworld.sh" "${GAMES_SCRIPT_BASE}/palworld.sh" ;;
            2) clear; games_run_script "mc.sh" "${GAMES_SCRIPT_BASE}/mc.sh" ;;
            *) echo -e "${red}无效的输入!${re}"; sleep 1 ;;
        esac
        break_end
    done
}

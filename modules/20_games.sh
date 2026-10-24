#!/usr/bin/env bash
# vps-toolbox 模块：游戏开服脚本合集
# 开服脚本为第三方脚本，运行时下载并校验后执行，下载地址可在 lib/branding.sh 中修改

games_run_script() {
    local name="$1" url="$2" target="$HOME/$1"
    if ! command -v curl >/dev/null 2>&1; then
        install curl || return 1
    fi
    echo -e "${yellow}正在下载 ${name} ...${re}"
    if ! curl -fsSL --max-time 60 "$url" -o "$target"; then
        rm -f "$target"
        echo -e "${red}下载失败，请检查网络或 ${url}${re}"
        return 1
    fi
    if [ ! -s "$target" ] || ! bash -n "$target" 2>/dev/null; then
        rm -f "$target"
        echo -e "${red}脚本校验失败，已删除${re}"
        return 1
    fi
    chmod +x "$target"
    echo -e "${green}开始执行 ${target}${re}"
    bash "$target"
}

menu_games() {
    while true; do
        clear
        echo "▶ 游戏开服脚本"
        echo "开服脚本来自第三方仓库，执行前会下载到 ~ 目录，请自行确认脚本内容"
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

#!/usr/bin/env bash
# vps-toolbox 模块：基础工具管理（参考 kejilion/sh 的 linux_tools）
# 显示工具安装状态，支持按编号安装、批量安装和卸载

BASIC_TOOLS=(
    curl wget sudo socat htop iftop unzip tar tmux ffmpeg
    btop ranger ncdu fzf vim nano git jq zip rsync
)

basic_tool_status() {
    local index="$1" name="$2"
    if command -v "$name" >/dev/null 2>&1; then
        printf "%2d. %-10s %b%s%b" "$index" "$name" "$green" "已安装" "$re"
    else
        printf "%2d. %-10s %b%s%b" "$index" "$name" "$red" "未安装" "$re"
    fi
}

show_basic_tools_menu() {
    local i name left right
    echo "▶ 基础工具"
    echo "------------------------"
    for ((i = 0; i < ${#BASIC_TOOLS[@]}; i += 2)); do
        name="${BASIC_TOOLS[i]}"
        left="$(basic_tool_status $((i + 1)) "$name")"
        if [ -n "${BASIC_TOOLS[i + 1]}" ]; then
            right="$(basic_tool_status $((i + 2)) "${BASIC_TOOLS[i + 1]}")"
            printf "%b        %b\n" "$left" "$right"
        else
            printf "%b\n" "$left"
        fi
    done
    echo "------------------------"
    echo " 1-${#BASIC_TOOLS[@]}   安装对应编号的工具"
    echo "98.  安装常用基础工具（下载/解压/tmux/git/jq）"
    echo "99.  卸载指定工具"
    echo "------------------------"
    echo -e "${skyblue} 0.  返回主菜单${re}"
    echo "------------------------"
}

menu_basic_tools() {
    local sub_choice index package confirm
    while true; do
        clear
        show_basic_tools_menu
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

        case "$sub_choice" in
            0)
                main_menu
                ;;
            98)
                clear
                install curl wget socat unzip tar tmux git jq
                break_end
                ;;
            99)
                clear
                read -e -p "请输入要卸载的工具名: " package
                if [ -z "$package" ]; then
                    echo "未输入工具名"
                else
                    read -e -p "确认卸载 ${package}（会删除其配置）？[y/N]: " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        remove "$package"
                    else
                        echo "已取消"
                    fi
                fi
                break_end
                ;;
            ''|*[!0-9]*)
                echo "无效的输入!"
                sleep 1
                ;;
            *)
                index=$((10#$sub_choice))
                if [ "$index" -ge 1 ] && [ "$index" -le "${#BASIC_TOOLS[@]}" ]; then
                    package="${BASIC_TOOLS[index - 1]}"
                    clear
                    install "$package"
                    break_end
                else
                    echo "无效的编号!"
                    sleep 1
                fi
                ;;
        esac
    done
}

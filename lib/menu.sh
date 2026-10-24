#!/usr/bin/env bash
# 主菜单展示与分支分派

show_main_menu() {
    clear
    if [ "${ENABLE_STATS:-0}" = "1" ] && [ -n "${TODAY:-}" ] && [ -n "${TOTAL:-}" ]; then
        echo -e "    ${skyblue}当日运行：${yellow}${TODAY}次   ${skyblue}累计运行：${yellow}${TOTAL}次${re}"
    fi
    echo -e "\033[0;97m-----------------By'${PROJECT_AUTHOR}'-----------------\033[0m"
    if [ -n "${PROJECT_REPO_URL}" ]; then
        echo -e "\033[0;97m项目地址: ${PROJECT_REPO_URL}\033[0m"
    fi
    echo ""
    echo -e "${skyblue} __     ______  ____    _____ ___   ___  _     ____   _____  __${re}"
    echo -e "${skyblue} \\ \\   / /  _ \\/ ___|  |_   _/ _ \\ / _ \\| |   | __ ) / _ \\ \\/ /${re}"
    echo -e "${skyblue}  \\ \\ / /| |_) \\___ \\    | || | | | | | | |   |  _ \\| | | \\  /${re}"
    echo -e "${skyblue}   \\ V / |  __/ ___) |   | || |_| | |_| | |___| |_) | |_| /  \\ ${re}"
    echo -e "${skyblue}    \\_/  |_|   |____/    |_| \\___/ \\___/|_____|____/ \\___/_/\\_\\ ${re}"
    echo ""
    local title title_width pad banner_width=63
    title="${PROJECT_TITLE} v${PROJECT_VERSION}"
    title_width=$(printf '%s' "$title" | wc -L 2>/dev/null)
    [[ "$title_width" =~ ^[0-9]+$ ]] || title_width=${#title}
    pad=$(( (banner_width - title_width) / 2 ))
    [ "$pad" -lt 0 ] && pad=0
    printf '%*s' "$pad" ""
    echo -e "${yellow}${title}${re}"
    echo -e "${yellow}支持Ubuntu/Debian/CentOS/Alpine/Fedora/Rocky/Almalinux/Oracle-linux${re}"
    echo -e "${skyblue}快捷命令${yellow}${SHORTCUT_NAMES[*]}${skyblue}，下次运行输入${yellow}${SHORTCUT_NAMES[0]}${skyblue}可快速启动${re}"
    echo "-------------------------------------------------------------------"
    echo -e "${green} 1. 本机信息                   5. BBR管理 ${re}"
    echo -e "${green} 2. 系统更新                   6. Docker管理 ▶${re}"
    echo -e "${green} 3. 系统清理                   7. WARP管理 ▶解锁ChatGPT/Netflix${re}"
    echo -e "${green} 4. 组件管理 ▶${purple}                 8. LDNMP建站 ▶${re}"
    echo "-------------------------------------------------------------------"
    echo -e "${green} 9. 面板工具 ▶                13. 测试脚本合集 ▶${re}"
    echo -e "${green}10. 系统工具 ▶                14. 甲骨文云合集 ▶${re}"
    echo -e "${green}11. 我的工作区 ▶              15. 常用环境管理 ▶${re}"
    echo -e "${purple}12. 节点搭建合集 ▶            16. 开设NAT小鸡 ▶${re}"
    echo -e "${green}17. 基础工具 ▶${re}"
    echo -e "${green}18. 应用市场 ▶                19. 服务器集群 ▶${re}"
    echo -e "${green}20. 游戏开服 ▶${re}"
    echo "-------------------------------------------------------------------"
    echo -e "${green}00. 脚本更新${red}                  88. 退出脚本${re}"
    echo -e "${yellow}-------------------------------------------------------------------${re}"
}

main_loop() {
    while true; do
        show_main_menu
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' choice || exit 0

        case "$choice" in
            1)  menu_system_info ;;
            2)  menu_system_update ;;
            3)  menu_system_clean ;;
            4)  menu_component_manage ;;
            5)  menu_bbr ;;
            6)  menu_docker_manage ;;
            7)  menu_warp ;;
            8)  menu_ldnmp ;;
            9)  menu_panel_tools ;;
            10) menu_system_tools ;;
            11) menu_workspace ;;
            12) menu_node_build ;;
            13) menu_test_scripts ;;
            14) menu_oracle_cloud ;;
            15) menu_env_manage ;;
            16) menu_nat_vm ;;
            17) menu_basic_tools ;;
            18) menu_app_market ;;
            19) menu_cluster ;;
            20) menu_games ;;
            00) menu_update_self ;;
            88) clear; exit 0 ;;
            *)  echo -e "${purple}无效的输入!${re}" ;;
        esac
        break_end
    done
}

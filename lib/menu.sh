#!/usr/bin/env bash
# 主菜单展示与分支分派

show_main_menu() {
    clear
    if [ "${ENABLE_STATS:-0}" = "1" ]; then
        echo -e "    ${skyblue}当日运行：${yellow}${TODAY}次   ${skyblue}累计运行：${yellow}${TOTAL}次${re}"
    fi
    echo -e "\033[0;97m-----------------By'${PROJECT_AUTHOR}'-----------------\033[0m"
    if [ -n "${PROJECT_REPO_URL}" ]; then
        echo -e "\033[0;97m项目地址: ${PROJECT_REPO_URL}\033[0m"
    fi
    echo ""
    echo -e "${skyblue}  __     __  ____    ____     _____  ___   ___   ____    __ __ ${re}"
    echo -e "${skyblue}  \\ \\   / / |  _ \\  / ___|   |_   _|/ _ \\ / _ \\ |  _ \\  |  |  |${re}"
    echo -e "${skyblue}   \\ \\ / /  | |_) | \\___ \\     | | | | | | | | | | |_) | |  |  |${re}"
    echo -e "${skyblue}    \\ V /   |  __/   ___) |    | | | |_| | |_| | |  _ <  |  |  |${re}"
    echo -e "${skyblue}     \\_/    |_|     |____/     |_|  \\___/ \\___/  |_| \\_\\ |__|__|${re}"
    echo ""
    echo -e "                 ${yellow}${PROJECT_TITLE} v${PROJECT_VERSION}${re}"
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
    echo "-------------------------------------------------------------------"
    echo -e "${green}00. 脚本更新${red}                  88. 退出脚本${re}"
    echo -e "${yellow}-------------------------------------------------------------------${re}"
}

main_loop() {
    while true; do
        show_main_menu
        read -p $'\033[1;91m请输入你的选择: \033[0m' choice || exit 0

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
            00) menu_update_self ;;
            88) clear; exit 0 ;;
            *)  echo -e "${purple}无效的输入!${re}" ;;
        esac
        break_end
    done
}

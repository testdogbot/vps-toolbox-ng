#!/usr/bin/env bash
# vps-toolbox 模块：测试脚本合集
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_test_scripts() {
    if ! confirm_action "本菜单会下载并执行第三方 root 脚本，确认进入？"; then
        return 0
    fi
    while true; do
      clear
      echo -e "${purple}▶ 测试脚本合集${re}"
      echo ""
      echo -e "${green}----IP及解锁状态检测-------${re}"
      echo -e "${green} 1. ChatGPT解锁状态检测${re}"
      echo -e "${green} 2. Region流媒体解锁测试${re}"
      echo -e "${green} 3. yeahwu流媒体解锁检测${re}"
      echo -e "${green} 4. xykt_IP质量体检脚本${re}"
      echo ""
      echo -e "${skyblue}----网络线路测速-----------${re}"
      echo -e "${skyblue} 5. Superspeed三网测速${re}"
      echo -e "${skyblue} 6. nxtrace快速回程测试${re}"
      echo -e "${skyblue} 7. ludashi2020三网线路测试${re}"
      echo -e "${skyblue} 8. mtr_trace三网回程线路测试${re}"
      echo -e "${skyblue} 9. besttrace三网回程延迟路由测试${re}"
      echo ""
      echo -e "${green}----硬件性能测试-----------${re}"
      echo -e "${green}10. yabs性能测试${re}"
      echo -e "${green}11. icu/gb5 CPU性能测试脚本${re}"
      echo ""
      echo -e "${purple}----综合性测试-------------${re}"
      echo -e "${purple}12. bench性能测试${re}"
      echo -e "${purple}13. spiritysdx融合怪测评${re}"
      echo ""
      echo "---------------------------"
      echo -e "${skyblue} 0. 返回主菜单${re}"
      echo "---------------------------"
      read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice || exit 0
      case $sub_choice in
          1)
              clear
              bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
              ;;
          2)
              clear
              bash <(curl -L -s check.unlock.media)
              ;;
          3)
              clear
              install wget
              wget -qO- https://github.com/yeahwu/check/raw/main/check.sh | bash
              ;;
          4)
              clear
              bash <(curl -Ls IP.Check.Place)
              ;;
          5)
              clear
              bash <(curl -Lso- https://git.io/superspeed_uxh)
              ;;
          6)
              clear
              curl nxtrace.org/nt |bash
              nexttrace --fast-trace --tcp
              ;;
          7)
              clear
              curl https://raw.githubusercontent.com/ludashi2020/backtrace/main/install.sh -sSf | sh
              ;;
          8)
              clear
              curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh | bash
              ;;
          9)
              clear
              install wget
              wget -qO- git.io/besttrace | bash
              ;;
          10)
              clear
              curl -sL yabs.sh | bash -s -- -i -5
              ;;
          11)
              clear
              bash <(curl -sL bash.icu/gb5)
              ;;
          12)
              clear
              curl -Lso- bench.sh | bash
              ;;
          13)
              clear
              curl -L https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh && chmod +x ecs.sh && bash ecs.sh
              ;;
          0)
              main_menu
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
        break_end
    done
}

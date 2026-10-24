#!/usr/bin/env bash
# vps-toolbox 模块：甲骨文云合集
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_oracle_cloud() {
    if ! confirm_action "本菜单会下载并执行第三方 root 脚本，确认进入？"; then
        return 0
    fi
     while true; do
      clear
      echo -e "${green}▶ 甲骨文云脚本合集${re}"
      echo "------------------------"
      echo -e "${green}1. 一键闲置机器活跃${re}"
      echo -e "${green}2. 开启ROOT密码登录${re}"
      echo "------------------------"
      echo -e "${purple}3. 一键DD重装系统${re}"
      echo "------------------------"
      echo -e "${green}4. 安装R探长刷机${re}"
      echo -e "${red}5. 卸载R探长刷机${re}"
      echo "------------------------"
      echo -e "${skyblue}0. 返回主菜单${re}"
      echo "------------------------"
      read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice || exit 0

      case $sub_choice in
          1)
             clear
              curl -L https://gitlab.com/spiritysdx/Oracle-server-keep-alive-script/-/raw/main/oalive.sh -o oalive.sh && chmod +x oalive.sh && bash oalive.sh
            ;; 
          2)
              clear
              read -e -p $'\033[1;33m请设置你的root密码: \033[0m' pswd
              echo "root:$pswd" | chpasswd
              sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
              sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
              service sshd restart
              echo -e "${green}root登录设置完毕，请断开连接使用root+密码登录${re}"
            ;;  
          3)
          clear
          echo "请备份数据，将为你重装系统，预计花费15分钟。"
          read -e -p "确定继续吗？(Y/N): " choice

          case "$choice" in
            [Yy])
              while true; do
                read -e -p "请选择要重装的系统:  1. Debian12 | 2. Ubuntu20.04 : " sys_choice

                case "$sys_choice" in
                  1)
                    xitong="-d 12"
                    break  # 结束循环
                    ;;
                  2)
                    xitong="-u 20.04"
                    break  # 结束循环
                    ;;
                  *)
                    echo "无效的选择，请重新输入。"
                    ;;
                esac
              done

              read -e -p "请输入你重装后的密码: " vpspasswd
              install wget
              bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') $xitong -v 64 -p $vpspasswd -port 22
              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac
              ;;

          4)
              clear  
              echo -e "${purple}温馨提醒：自动抢机属于官方禁止行为，可能会造成封号现象，如因刷机造成封号，与本人无关！\n开始执行此任务前请确认以下3步是否操作完成。${re}"
              echo ""
              echo -e "${yellow}1：请确保你的服务器${purple}9527端口${yellow}可用，故此一键开机也不适合nat小鸡${re}"
              echo ""
              echo -e "${yellow}2：获取R探长机器人对应的${purple}username和password，${yellow}机器人获取链接https://t.me/radiance_helper_bot，使用/raninfo命令随机生成${re}"
              echo ""
              echo -e "${yellow}3：获取甲骨文云${purple}api密钥${yellow}下载文件并复制内容保存，获取方式在甲骨文云控制台右上角头像--我的概要信息里${re}"
              echo ""
              read -e -p $'\033[1;91m确定要继续吗？[y/n]: \033[0m' confirm
              echo ""

                if [[ $confirm =~ ^[Yy]$ ]]; then
                    echo -e "${yellow}开安装依赖...${re}"
                    install iptables wget nano
                    install_java
                    iptables -A INPUT -p tcp --dport 9527 -j ACCEPT
                    mkdir -p rtbot && cd rtbot
                    # 下载、解压、设置权限并后台运行 sh_client_bot.sh
                    wget -O sh_client_bot.sh https://github.com/semicons/java_oci_manage/releases/latest/download/sh_client_bot.sh && chmod +x sh_client_bot.sh && bash sh_client_bot.sh
                    clear 

                    while true; do
                        pid_tail=$(ps aux | grep '[t]ail' | awk '{print $2}')
                        pid_java=$(ps aux | grep '[j]ava' | grep -v 'grep' | awk '{print $2}')

                        tail_running=true
                        java_running=true

                        if [ ! -z "$pid_tail" ]; then
                            kill $pid_tail
                            echo -e "${green}已结束PID为${pid_tail}的tail进程。${re}"
                            tail_running=false
                        fi

                        if [ ! -z "$pid_java" ]; then
                            kill $pid_java
                            echo -e "${green}已结束PID为${pid_java}的java进程。${re}"
                            java_running=false
                        fi

                        if [ "$tail_running" = false ] && [ "$java_running" = false ]; then
                            break
                        fi

                        sleep 5
                    done
                    sleep 2
                    clear
                    echo ""
                    echo -e "${red}等待完成以下步骤,请完成后再确认${re}"
                    echo ""
                    echo -e "${yellow}1：获取R探长机器人对应的${purple}username和password，${yellow}机器人获取链接https://t.me/radiance_helper_bot${re}"
                    echo ""
                    echo -e "${yellow}2：获取甲骨文云${purple}api密钥下载文件并复制内容保存，${yellow}获取方式在甲骨文云控制台右上角头像--我的概要信息里${re}"
                    echo ""
                    echo -e "${yellow}3：将甲骨文云api密钥文件上传至root目录内，并复制文件路径保存，api密钥最后一行的路径改为此路径${re}"
                    echo ""                    
                    read -e -p $'\033[1;91m是否已完成以上步骤？[y/n]: \033[0m' confirm
                        sleep 1
                        if [[ $confirm =~ ^[Yy]$ ]]; then
                            # 使用 nano 编辑器打开文件
                            chmod +x /root/rtbot/client_config
                            echo ""
                            echo -e "${purple}即将打开/root/rtbot/client_config配置文件进行编辑。${re}"
                            echo ""
                            echo -e "${purple}键盘上下键定位，将api密钥(注意最后一行的路径)，username，password粘贴到指定位置${re}"
                            echo ""
                            echo -e "${purple}编辑完成后，请按顺序输入命令(Ctrl+O, Enter, Ctrl+X)保存退出${re}"
                            sleep 2
                            echo ""
                            read -e -p $'\033[1;91m是否清楚以上步骤？[y/n]: \033[0m' confirm

                            if [[ $confirm =~ ^[Yy]$ ]]; then
                                sleep 1
                                nano "/root/rtbot/client_config"
                                echo -e "${green}client_config配置更新成功。${re}"
                                sleep 1
                                echo -e "${green}开始执行抢机...${re}"
                                bash sh_client_bot.sh
                                sleep  3
                                echo -e "${green}正在后台执行抢机中，可关闭SSH，开机成功会在R探长bot上提醒...${re}"
                                sleep  3
                                main_menu
                            else 
                                echo -e "${yellow}请重新执行，正在退出...${re}"
                                sleep 1
                                rm -rf /root/rtbot
                                main_menu
                            fi
                        else 
                            echo -e "${yellow}已取消操作，正在退出...${re}"
                            rm -rf /root/rtbot
                            sleep 2
                            main_menu

                        fi
                else 
                    echo -e "${yellow}已取消操作，正在退出...${re}"
                    sleep 2
                    main_menu
                fi
              ;;

          5)
              clear
              ps -ef | grep r_client.jar | grep -v grep | awk '{print $2}' | xargs kill -9
              rm -rf /root/rtbot
              echo -e "${green}卸载完毕...${re}"
              break_end
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

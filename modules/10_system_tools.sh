#!/usr/bin/env bash
# vps-toolbox 模块：系统工具
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_system_tools() {
    while true; do
      clear
      echo "▶ 系统工具"
      echo "------------------------"
      echo " 1. 设置脚本启动快捷键"
      echo "------------------------"
      echo " 2. 修改ROOT密码                   9. 禁用ROOT账户创建新账户"
      echo " 3. 开启ROOT密码登录              10. 切换优先ipv4/ipv6"
      echo " 4. 禁用修改ROOT密码              11. 查看端口占用状态"
      echo " 5. 开放所有端口                  12. 修改虚拟内存大小"
      echo " 6. 修改SSH连接端口               13. 用户/密码生成器"
      echo " 7. 优化DNS地址                   14. 用户管理"
      echo -e "${skyblue} 8. 一键重装系统                  15. NAT小鸡一键重装系统${re} "
      echo -e "${yellow}--------------------------------------------------------${re}"
      echo "16. 开启BBR3加速                  23. 系统时区调整"
      echo "17. 防火墙高级管理器              24. iptables一键转发"
      echo "18. 修改主机名                    25. NAT批量SSH连接测试"
      echo "19. 切换系统更新源"
      echo "20. 定时任务管理"
      echo "21. ip开放端口扫描"
      echo "22. 服务器资源限制"
      echo "------------------------"
      echo "80. 留言板"
      echo "------------------------"
      echo "99. 重启服务器"
      echo "------------------------"
      echo -e "${skyblue} 0. 返回主菜单${re}"
      echo "------------------------"
      read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

      case $sub_choice in
          1)
              clear
              read -e -p $'\033[1;91m请输入你需要设置的快捷按键: \033[0m' kuaijiejian              
                [ -z "$kuaijiejian" ] && echo -e "${red}你似乎什么也没输入${re}" && main_menu || kuaijiejian_value="$kuaijiejian"
    
                # 检查输入是否为单个字母
                if [[ ! "$kuaijiejian_value" =~ ^[a-zA-Z]$ ]]; then
                    echo -e "${red}请输入单个大写或小写字母${re}"
                else
                    # 将输入转换为大写和小写
                    uppercase_value=$(echo "$kuaijiejian_value" | tr '[:lower:]' '[:upper:]')
                    lowercase_value=$(echo "$kuaijiejian_value" | tr '[:upper:]' '[:lower:]')
                    
                    # 软连接目标脚本
                    script_path="/usr/local/bin/${PROJECT_NAME}.sh"
                    
                    # 确保目标脚本存在且有执行权限
                    if [ ! -f "$script_path" ]; then
                        echo -e "${red}目标脚本不存在，请先安装脚本${re}"
                    else
                        # 删除可能存在的同名软连接
                        rm -f "/usr/local/bin/$uppercase_value" 2>/dev/null
                        rm -f "/usr/local/bin/$lowercase_value" 2>/dev/null
                        
                        # 创建大写和小写的软连接
                        ln -sf "$script_path" "/usr/local/bin/$uppercase_value"
                        ln -sf "$script_path" "/usr/local/bin/$lowercase_value"
                        hash -r >/dev/null 2>&1
                        echo -e "${green}快捷键已设置为：$uppercase_value 和 $lowercase_value${re}"
                    fi
                fi
              ;;

          2)
              clear
               read -e -p $'\033[1;35m请输入新的ROOT密码: \033[0m' passwd
               echo "root:$passwd" | chpasswd && echo -e "\033[1;32mRoot密码修改成功. 正在重启服务器...\033[0m" && sleep 1 && reboot || echo -e "\033[1;91mRoot密码修改失败\033[0m"
              ;;
          3)
              clear
              read -e -p $'\033[1;35m请设置你的root密码: \033[0m' passwd
              echo "root:$passwd" | chpasswd && echo "Root密码设置成功" || echo "Root密码修改失败"
              sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
              sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
              sed -i 's|^Include /etc/ssh/sshd_config.d/\*.conf|#&|' /etc/ssh/sshd_config;
              service sshd restart
              echo -e "${green}ROOT登录设置完毕，重启服务器生效${re}"
              read -e -p $'\033[1;35m需要立即重启服务器吗？(y/n): \033[0m' choice
          case "$choice" in
            [Yy])
              reboot
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
                chattr +i /etc/passwd
                chattr +i /etc/shadow
                echo -e "${yellow}已禁用修改ROOT密码${re}"
              ;;

          5)
              clear
              iptables_open
              remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1
              echo -e "${green}端口已全部开放${re}"

              ;;
          6)
              clear
              #!/bin/bash

              # 去掉 #Port 的注释
              sed -i 's/#Port/Port/' /etc/ssh/sshd_config

              # 读取当前的 SSH 端口号
              current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

              # 打印当前的 SSH 端口号
              echo "当前的 SSH 端口号是: $current_port"

              echo "------------------------"

              # 提示用户输入新的 SSH 端口号
              read -e -p $'\033[1;35m请输入新的 SSH 端口号: \033[0m' new_port

              # 备份 SSH 配置文件
              cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

              # 替换 SSH 配置文件中的端口号
              sed -i "s/Port [0-9]\+/Port $new_port/g" /etc/ssh/sshd_config

              # 重启 SSH 服务
              service sshd restart

              echo "SSH 端口已修改为: $new_port"

              clear
              iptables_open
              remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1

              ;;


          7)
            clear
            echo "当前DNS地址"
            echo "------------------------"
            cat /etc/resolv.conf
            echo "------------------------"
            echo ""
            # 询问用户是否要优化DNS设置
            read -e -p $'\033[1;35m是否要设置为Cloudflare和Google的DNS地址？(y/n): \033[0m' choice

            if [ "$choice" == "y" ]; then
                # 定义DNS地址
                cloudflare_ipv4="1.1.1.1"
                google_ipv4="8.8.8.8"
                cloudflare_ipv6="2606:4700:4700::1111"
                google_ipv6="2001:4860:4860::8888"

                # 检查机器是否有IPv6地址
                ipv6_available=0
                if [[ $(ip -6 addr | grep -c "inet6") -gt 0 ]]; then
                    ipv6_available=1
                fi

                # 设置DNS地址为Cloudflare和Google（IPv4和IPv6）
                echo "设置DNS为Cloudflare和Google"

                # 设置IPv4地址
                echo "nameserver $cloudflare_ipv4" > /etc/resolv.conf
                echo "nameserver $google_ipv4" >> /etc/resolv.conf

                # 如果有IPv6地址，则设置IPv6地址
                if [[ $ipv6_available -eq 1 ]]; then
                    echo "nameserver $cloudflare_ipv6" >> /etc/resolv.conf
                    echo "nameserver $google_ipv6" >> /etc/resolv.conf
                fi

                echo "DNS地址已更新"
                echo "------------------------"
                cat /etc/resolv.conf
                echo "------------------------"
            else
                echo "DNS设置未更改"
            fi

              ;;

          8)
            clear

            restart_system() {
                read -e -p $'\033[1;35m是否立即重启系统继续完成安装？(y/n): \033[0m' restart_choice
                echo -e "${green}重启系统几分钟后即可连接SSH${re}"
                if [[ $restart_choice =~ ^[Yy]$ ]]; then
                    reboot
                else 
                    echo -e "${green}请手动重启系统继续完成安装${re}"
                    sleep 2
                    main_menu
                fi
            }

            echo -e "${purple}重装系统将无法恢复数据，请提前做好备份${re}"
            echo ""
            read -e -p $'\033[1;35m确定要重装吗？(y/n): \033[0m' confirm

            if [[ $confirm =~ ^[Yy]$ ]]; then
                    sleep 1
                    echo -e "${yellow}初始化安装环境...${re}"
                    install wget
                    wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh
                    sleep 1
                while true; do
                    echo ""
                    echo -e "${purple}请保存你的root密码，安装后使用该密码登录，登录成功后自行修改${re}"
                    echo -e "${yellow}Linux默认用户名：${purple}root${yellow} 默认密码：${purple}LeitboGi0ro${yellow} 默认ssh端口22${re}"
                    echo -e "${yellow}Windows默认用户名：${purple}Administrator${yellow} 默认密码：${purple}Teddysun.com${yellow} 默认远程连接端口${purple}3389${re}"
                    echo -e "${yellow}详细参数参考Github项目地址：https://github.com/leitbogioro/Tools${re}"
                    echo ""
                    echo -e "${green} 1.安装Debian-12            2.安装Debian-13${re}"
                    echo -e "${green} 3.安装Ubuntu-22.04         4.安装Ubuntu-24.04${re}"
                    echo -e "${green} 5.安装Alpine-3.19          6.安装Alpine-3.20${re}"
                    echo -e "${green} 7.安装Centos-8             8.安装Centos-9${re}"
                    echo -e "${green} 9.安装Fedora-39           10.安装RockyLinux-9${re}"
                    echo -e "${green}11.安装AlmaLinux-9         12.安装Kali-Rolling${re}"
                    echo -e "${green}13.安装Windows-10          14.安装Windows-11${re}"
                    echo "-----------------------------------------------"
                    echo -e "${red}0.取消安装${re}"
                    echo "---------------------"
                    read -e -p $'\033[1;35m请输入你的选择: \033[0m' sub_choice
                   
                    case $sub_choice in
                        1) 
                            echo -e "${green}开始为你安装Debian-12${re}"
                            sleep 1
                            bash InstallNET.sh -debian 12
                            sleep 2
                            clear
                            restart_system
                            ;;
                        2) 
                            echo -e "${green}开始为你安装Debian-13${re}"
                            sleep 1
                            bash InstallNET.sh -debian 13
                            sleep 2
                            clear
                            restart_system
                            ;;
                        3) 
                            echo -e "${green}开始为你安装Ubuntu-22.04${re}"
                            sleep 1
                            bash InstallNET.sh -ubuntu 22.04
                            sleep 2
                            clear
                            restart_system
                            ;;
                        4) 
                            echo -e "${green}开始为你安装Ubuntu-24.04${re}"
                            sleep 1
                            bash InstallNET.sh -ubuntu 24.04
                            sleep 2
                            clear
                            restart_system
                            ;;
                        5) 
                            echo -e "${green}开始为你安装Alpine-3.19${re}"
                            sleep 1
                            bash InstallNET.sh -alpine 3.19
                            sleep 2
                            clear
                            restart_system
                            ;;
                        6) 
                            echo -e "${green}开始为你安装Alpine-3.20${re}"
                            sleep 1
                            bash InstallNET.sh -alpine
                            sleep 2
                            clear
                            restart_system
                            ;;
                        7) 
                            echo -e "${green}开始为你安装Centos-8${re}"
                            sleep 1
                            bash InstallNET.sh -centos 8
                            sleep 2
                            clear
                            restart_system
                            ;;
                        8) 
                            echo -e "${green}开始为你安装Centos-9${re}"
                            sleep 1
                            bash InstallNET.sh -centos 9
                            sleep 2
                            clear
                            restart_system
                            ;;
                        9) 
                            echo -e "${green}开始为你安装Fedora-39${re}"
                            sleep 1
                            bash InstallNET.sh -fedora
                            sleep 2
                            clear
                            restart_system
                            ;;
                        10) 
                            echo -e "${green}开始为你安装RockyLinux-9${re}"
                            sleep 1
                            bash InstallNET.sh -rockylinux
                            sleep 2
                            clear
                            restart_system
                            ;;
                        11) 
                            echo -e "${green}开始为你安装AlmaLinux-9${re}"
                            sleep 1
                            bash InstallNET.sh -almaLinux
                            sleep 2
                            clear
                            restart_system
                            ;;
                        12) 
                            echo -e "${green}开始为你安装Kali-Rolling${re}"
                            sleep 1
                            bash InstallNET.sh -kali
                            sleep 2
                            clear
                            restart_system
                            ;;
                        13) 
                            echo -e "${green}开始为你安装Windows-10${re}"
                            sleep 1
                            bash InstallNET.sh -windows 10 -lang "cn"
                            sleep 2
                            clear
                            restart_system
                            ;;
                        14) 
                            echo -e "${green}开始为你安装Windows-11${re}"
                            sleep 1
                            bash InstallNET.sh -windows 11 -lang "cn"
                            sleep 2
                            clear
                            restart_system
                            ;;
                        0) 
                            echo -e "${red}正在退出安装...${re}"
                            rm InstallNET.sh
                            sleep 1
                            main_menu
                            ;;
                        *)
                            echo -e "${red}输入错误，请重新输入${re}"
                            ;;
                    esac
                done
            else 
                main_menu
            fi
            ;;

          9)
            clear
            install sudo

            # 提示用户输入新用户名
            read -e -p "请输入新用户名: " new_username

            # 创建新用户并设置密码
            sudo useradd -m -s /bin/bash "$new_username"
            sudo passwd "$new_username"

            # 赋予新用户sudo权限
            echo "$new_username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers

            # 禁用ROOT用户登录
            sudo passwd -l root

            echo "操作已完成。"
            ;;


          10)
            clear
            GAI_CONF="/etc/gai.conf"

            echo ""
            if grep -qE '^\s*precedence\s+::ffff:0:0/96\s+100' "$GAI_CONF" 2>/dev/null; then
                echo "当前网络优先级设置: IPv4 优先"
            else
                echo "当前网络优先级设置: IPv6 优先"
            fi
            echo "------------------------"

            echo ""
            echo "切换的网络优先级"
            echo "------------------------"
            echo "1. IPv4 优先          2. IPv6 优先      3. 禁用 IPv6"
            echo "------------------------"
            read -e -p "选择优先的网络: " choice

            case $choice in
                1)
                    [ ! -f "${GAI_CONF}.bak" ] && cp "$GAI_CONF" "${GAI_CONF}.bak" 2>/dev/null
                    [ ! -f "$GAI_CONF" ] && touch "$GAI_CONF"
                    sed -i '/^\s*precedence\s\+::ffff:0:0\/96/d' "$GAI_CONF"
                    echo "precedence ::ffff:0:0/96  100" >> "$GAI_CONF"
                    
                    # 检查IPv6是否禁用
                    v6_disabled=$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)
                    if [ "$v6_disabled" -eq 1 ]; then
                        echo -e "\n${yellow}IPv6 已禁用，是否需要开启？[Y/N]${re}"
                        read -e -p "是否需要开启？[Y/N]" choice
                        if [[ "$choice" =~ [Yy] ]]; then
                            sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
                            sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
                            sysctl -w net.ipv6.conf.lo.disable_ipv6=0 >/dev/null 2>&1

                            # 写入持久化
                            sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
                            sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
                            sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf

                            {
                                echo "net.ipv6.conf.all.disable_ipv6 = 0"
                                echo "net.ipv6.conf.default.disable_ipv6 = 0"
                                echo "net.ipv6.conf.lo.disable_ipv6 = 0"
                            } >> /etc/sysctl.conf

                            sysctl -p >/dev/null 2>&1
                        fi
                    fi
                    echo -e "\n${green}已切换为 IPv4 优先(IPv6 仍然可用，只是优先级降低)${re}\n"
                    ;;
                2)
                    [ ! -f "${GAI_CONF}.bak" ] && cp "$GAI_CONF" "${GAI_CONF}.bak" 2>/dev/null
                    [ ! -f "$GAI_CONF" ] && touch "$GAI_CONF"
                    # 移除 IPv4 优先规则即可恢复默认 IPv6 优先
                    sed -i '/^\s*precedence\s\+::ffff:0:0\/96/d' "$GAI_CONF"
                    sysctl -w net.ipv6.conf.all.disable_ipv6=0 > /dev/null 2>&1
                    echo -e "\n${green}已切换为 IPv6 优先(IPv4 仍然可用，只是优先级降低)${re}\n"
                    ;;
                3)
                    sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
                    sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
                    sysctl -w net.ipv6.conf.lo.disable_ipv6=1 >/dev/null 2>&1

                    sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
                    sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
                    sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf

                    {
                        echo "net.ipv6.conf.all.disable_ipv6 = 1"
                        echo "net.ipv6.conf.default.disable_ipv6 = 1"
                        echo "net.ipv6.conf.lo.disable_ipv6 = 1"
                    } >> /etc/sysctl.conf

                    sysctl -p >/dev/null 2>&1
                    # 同时移除 IPv4 优先规则（禁用 IPv6 后此规则无意义）
                    sed -i '/^\s*precedence\s\+::ffff:0:0\/96/d' "$GAI_CONF" 2>/dev/null
                    echo -e "\n${yellow}✓ IPv6 已在系统层禁用${re}\n"
                    ;;
                *)
                    echo "无效的选择"
                    ;;

            esac
            ;;

          11)
            clear
            ss -tulnape
            ;;

          12)

            if [ "$EUID" -ne 0 ]; then
              echo "请以 root 权限运行此脚本。"
              exit 1
            fi

            clear
            # 获取当前交换空间信息
            swap_used=$(free -m | awk 'NR==3{print $3}')
            swap_total=$(free -m | awk 'NR==3{print $2}')

            if [ "$swap_total" -eq 0 ]; then
              swap_percentage=0
            else
              swap_percentage=$((swap_used * 100 / swap_total))
            fi

            swap_info="${swap_used}MB/${swap_total}MB (${swap_percentage}%)"

            echo "当前虚拟内存: $swap_info"

            read -e -p "是否调整大小?(Y/N): " choice

            case "$choice" in
              [Yy])
                # 输入新的虚拟内存大小
                read -e -p "请输入虚拟内存大小MB: " new_swap

                # 获取当前系统中所有的 swap 分区
                swap_partitions=$(grep -E '^/dev/' /proc/swaps | awk '{print $1}')

                # 遍历并删除所有的 swap 分区
                for partition in $swap_partitions; do
                  swapoff "$partition"
                  wipefs -a "$partition"  # 清除文件系统标识符
                  mkswap -f "$partition"
                  echo "已删除并重新创建 swap 分区: $partition"
                done

                # 确保 /swapfile 不再被使用
                swapoff /swapfile

                # 删除旧的 /swapfile
                rm -f /swapfile

                # 创建新的 swap 分区
                dd if=/dev/zero of=/swapfile bs=1M count=$new_swap
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

                echo "虚拟内存大小已调整为${new_swap}MB"
                ;;
              [Nn])
                echo "已取消"
                ;;
              *)
                echo "无效的选择，请输入 Y 或 N。"
                ;;
            esac
            ;;

          13)
            clear

            echo "随机用户名"
            echo "------------------------"
            for i in {1..5}; do
                username="user$(< /dev/urandom tr -dc _a-z0-9 | head -c6)"
                echo "随机用户名 $i: $username"
            done

            echo ""
            echo "随机姓名"
            echo "------------------------"
            first_names=("John" "Jane" "Michael" "Emily" "David" "Sophia" "William" "Olivia" "James" "Emma" "Ava" "Liam" "Mia" "Noah" "Isabella")
            last_names=("Smith" "Johnson" "Brown" "Davis" "Wilson" "Miller" "Jones" "Garcia" "Martinez" "Williams" "Lee" "Gonzalez" "Rodriguez" "Hernandez")

            # 生成5个随机用户姓名
            for i in {1..5}; do
                first_name_index=$((RANDOM % ${#first_names[@]}))
                last_name_index=$((RANDOM % ${#last_names[@]}))
                user_name="${first_names[$first_name_index]} ${last_names[$last_name_index]}"
                echo "随机用户姓名 $i: $user_name"
            done

            echo ""
            echo "随机UUID"
            echo "------------------------"
            for i in {1..5}; do
                uuid=$(cat /proc/sys/kernel/random/uuid)
                echo "随机UUID $i: $uuid"
            done

            echo ""
            echo "16位随机密码"
            echo "------------------------"
            for i in {1..5}; do
                password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
                echo "随机密码 $i: $password"
            done

            echo ""
            echo "32位随机密码"
            echo "------------------------"
            for i in {1..5}; do
                password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
                echo "随机密码 $i: $password"
            done
            echo ""
            ;;

          14)
            clear
              while true; do
                clear
                install sudo
                clear
                # 显示所有用户、用户权限、用户组和是否在sudoers中
                echo "用户列表"
                echo "----------------------------------------------------------------------------"
                printf "%-24s %-34s %-20s %-10s\n" "用户名" "用户权限" "用户组" "sudo权限"
                while IFS=: read -r username _ userid groupid _ _ homedir shell; do
                    groups=$(groups "$username" | cut -d : -f 2)
                    sudo_status=$(sudo -n -lU "$username" 2>/dev/null | grep -q '(ALL : ALL)' && echo "Yes" || echo "No")
                    printf "%-20s %-30s %-20s %-10s\n" "$username" "$homedir" "$groups" "$sudo_status"
                done < /etc/passwd


                  echo ""
                  echo "账户操作"
                  echo "------------------------"
                  echo "1. 创建普通账户             2. 创建高级账户"
                  echo "------------------------"
                  echo "3. 赋予最高权限             4. 取消最高权限"
                  echo "------------------------"
                  echo "5. 删除账号"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                  case $sub_choice in
                      1)
                       # 提示用户输入新用户名
                       read -e -p "请输入新用户名: " new_username

                       # 创建新用户并设置密码
                       sudo useradd -m -s /bin/bash "$new_username"
                       sudo passwd "$new_username"

                       echo "操作已完成。"
                          ;;

                      2)
                       # 提示用户输入新用户名
                       read -e -p "请输入新用户名: " new_username

                       # 创建新用户并设置密码
                       sudo useradd -m -s /bin/bash "$new_username"
                       sudo passwd "$new_username"

                       # 赋予新用户sudo权限
                       echo "$new_username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers

                       echo "操作已完成。"

                          ;;
                      3)
                       read -e -p "请输入用户名: " username
                       # 赋予新用户sudo权限
                       echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
                          ;;
                      4)
                       read -e -p "请输入用户名: " username
                       # 从sudoers文件中移除用户的sudo权限
                       sudo sed -i "/^$username\sALL=(ALL:ALL)\sALL/d" /etc/sudoers

                          ;;
                      5)
                       read -e -p "请输入要删除的用户名: " username
                       # 删除用户及其主目录
                       sudo userdel -r "$username"
                          ;;

                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;

          15)
            clear
            echo -e "${green}重装系统将无法恢复数据，请提前做好备份${re}"
            echo ""
            read -e -p $'\033[1;35m确定要重装吗？(y/n): \033[0m' confirm

                if [[ $confirm =~ ^[Yy]$ ]]; then
                    sleep 1
                    curl -so OsMutation.sh https://raw.githubusercontent.com/LloydAsp/OsMutation/main/OsMutation.sh && chmod u+x OsMutation.sh && ./OsMutation.sh
                    break_end
                else 
                    main_menu
                fi
            ;;

          16)
          if dpkg -l | grep -q 'linux-xanmod'; then
            while true; do
                  clear
                  kernel_version=$(uname -r)
                  echo "您已安装xanmod的BBRv3内核"
                  echo "当前内核版本: $kernel_version"

                  echo ""
                  echo "内核管理"
                  echo "------------------------"
                  echo "1. 更新BBRv3内核              2. 卸载BBRv3内核"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                  case $sub_choice in
                      1)
                        apt update -y
                        apt upgrade -y
                        echo "XanMod内核已更新。重启后生效"
                        reboot

                          ;;
                      2)
                        apt purge -y 'linux-*xanmod1*'
                        update-grub
                        echo "XanMod内核已卸载。重启后生效"
                        reboot
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;

                  esac
            done
        else

          clear
          echo "请备份数据，将为你升级Linux内核开启BBR3"
          echo "官网介绍: https://xanmod.org/"
          echo "------------------------------------------------"
          echo "仅支持Debian/Ubuntu 仅支持x86_64架构"
          echo "VPS是512M内存的，请提前添加1G虚拟内存，防止因内存不足失联！"
          echo "------------------------------------------------"
          read -e -p "确定继续吗？(Y/N): " choice

          case "$choice" in
            [Yy])
            if [ -r /etc/os-release ]; then
                . /etc/os-release
                if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
                    echo "当前环境不支持，仅支持Debian和Ubuntu系统"
                    break
                fi
            else
                echo "无法确定操作系统类型"
                break
            fi

            # 检查系统架构
            arch=$(dpkg --print-architecture)
            if [ "$arch" != "amd64" ]; then
              echo "当前环境不支持，仅支持x86_64架构"
              break
            fi

            install wget gnupg

            # wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes
            wget -qO - https://raw.githubusercontent.com/kejilion/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

            # 步骤3：添加存储库
            echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

            # version=$(wget -q https://dl.xanmod.org/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')
            version=$(wget -q https://raw.githubusercontent.com/kejilion/sh/main/check_x86-64_psabi.sh && chmod +x check_x86-64_psabi.sh && ./check_x86-64_psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

            apt update -y
            apt install -y linux-xanmod-x64v$version

            # 步骤5：启用BBR3
            cat > /etc/sysctl.conf << EOF
net.core.default_qdisc=fq_pie
net.ipv4.tcp_congestion_control=bbr
EOF
            sysctl -p
            echo "XanMod内核安装并BBR3启用成功。重启后生效"
            rm -f /etc/apt/sources.list.d/xanmod-release.list
            rm -f check_x86-64_psabi.sh*
            reboot

              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac
        fi
              ;;

          17)
          if dpkg -l | grep -q iptables-persistent; then
            while true; do
                  clear
                  echo "防火墙已安装"
                  echo "------------------------"
                  iptables -L INPUT

                  echo ""
                  echo "防火墙管理"
                  echo "------------------------"
                  echo "1. 开放指定端口              2. 关闭指定端口"
                  echo "3. 开放所有端口              4. 关闭所有端口"
                  echo "------------------------"
                  echo "5. IP白名单                  6. IP黑名单"
                  echo "7. 清除指定IP"
                  echo "------------------------"
                  echo "9. 关闭并卸载防火墙"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                  case $sub_choice in
                      1)
                      read -e -p "请输入开放的端口号: " o_port
                      sed -i "/COMMIT/i -A INPUT -p tcp --dport $o_port -j ACCEPT" /etc/iptables/rules.v4
                      sed -i "/COMMIT/i -A INPUT -p udp --dport $o_port -j ACCEPT" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4

                          ;;
                      2)
                      read -e -p "请输入关闭的端口号: " c_port
                      sed -i "/--dport $c_port/d" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4
                        ;;

                      3)
                      current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

                      cat > /etc/iptables/rules.v4 << EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A FORWARD -i lo -j ACCEPT
-A INPUT -p tcp --dport $current_port -j ACCEPT
COMMIT
EOF
                      iptables-restore < /etc/iptables/rules.v4

                          ;;
                      4)
                      current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

                      cat > /etc/iptables/rules.v4 << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A FORWARD -i lo -j ACCEPT
-A INPUT -p tcp --dport $current_port -j ACCEPT
COMMIT
EOF
                      iptables-restore < /etc/iptables/rules.v4

                          ;;

                      5)
                      read -e -p "请输入放行的IP: " o_ip
                      sed -i "/COMMIT/i -A INPUT -s $o_ip -j ACCEPT" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4

                          ;;

                      6)
                      read -e -p "请输入封锁的IP: " c_ip
                      sed -i "/COMMIT/i -A INPUT -s $c_ip -j DROP" /etc/iptables/rules.v4
                      iptables-restore < /etc/iptables/rules.v4
                          ;;

                      7)
                     read -e -p "请输入清除的IP: " d_ip
                     sed -i "/-A INPUT -s $d_ip/d" /etc/iptables/rules.v4
                     iptables-restore < /etc/iptables/rules.v4
                          ;;

                      9)
                      sudo systemctl stop ufw.service && sudo systemctl disable ufw.service && (sudo ufw status | grep -q 'Status: inactive' && echo "UFW closed successfully" || echo "Failed to close UFW")
                      remove iptables-persistent
                      rm /etc/iptables/rules.v4
                      break
                      # echo "防火墙已卸载，重启生效"
                      # reboot
                          ;;

                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;

                  esac
            done
        else

          clear
          echo "将为你安装防火墙，该防火墙仅支持Debian/Ubuntu"
          echo "------------------------------------------------"
          read -e -p "确定继续吗？(Y/N): " choice

          case "$choice" in
            [Yy])
            if [ -r /etc/os-release ]; then
                . /etc/os-release
                if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
                    echo "当前环境不支持，仅支持Debian和Ubuntu系统"
                    break
                fi
            else
                echo "无法确定操作系统类型"
                break
            fi

          clear
          iptables_open
          remove iptables-persistent ufw
          rm /etc/iptables/rules.v4

          apt update -y && apt install -y iptables-persistent

          current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

          cat > /etc/iptables/rules.v4 << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A FORWARD -i lo -j ACCEPT
-A INPUT -p tcp --dport $current_port -j ACCEPT
COMMIT
EOF

          iptables-restore < /etc/iptables/rules.v4
          systemctl enable netfilter-persistent
          echo "防火墙安装完成"


              ;;
            [Nn])
              echo "已取消"
              ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
          esac
        fi
              ;;

          18)
            clear
            # 获取系统信息
            source /etc/os-release
            echo -e "${yellow}当前系统: ${red}${PRETTY_NAME}${re}"
            current_hostname=$(hostname)
            read -e -p $'\033[1;35m确定要更改主机名？ (y/n): \033[0m' choice

            if [[ "$choice" =~ ^[Yy]$ ]]; then

                read -e -p $'\033[1;35m请输入新的主机名: \033[0m' new_hostname

                case $ID in
                    "alpine")
                        echo "$new_hostname" > /etc/hostname
                        echo "127.0.0.1 localhost $new_hostname" > /etc/hosts
                        ;;
                    "debian" | "ubuntu")
                        hostnamectl set-hostname "$new_hostname"
                        sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
                        ;;
                    "centos" | "fedora" | "rocky" | "amzn" | "almalinux")
                        hostnamectl set-hostname "$new_hostname"
                        ;;
                    *)
                        echo -e "${red}不支持的系统类型: ${ID}${re}"
                        sleep 3
                        main_menu
                        ;;
                esac

                echo -e $'\033[1;35m主机名已更改，重新连接ssh生效\033[0m'
                    sleep 2
                    main_menu
            else
                echo -e "${green}取消更改主机名。${re}"
                sleep 2
                main_menu
            fi

            ;;
            
          19)

          # 获取系统信息
          source /etc/os-release

          # 定义 Ubuntu 更新源
          aliyun_ubuntu_source="http://mirrors.aliyun.com/ubuntu/"
          official_ubuntu_source="http://archive.ubuntu.com/ubuntu/"
          initial_ubuntu_source=""

          # 定义 Debian 更新源
          aliyun_debian_source="http://mirrors.aliyun.com/debian/"
          official_debian_source="http://deb.debian.org/debian/"
          initial_debian_source=""

          # 定义 CentOS 更新源
          aliyun_centos_source="http://mirrors.aliyun.com/centos/"
          official_centos_source="http://mirror.centos.org/centos/"
          initial_centos_source=""

          # 获取当前更新源并设置初始源
          case "$ID" in
              ubuntu)
                  initial_ubuntu_source=$(grep -E '^deb ' /etc/apt/sources.list | head -n 1 | awk '{print $2}')
                  ;;
              debian)
                  initial_debian_source=$(grep -E '^deb ' /etc/apt/sources.list | head -n 1 | awk '{print $2}')
                  ;;
              centos)
                  initial_centos_source=$(awk -F= '/^baseurl=/ {print $2}' /etc/yum.repos.d/CentOS-Base.repo | head -n 1 | tr -d ' ')
                  ;;
              *)
                  echo "未知系统，无法执行切换源脚本"
                  exit 1
                  ;;
          esac

          # 备份当前源
          backup_sources() {
              case "$ID" in
                  ubuntu)
                      cp /etc/apt/sources.list /etc/apt/sources.list.bak
                      ;;
                  debian)
                      cp /etc/apt/sources.list /etc/apt/sources.list.bak
                      ;;
                  centos)
                      if [ ! -f /etc/yum.repos.d/CentOS-Base.repo.bak ]; then
                          cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
                      else
                          echo "备份已存在，无需重复备份"
                      fi
                      ;;
                  *)
                      echo "未知系统，无法执行备份操作"
                      exit 1
                      ;;
              esac
              echo "已备份当前更新源为 /etc/apt/sources.list.bak 或 /etc/yum.repos.d/CentOS-Base.repo.bak"
          }

          # 还原初始更新源
          restore_initial_source() {
              case "$ID" in
                  ubuntu)
                      cp /etc/apt/sources.list.bak /etc/apt/sources.list
                      ;;
                  debian)
                      cp /etc/apt/sources.list.bak /etc/apt/sources.list
                      ;;
                  centos)
                      cp /etc/yum.repos.d/CentOS-Base.repo.bak /etc/yum.repos.d/CentOS-Base.repo
                      ;;
                  *)
                      echo "未知系统，无法执行还原操作"
                      exit 1
                      ;;
              esac
              echo "已还原初始更新源"
          }

          # 函数：切换更新源
          switch_source() {
              case "$ID" in
                  ubuntu)
                      sed -i 's|'"$initial_ubuntu_source"'|'"$1"'|g' /etc/apt/sources.list
                      ;;
                  debian)
                      sed -i 's|'"$initial_debian_source"'|'"$1"'|g' /etc/apt/sources.list
                      ;;
                  centos)
                      sed -i "s|^baseurl=.*$|baseurl=$1|g" /etc/yum.repos.d/CentOS-Base.repo
                      ;;
                  *)
                      echo "未知系统，无法执行切换操作"
                      exit 1
                      ;;
              esac
          }

          # 主菜单
          while true; do
              clear
              case "$ID" in
                  ubuntu)
                      echo "Ubuntu 更新源切换脚本"
                      echo "------------------------"
                      ;;
                  debian)
                      echo "Debian 更新源切换脚本"
                      echo "------------------------"
                      ;;
                  centos)
                      echo "CentOS 更新源切换脚本"
                      echo "------------------------"
                      ;;
                  *)
                      echo "未知系统，无法执行脚本"
                      exit 1
                      ;;
              esac

              echo "1. 切换到阿里云源"
              echo "2. 切换到官方源"
              echo "------------------------"
              echo "3. 备份当前更新源"
              echo "4. 还原初始更新源"
              echo -e "${green}5. 国内软件源列表(推荐)${re}"
              echo -e "${green}6. 国外软件源列表(推荐)${re}"
              echo "------------------------"
              echo "0. 返回上一级"
              echo "------------------------"
              read -e -p "请选择操作: " choice

              case $choice in
                  1)
                      backup_sources
                      case "$ID" in
                          ubuntu)
                              switch_source $aliyun_ubuntu_source
                              ;;
                          debian)
                              switch_source $aliyun_debian_source
                              ;;
                          centos)
                              switch_source $aliyun_centos_source
                              ;;
                          *)
                              echo "未知系统，无法执行切换操作"
                              exit 1
                              ;;
                      esac
                      echo "已切换到阿里云源"
                      ;;
                  2)
                      backup_sources
                      case "$ID" in
                          ubuntu)
                              switch_source $official_ubuntu_source
                              ;;
                          debian)
                              switch_source $official_debian_source
                              ;;
                          centos)
                              switch_source $official_centos_source
                              ;;
                          *)
                              echo "未知系统，无法执行切换操作"
                              exit 1
                              ;;
                      esac
                      echo "已切换到官方源"
                      ;;
                  3)
                      backup_sources
                      case "$ID" in
                          ubuntu)
                              switch_source $initial_ubuntu_source
                              ;;
                          debian)
                              switch_source $initial_debian_source
                              ;;
                          centos)
                              switch_source $initial_centos_source
                              ;;
                          *)
                              echo "未知系统，无法执行切换操作"
                              exit 1
                              ;;
                      esac
                      echo "已切换到初始更新源"
                      ;;
                  4)
                      restore_initial_source
                      ;;
                  5)
                      clear
                      bash <(curl -sSL https://raw.githubusercontent.com/SuperManito/LinuxMirrors/main/ChangeMirrors.sh)
                      break_end
                      ;;     
                  6)
                      clear
                      bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad
                      break_end
                      ;;                 
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入"
                      ;;
              esac
              break_end

          done

              ;;

          20)

              while true; do
                  clear
                  echo "定时任务列表"
                  crontab -l
                  echo ""
                  echo "操作"
                  echo "------------------------"
                  echo "1. 添加定时任务              2. 删除定时任务"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                  case $sub_choice in
                      1)
                          read -e -p "请输入新任务的执行命令: " newquest
                          echo "------------------------"
                          echo "1. 每周任务                 2. 每天任务"
                          read -e -p $'\033[1;91m请输入你的选择: \033[0m' dingshi

                          case $dingshi in
                              1)
                                  read -e -p "选择周几执行任务？ (0-6，0代表星期日): " weekday
                                  (crontab -l ; echo "0 0 * * $weekday $newquest") | crontab - > /dev/null 2>&1
                                  ;;
                              2)
                                  read -e -p "选择每天几点执行任务？（小时，0-23）: " hour
                                  (crontab -l ; echo "0 $hour * * * $newquest") | crontab - > /dev/null 2>&1
                                  ;;
                              *)
                                  break  # 跳出
                                  ;;
                          esac
                          ;;
                      2)
                          read -e -p "请输入需要删除任务的关键字: " kquest
                          crontab -l | grep -v "$kquest" | crontab -
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done

              ;;

          21)

            while true; do
                clear
                echo "ip端口扫描"
                echo "------------------------"
                echo "1. ipv4"
                echo "2. ipv6"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice   

                case $sub_choice in
                    1)
                        clear
                        # 检查是否已安装 nmap
                        if command -v nmap &> /dev/null; then
                            # nmap 已安装
                            echo -e "${green}nmap已存在，无需安装${re}"
                            while true; do
                                read -e -p "请输入你想要扫描的ipv4: " ip4
                                if [[ $ip4 =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
                                    break
                                else
                                    echo -e "${red}无效的IPv4地址，请重新输入${re}"
                                fi
                            done
                            sleep 1
                            echo -e "${green}开始扫描${ip4}开放的端口，请稍等...${re}"
                            nmap -sS -p 1-65535 $ip4
                            echo -e "${green}${ip4}端口已扫描完${re}"

                        else
                            # nmap 未安装，使用相应的包管理工具进行安装
                            echo -e "${yellow}nmap不存在. 开始安装nmap...${re}"
                            install "nmap"
                            sleep 1
                            clear
                            while true; do
                                read -e -p "请输入你想要扫描的ipv4: " ip4
                                if [[ $ip4 =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
                                    break
                                else
                                    echo -e "${red}无效的IPv4地址，请重新输入${re}"
                                fi
                            done
                            sleep 1
                            echo -e "${green}开始扫描${ip4}开放的端口，请稍等...${re}"
                            nmap -sS -p 1-65535 $ip4
                            echo -e "${green}${ip4}端口已扫描完${re}"

                        fi
                            break_end

                        ;;
                    
                    2)
                        clear
                        # 检查是否已安装 nmap
                        if command -v nmap &> /dev/null; then
                            # nmap 已安装
                            echo -e "${green}nmap已存在，无需安装${re}"
                            while true; do
                                read -e -p "请输入你想要扫描的ipv6: " ip6
                                if [[ $ip6 =~ ^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^::([0-9a-fA-F]{1,4}:){0,5}[0-9a-fA-F]{1,4}$|^([0-9a-fA-F]{1,4}:){1,6}:$|^([0-9a-fA-F]{1,4}:){1,6}::([0-9a-fA-F]{1,4}:){0,4}[0-9a-fA-F]{1,4}$ ]]; then
                                    break
                                else
                                    echo -e "${red}无效的IPv6地址，请重新输入${re}"
                                fi
                            done
                            sleep 1
                            echo -e "${green}开始扫描${ip6}开放的端口，请稍等...${re}"
                            nmap -6 -sS -p 1-65535 $ip6
                            echo -e "${green}${ip6}端口已扫描完${re}"

                        else
                            # nmap 未安装，使用相应的包管理工具进行安装
                            echo -e "${yellow}nmap不存在. 开始安装nmap...${re}"
                            install "nmap"
                            sleep 1
                            while true; do
                                read -e -p "请输入你想要扫描的ipv6: " ip6
                                if [[ $ip6 =~ ^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^::([0-9a-fA-F]{1,4}:){0,5}[0-9a-fA-F]{1,4}$|^([0-9a-fA-F]{1,4}:){1,6}:$|^([0-9a-fA-F]{1,4}:){1,6}::([0-9a-fA-F]{1,4}:){0,4}[0-9a-fA-F]{1,4}$ ]]; then
                                    break
                                else
                                    echo -e "${red}无效的IPv6地址，请重新输入${re}"
                                fi
                            done
                            sleep 1
                            echo -e "${green}开始扫描${ip6}开放的端口，请稍等...${re}"
                            nmap -6 -sS -p 1-65535 $ip6
                            echo -e "${green}${ip6}端口已扫描完${re}"

                        fi
                            break_end
                        ;;
                    0)
                        break  # 跳出循环，退出菜单
                    ;;

                    *)
                        break  # 跳出循环，退出菜单
                    ;; 
                esac
            done
            ;;

          22)
            # 检查依赖包
            check_packages() {
                install net-tools bc sysstat
            }
            check_packages
            
            while true; do
                clear
                echo -e "${yellow}服务器资源控制${re}"
                echo "------------------------"
                echo -e "${yellow}当CPU或内存或流量达到设置的阈值将采取关机操作${re}"
                echo "------------------------"
                echo "1. 一键限制CPU，当CPU达到99%自动关机"
                echo "2. 一键限制内存，内存达到99%自动关机"
                echo "3. 一键限制流量1T，流量达到1T自动关机"
                echo "4. CPU99%、内存99%、流量5T统一限制"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice   

                case $sub_choice in
                    1)
                        if [ -f "${VPS_TOOLBOX_ROOT}/scripts/check_cpu.sh" ]; then cp "${VPS_TOOLBOX_ROOT}/scripts/check_cpu.sh" /root/check_cpu.sh && chmod +x /root/check_cpu.sh && bash /root/check_cpu.sh; else curl https://raw.githubusercontent.com/eooce/ssh_tool/main/check_cpu.sh -o check_cpu.sh && chmod +x check_cpu.sh && bash check_cpu.sh; fi

                        # 添加Cron任务
                        (crontab -l 2>/dev/null; echo "*/10 * * * * /bin/bash /root/check_cpu.sh >> /root/check_cpu.log 2>&1") | crontab -
                        echo -e "${green}Cron任务已添加${re}"
                        break_end
                    ;;
                    2)
                        if [ -f "${VPS_TOOLBOX_ROOT}/scripts/check_memory.sh" ]; then cp "${VPS_TOOLBOX_ROOT}/scripts/check_memory.sh" /root/check_memory.sh && chmod +x /root/check_memory.sh && bash /root/check_memory.sh; else curl https://raw.githubusercontent.com/eooce/ssh_tool/main/check_memory.sh -o check_memory.sh && chmod +x check_memory.sh && bash check_memory.sh; fi

                        # 添加Cron任务
                        (crontab -l 2>/dev/null; echo "*/10 * * * * /bin/bash /root/check_memory.sh >> /root/check_cpu.log 2>&1") | crontab -
                        echo -e "${green}Cron任务已添加${re}"
                        break_end                         
                    ;;
                    3)
                        if [ -f "${VPS_TOOLBOX_ROOT}/scripts/check_traffic.sh" ]; then cp "${VPS_TOOLBOX_ROOT}/scripts/check_traffic.sh" /root/check_traffic.sh && chmod +x /root/check_traffic.sh && bash /root/check_traffic.sh; else curl https://raw.githubusercontent.com/eooce/ssh_tool/main/check_traffic.sh -o check_traffic.sh && chmod +x check_traffic.sh && bash check_traffic.sh; fi

                        # 添加Cron任务
                        (crontab -l 2>/dev/null; echo "*/10 * * * * /bin/bash /root/check_traffic.sh >> /root/check_traffic.log 2>&1") | crontab -
                        echo -e "${green}Cron任务已添加${re}"
                        break_end                         
                    ;;
                    4)
                        if [ -f "${VPS_TOOLBOX_ROOT}/scripts/check.sh" ]; then cp "${VPS_TOOLBOX_ROOT}/scripts/check.sh" /root/check.sh && chmod +x /root/check.sh && bash /root/check.sh; else curl https://raw.githubusercontent.com/eooce/ssh_tool/main/check.sh -o check.sh && chmod +x check.sh && bash check.sh; fi

                        # 添加Cron任务
                        (crontab -l 2>/dev/null; echo "*/10 * * * * /bin/bash /root/check.sh >> /root/check.log 2>&1") | crontab -
                        echo -e "${green}Cron任务已添加${re}"
                        break_end                         
                    ;;

                    0)
                        break  # 跳出循环，退出菜单
                    ;;

                    *)
                        break  # 跳出循环，退出菜单
                    ;; 
                esac
            done
            ;;

          23)
            while true; do
                clear
                # 获取当前系统时区
                if [ -f /etc/alpine-release ]; then
                    if [ ! -f /etc/timezone ]; then
                        apk add --no-cache tzdata
                        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
                        echo "Asia/Shanghai" > /etc/timezone
                        current_timezone=$(cat /etc/timezone)
                    else
                        current_timezone=$(cat /etc/timezone)
                    fi
                else
                    current_timezone=$(timedatectl show --property=Timezone --value)
                fi
                clear
                echo -e "${green}系统时间信息${re}"
                echo ""
                # 获取当前系统时间
                current_time=$(date +"%Y-%m-%d %H:%M:%S")

                # 显示时区和时间
                echo -e "${purple}当前系统时区：${re}${yellow}${current_timezone}${re}"
                echo -e "${purple}当前系统时间：${re}${yellow}${current_time}${re}"

                echo ""
                echo "时区切换"
                echo "亚洲------------------------"
                echo " 1. 中国上海时间              2. 中国香港时间"
                echo " 3. 日本东京时间              4. 韩国首尔时间"
                echo " 5. 新加坡时间                6. 印度加尔各答时间"
                echo " 7. 阿联酋迪拜时间            8. 澳大利亚悉尼时间"
                echo "欧洲------------------------"
                echo "11. 英国伦敦时间             12. 法国巴黎时间"
                echo "13. 德国柏林时间             14. 俄罗斯莫斯科时间"
                echo "15. 荷兰尤特赖赫特时间       16. 西班牙马德里时间"
                echo "美洲------------------------"
                echo "21. 美国西部时间             22. 美国东部时间"
                echo "23. 加拿大时间               24. 墨西哥时间"
                echo "25. 巴西时间                 26. 阿根廷时间"
                echo "------------------------"
                echo " 0. 返回上一级选单"
                echo "------------------------"
                read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                case $sub_choice in
                    1) timedatectl set-timezone Asia/Shanghai ;;
                    2) timedatectl set-timezone Asia/Hong_Kong ;;
                    3) timedatectl set-timezone Asia/Tokyo ;;
                    4) timedatectl set-timezone Asia/Seoul ;;
                    5) timedatectl set-timezone Asia/Singapore ;;
                    6) timedatectl set-timezone Asia/Kolkata ;;
                    7) timedatectl set-timezone Asia/Dubai ;;
                    8) timedatectl set-timezone Australia/Sydney ;;
                    11) timedatectl set-timezone Europe/London ;;
                    12) timedatectl set-timezone Europe/Paris ;;
                    13) timedatectl set-timezone Europe/Berlin ;;
                    14) timedatectl set-timezone Europe/Moscow ;;
                    15) timedatectl set-timezone Europe/Amsterdam ;;
                    16) timedatectl set-timezone Europe/Madrid ;;
                    21) timedatectl set-timezone America/Los_Angeles ;;
                    22) timedatectl set-timezone America/New_York ;;
                    23) timedatectl set-timezone America/Vareouver ;;
                    24) timedatectl set-timezone America/Mexico_City ;;
                    25) timedatectl set-timezone America/Sao_Paulo ;;
                    26) timedatectl set-timezone America/Argentina/Buenos_Aires ;;
                    0) break ;; # 跳出循环，退出菜单
                    *) break ;; # 跳出循环，退出菜单
                esac
            done
            ;;

          24)
            clear
            wget --no-check-certificate -qO natcfg.sh https://raw.githubusercontent.com/arloor/iptablesUtils/master/natcfg.sh && bash natcfg.sh
            sleep 2
            break_end
            ;;
          25)
            clear
                echo -e "${yellow}初始化环境...${re}"
                install sshpass
                clear
                read -e -p $'\033[1;35m请输入要连接的ipv4/ipv6地址: \033[0m' common_ip
                
                echo -e "${green}即将进入nano编辑器，请添加nat小鸡配置信息${re}"
                sleep 1
                echo -e "# 示例配置: \n# ex1 20001 8a2a7f65c 30001 30025" > server.txt
                nano -w server.txt
                echo -e "${green}进入测试中,请稍等...${re}"

                if [ -f "server.txt" ]; then
                    mapfile -t lines < "server.txt"

                    # 遍历配置文件进行连接测试
                    for line in "${lines[@]}"; do
 
                        if [[ "$line" == \#* || -z "$line" ]]; then
                            continue
                        fi

                        name=$(echo "$line" | awk '{print $1}')
                        port=$(echo "$line" | awk '{print $2}')
                        password=$(echo "$line" | awk '{print $3}')

                        ssh_output=$(sshpass -p "$password" ssh -p "$port" -o ConnectTimeout=5 "root@$common_ip" "echo Connection successful!" 2>&1 || true)

                        if [[ "$ssh_output" == *successful* ]]; then
                            echo -e "${green}$name $port $password connect successful${re}"
                        else
                            echo -e "${red}$name $port $password connect failed${re}"
                        fi
                    done

                else
                    echo -e "${red}未找到server.txt配置文件${re}"
                    exit 1
                fi

                rm server.txt
                
              ;;
          80)
            clear
            install sshpass

            remote_ip="8.8.8.8"
            remote_user="liaotian123"
            remote_file="/home/liaotian123/liaotian.txt"
            password="wangYYDS"  # 替换为您的密码

            clear
            echo "留言板"
            echo "------------------------"
            # 显示已有的留言内容
            sshpass -p "${password}" ssh -o StrictHostKeyChecking=no "${remote_user}@${remote_ip}" "cat '${remote_file}'"
            echo ""
            echo "------------------------"

            # 判断是否要留言
            read -e -p "是否要留言？(y/n): " leave_message

            if [ "$leave_message" == "y" ] || [ "$leave_message" == "Y" ]; then
                # 输入新的留言内容
                read -e -p "输入你的昵称: " nicheng
                read -e -p "输入你的聊天内容: " neirong

                # 添加新留言到远程文件
                sshpass -p "${password}" ssh -o StrictHostKeyChecking=no "${remote_user}@${remote_ip}" "echo -e '${nicheng}: ${neirong}' >> '${remote_file}'"
                echo "已添加留言: "
                echo "${nicheng}: ${neirong}"
                echo ""
            else
                echo "您选择了不留言。"
            fi

            echo "留言板操作完成。"

              ;;

          99)
              clear
              echo "正在重启服务器，即将断开SSH连接"
              reboot
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

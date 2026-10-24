#!/usr/bin/env bash
# vps-toolbox 模块：开设 NAT 小鸡
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_nat_vm() {
    while true; do
        clear
        echo -e "${purple}▶ 管理NAT小鸡${re}"
        echo "------------------------"
        echo -e "${yellow}开设kvm小鸡分两步，请依次执行。 \n如果第一步失败，请选择其他方式开设小鸡。\n建议选择4或9，大部分vps都兼容！${re}"
        echo "------------------------"
        echo -e "${skyblue} 1. 开设KVM小鸡(第1步)${re}" 
        echo -e "${skyblue} 2. 开设KVM小鸡(第2步)${re}"
        echo -e "${red} 3. 删除所有KVM小鸡${re}"
        echo "------------------------"
        echo -e "${green} 4. 开设LXC小鸡(官方版)${re}" 
        echo -e "${green} 5. 开设LXC小鸡(魔改版)${re}" 
        echo -e "${skyblue} 6. 管理LXC小鸡 ▶${re}"
        echo "------------------------"
        echo -e "${green} 7. 开设Docker小鸡${re}"
        echo -e "${red} 8. 删除所有Docker容器${re}"
        echo "------------------------"
        echo -e "${green} 9. 开设incus小鸡(官方版)${re}" 
        echo -e "${skyblue}10. 管理incus小鸡 ▶${re}"
        echo "------------------------"
        echo -e "${skyblue} 0. 返回主菜单${re}"
        echo "------------------------"
        while :; do
            echo
            read -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice
            if ! [[ "$sub_choice" =~ ^[0-9]+$ ]]; then
                echo -e "${red}输入错误, 请输入0~10的数字!${re}"
                continue
            fi
            if [ $sub_choice -ge 0 -a $sub_choice -le 12 ]; then
                break
            else
                echo -e "${red}输入错误, 请输入0~10的数字!${re}"   
            fi
        done
        case $sub_choice in 
            1)
                clear
                echo -e "${yellow}开始进行环境检测...${re}"
                install wget
                output=$(bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/oneclickvirt/pve/main/scripts/check_kernal.sh))
                echo "$output"
                if echo "$output" | grep -q "CPU不支持硬件虚拟化，无法嵌套虚拟化KVM服务器，但可以开LXC服务器(CT)"; then
                    echo ""
                    echo -e "${red}你的服务器不支持开设KVM小鸡，建议选择4或9开设其他类型，正在退出...${re}"
                    rm -rf /root/check_kernal.sh
                    sleep 2
                    break_end

                elif echo "$output" | grep -q "本机符合要求：可以使用PVE虚拟化KVM服务器，并可以在开出来的KVM服务器选项中开启KVM硬件虚拟化"; then
                    echo -e "${green}本机符合开设kvm小鸡的要求${re}"
                    read -p $'\033[1;35m确定要开设kvm小鸡吗？ [y/n]: \033[0m' confirm
                    sleep 1
                    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                        echo ""
                        echo ""
                        echo ""
                        echo -e "${yellow}开设虚拟内存(Swap),请先输入2移除原来的配置，会自动重新执行一次，再输入1添加虚拟内存${re}"
                        curl -L https://raw.githubusercontent.com/spiritLHLS/addswap/main/addswap.sh -o addswap.sh && chmod +x addswap.sh && bash addswap.sh
                        sleep 1
                        curl -L https://raw.githubusercontent.com/spiritLHLS/addswap/main/addswap.sh -o addswap.sh && chmod +x addswap.sh && bash addswap.sh
                        echo -e "${yellow}开始进行PVE主体安装${re}"
                        curl -L https://raw.githubusercontent.com/spiritLHLS/pve/main/scripts/install_pve.sh -o install_pve.sh && chmod +x install_pve.sh && bash install_pve.sh
                        sleep 1
                        echo -e "${yellow}请等待20秒后重启后运行第2步${re}"
                        read -p $'\033[1;96m需要立即重启吗？ [y/n]: \033[0m' confirm
                        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                            sleep 1
                            reboot
                        else 
                            break_end
                        fi
                    else
                        echo -e "${yellow}已取消操作...${re}"
                        sleep 2
                        main_menu
                    fi

                elif echo "$output" | grep -q "宿主机的环境无apt包管理器命令，请检查系统"; then
                    echo ""
                    echo -e "${red}你的vps系统暂不支持，请更换Debian12或Ubuntu22.04后重试${re}"
                    sleep 3
                    main_menu
                else 
                    echo -e "${red}暂不能判定你的服务器状态，无法开设kvm小鸡，可以考虑使用LXC模式开小鸡，正在退出...${re}"
                    rm -rf /root/check_kernal.sh
                    sleep 3
                    main_menu
                fi
            ;;

            2)
                clear

                read -p $'\033[1;96m确认你已执行完第1步，是否继续 [y/n]: \033[0m' confirm
                if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then

                    sleep 1
                    curl -L https://raw.githubusercontent.com/spiritLHLS/pve/main/scripts/install_pve.sh -o install_pve.sh && chmod +x install_pve.sh && bash install_pve.sh
                    sleep 1
                    echo -e "${yellow}开始配置环境...${re}"
                    bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/spiritLHLS/pve/main/scripts/build_backend.sh)
                    sleep 1
                    echo -e "${yellow}开始自动配置宿主机的网关...${re}"
                    bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/spiritLHLS/pve/main/scripts/build_nat_network.sh)
                    sleep 1
                    echo -e "${yellow}KVM虚拟化开设出的虚拟机，默认生成的用户名不是root，请确保你已在root下运行及修改root密码${re}"

                    while true; do
                        read -p $'\033[1;96m你需要手动开设kvm小鸡还是批量开设kvm小鸡？(1：手动开设  2：自动批量开设) \033[0m' choose

                        if [ "$choose" == "1" ]; then
                            sleep 1
                            curl -L https://raw.githubusercontent.com/spiritLHLS/pve/main/scripts/buildvm.sh -o buildvm.sh && chmod +x buildvm.sh
                            sleep 2
                            echo -e "${purple}手动开设请执行以下命令，参数对照如下可自行修改${re}"
                            echo ""
                            echo -e "${purple}./buildvm.sh VMID 用户名 密码 CPU核数 内存 硬盘 SSH端口 80端口 443端口 外网端口起 外网端口止 系统 存储盘 独立IPV6地址(留空默认N)${re}"
                            echo -e "${purple}./buildvm.sh 102 test1 oneclick123 1 512 10 40001 40002 40003 50000 50025 debian11 local N${re}"
                            sleep 3
                            break_end
                            break  # 跳出循环
                        elif [ "$choose" == "2" ]; then
                            sleep 1
                            echo -e "${red}注意: KVM开设出的NAT小鸡，默认生成的用户名不是root，默认的root密码部分类型是${green}password${red},需要sudo -i手动切换为root${re}"
                            sleep 2
                            curl -L https://raw.githubusercontent.com/spiritLHLS/pve/main/scripts/create_vm.sh -o create_vm.sh && chmod +x create_vm.sh && bash create_vm.sh
                            sleep 2
                            break_end
                            break  # 跳出循环
                        else
                            echo -e "${red}输入错误，请输入1或2${re}"
                        fi
                    done
                else 
                    break_end
                fi
            ;;

            3)
                clear
                for vmid in $(qm list | awk '{if(NR>1) print $1}'); do qm stop $vmid; qm destroy $vmid; rm -rf /var/lib/vz/images/$vmid*; done
                iptables -t nat -F
                iptables -t filter -F
                service networking restart
                systemctl restart networking.service
                systemctl restart ndpresponder.service
                iptables-save | awk '{if($1=="COMMIT"){delete x}}$1=="-A"?!x[$0]++:1' | iptables-restore
                iptables-save > /etc/iptables/rules.v4
                rm -rf vmlog
                rm -rf vm*
                sleep 2
                break_end
            ;;

            4)
                clear
                echo -e "${yellow}开始进行环境检测...${re}"
                install wget 

                output=$(bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/oneclickvirt/lxd/main/scripts/pre_check.sh))
                echo "$output"
                if echo "$output" | grep -q "本机符合作为LXC母鸡的要求，可以批量开设LXC容器"; then
                    echo ""
                    echo -e "${green}你的vps已通过检测，可以开设LXC小鸡${re}"

                    read -p $'\033[1;35m确定要开设LXC小鸡吗？ [y/n]: \033[0m' confirm

                        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then

                            echo -e "${yellow}开始进行安装LXD主体...${re}"
                            sleep 1
                            curl -L https://raw.githubusercontent.com/oneclickvirt/lxd/main/scripts/lxdinstall.sh -o lxdinstall.sh && chmod +x lxdinstall.sh && bash lxdinstall.sh
                            sleep 3
                            # 检查LXD是否安装成功
                            check_lxc(){
                                if command lxc -h &> /dev/null; then
                                    echo -e "${green}LXD主体已安装完成${re}"
                                    # lxc --version 2>/dev/null
                                    sleep 1
                                    return 0
                                else
                                    echo -e "${yellow}lxc没有软连接上，正在为你修复...${re}"
                                    apt update -y
                                    ! lxc -h >/dev/null 2>&1 && echo 'alias lxc="/snap/bin/lxc"' >> /root/.bashrc && source /root/.bashrc
                                    export PATH=$PATH:/snap/bin

                                    if command lxc -h &> /dev/null; then
                                        sleep 1
                                        return 0
                                    else
                                        echo -e "${yellow}lxc没有软连接上，请重启系统后重新运行${re}"
                                        sleep 2
                                        main_menu
                                    fi
                                fi
                            }
                            check_lxc
                            while true; do
                                clear
                                echo ""
                                echo -e "${yellow}温馨提醒:如果你开设的小鸡数量较多建议reboot重启一次系统使配置生效，再进入管理LXC小鸡菜单${purple}新增即可${re}"
                                echo ""
                                read -p $'\033[1;35m选择哪种方式开设LXC小鸡？\n1:普通批量生成(256RAM+1G+上下行限制300Mb)  \n2:自定义配置批量生成  \n3:取消开小鸡 \n4:重启系统 \n请选择： \033[0m' confirm

                                case $confirm in
                                    1)
                                        echo -e "${green}开始运行普通版本批量生成小鸡${yellow}(1核256MB内存1GB硬盘限速300Mbit)${re}"
                                        sleep 1
                                        install screen wget sudo dos2unix jq
                                        curl -L https://raw.githubusercontent.com/oneclickvirt/lxd/main/scripts/init.sh -o init.sh && chmod +x init.sh && dos2unix init.sh
                                        
                                        read -p $'\033[1;35m请输入你要生成小鸡的数量：\033[0m' number
                                        sleep 1
                                        install screen
                                        echo -e "${green}正在后台自动为你开设小鸡中，可关闭SSH，完成后运行cat log查看信息${re}"
                                        sleep 3
                                        screen bash init.sh lxc $number 
                                        sleep 3
                                        cat log
                                        break
                                        ;;
                                    2)
                                        echo -e "${green}开始运行自定义批量生成小鸡(自定义配置)${re}"
                                        sleep 1
                                        install screen wget sudo dos2unix jq
                                        echo -e "${green}输入配置后，自动进入后台生成小鸡(可直接关闭SSH连接，完成后运行cat log查看小鸡信息)${re}"
                                        sleep 3
                                        curl -L https://github.com/oneclickvirt/lxd/raw/main/scripts/add_more.sh -o add_more.sh && chmod +x add_more.sh && screen bash add_more.sh
                                        cat log
                                        break
                                        ;;
                                    3)
                                        echo -e "${yellow}你已取消了开设小鸡的操作${re}"
                                        exit 0
                                        ;;
                                    4)
                                        reboot
                                        ;;
                                    *)
                                        echo -e "${red}输入错误，请输入1~4${re}"
                                        ;;
                                esac
                            done

                        else
                            echo -e "${yellow}取消开设LXC小鸡，正在退出...${re}"
                            sleep 2
                            main_menu
                            
                        fi                        
                else
                    echo -e "${red}你的vps不符合开设LXC母鸡要求，请选择incus或Docker方式开设小鸡${re}"
                    sleep 3
                    main_menu
                fi
            ;;


            5)
                clear
                install wget
                wget -N --no-check-certificate https://raw.githubusercontent.com/eooce/lxdpro/main/lxdpro.sh && chmod +x lxdpro.sh && bash lxdpro.sh

                break_end
            
            ;;                   

            6)
              while true; do
                clear
                echo -e "${purple}▶ 管理LXC小鸡${re}"
                echo "------------------------"
                echo -e "${skyblue}1. 查看所有LXC小鸡${re}"
                echo "------------------------"
                echo -e "${skyblue}2. 暂停所有LXC小鸡${re}"
                echo -e "${skyblue}3. 启动所有LXC小鸡${re}"
                echo "------------------------"
                echo -e "${skyblue}4. 暂停指定LXC小鸡${re}"
                echo -e "${skyblue}5. 启动指定LXC小鸡${re}"
                echo -e "${skyblue}6. 给指定小鸡重装系统${re}"
                echo "------------------------"
                echo -e "${skyblue}7. 新增开设LXC小鸡${re}"
                echo -e "${red}8. 删除指定LXC小鸡${re}" 
                echo -e "${red}9. 删除所有LXC小鸡和配置${re}" 
                echo "------------------------"
                echo -e "${white}0. 返回上一级菜单${re}"
                echo "------------------------"
                read -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                case $sub_choice in
                    1)
                        clear
                        echo -e "${green}所有LXC小鸡运行状态：${re}"
                        lxc list
                        echo -e "${green}所有LXC小鸡密码端口信息${re}"
                        cat log
                        break_end
                    ;;

                    2)
                        clear
                        lxc stop --all
                        break_end
                    ;;

                    3)
                        clear
                        lxc start --all
                        break_end
                    ;;

                    4)
                        clear
                        read -p $'\033[1;35m请输入要暂停的小鸡的名字（如ex1，nat1等）：\033[0m' nat
                        lxc stop $nat
                        info_output=$(lxc info $nat)

                        # 检查指定暂停的小鸡状态
                        if echo "$info_output" | grep -q "Status: STOPPED"; then
                            echo -e "${green}已暂停${nat}小鸡${re}"
                            sleep 2
                            break_end
                        elif echo "$info_output" | grep -q "Status: RUNNING"; then
                            echo -e "${yellow}${nat}仍在运行，请重试${re}"
                            sleep 2
                        else
                            echo -e "${red}未知${nat}状态${re}"
                            sleep 2
                        fi
                    ;;

                    5)
                        clear
                        read -p $'\033[1;35m请输入要启动的小鸡的名字（如ex1，nat1等）: \033[0m' nat
                        lxc start $nat
                        info_output=$(lxc info ${nat})

                        # 检查指定启动的小鸡状态
                        if echo "$info_output" | grep -q "Status: RUNNING"; then
                            echo -e "${green}启动成功${nat}小鸡${re}"
                            sleep 2
                            break_end
                        elif echo "$info_output" | grep -q "Status: STOPPED"; then
                            echo -e "${yellow}${nat}暂停状态，请重新启动${re}"
                            sleep 2
                        else
                            echo -e "${red}未知${nat}状态${re}"
                            sleep 2
                        fi

                    ;;

                    6)
                        clear
                        read -p $'\033[1;35m请输入要重装系统的小鸡的名字（如ex1，nat1等）: \033[0m' nat
                        lxc stop $nat && lxc rebuild images:debian/11 $nat
                        sleep 2
                        lxc start $nat
                        echo -e "${green}${nat}小鸡已重装系统完成${re}"
                        sleep 2
                        break_end
                    ;;

                    7)
                        read -p $'\033[1;35m确定要新增LXC小鸡吗？ [y/n]: \033[0m' confirm

                        if [[ "$confirm" =~ ^[Yy]$ ]]; then   
                            echo -e "${green}输入配置后将进入后台为你新增，可关闭SSH，完成后cat log查看信息${re}"
                            install screen wget sudo dos2unix jq
                            curl -L https://github.com/oneclickvirt/lxd/raw/main/scripts/add_more.sh -o add_more.sh && chmod +x add_more.sh && screen bash add_more.sh

                        else 
                            echo -e "${green}已取消${re}"
                            break_end
                        fi
                    ;;

                    8)
                        clear
                        read -p $'\033[1;35m请输入要删除的小鸡的名字（如ex1，nat1等）: \033[0m' nat
                        lxc delete -f $nat
                        sleep 2
                        echo -e "${green}${nat}小鸡已删除${re}"
                        sleep 2
                        break_end
                    ;;

                    9)
                        clear
                        read -p $'\033[1;35m删除后无法恢复，确定要继续删除所有Lxc小鸡吗 [y/n]: \033[0m' confirm

                        if [[ "$confirm" =~ ^[Yy]$ ]]; then   
                            lxc list -c n --format csv | xargs -I {} lxc delete -f {}

                            sudo find /var/log -type f -delete
                            sudo find /var/tmp -type f -delete
                            sudo find /tmp -type f -delete
                            sudo find /var/cache/apt/archives -type f -delete

                            # 删除配置
                            rm -rf /usr/local/bin/ssh_sh.sh
                            rm -rf /usr/local/bin/config.sh
                            rm -rf /usr/local/bin/ssh_bash.sh
                            rm -rf /usr/local/bin/check-dns.sh
                            rm -rf /root/ssh_sh.sh
                            rm -rf /root/config.sh
                            rm -rf /root/ssh_bash.sh
                            rm -rf /root/buildone.sh
                            rm -rf /root/add_more.sh
                            rm -rf /root/build_ipv6_network.sh

                            echo -e "${green}已删除所有Lxc小鸡${re}"
                            break_end
                        else 
                            echo -e "${green}已取消删除${re}"
                            break_end
                        fi    
                    ;;                    
                    
                    0)
                        break
                    ;;
                    *)
                        echo -e "${red}无效选择，请重新输入。${re}"
                    ;;
                esac
              done
            ;;

            7)
                clear
                echo -e "${yellow}开设虚拟内存(Swap),请先输入2移除原来的，会重新执行一次，再输入1添加虚拟内存${re}"
                curl -L https://raw.githubusercontent.com/spiritLHLS/addswap/main/addswap.sh -o addswap.sh && chmod +x addswap.sh && bash addswap.sh
                sleep 1
                curl -L https://raw.githubusercontent.com/spiritLHLS/addswap/main/addswap.sh -o addswap.sh && chmod +x addswap.sh && bash addswap.sh
                sleep 1
                echo -e "${yellow}开始安装docker配置环境${re}"
                curl -L https://raw.githubusercontent.com/spiritLHLS/docker/main/scripts/dockerinstall.sh -o dockerinstall.sh && chmod +x dockerinstall.sh && bash dockerinstall.sh
                sleep 2

                while true; do
                    read -p $'\033[1;96m你需要单独开设Docker小鸡还是批量开设Docker小鸡？(1：单个开设  2：批量开设 3：重启系统) \033[0m' choose

                    if [ "$choose" == "1" ]; then
                        sleep 1
                        install screen
                        curl -L https://raw.githubusercontent.com/spiritLHLS/docker/main/scripts/onedocker.sh -o onedocker.sh && chmod +x onedocker.sh && screen bash onedocker.sh
                        sleep 2
                        break_end
                        break  # 跳出循环
                    elif [ "$choose" == "2" ]; then
                        sleep 1
                        curl -L https://raw.githubusercontent.com/spiritLHLS/docker/main/scripts/create_docker.sh -o create_docker.sh && chmod +x create_docker.sh && screen bash create_docker.sh
                        sleep 2
                        break_end
                        break  # 跳出循环
                    elif  [ "$choose" == "3" ]; then
                        reboot
                    else
                        echo -e "${red}输入错误，请输入1或2${re}"
                    fi
                done
            ;;

            8)
                clear
                docker ps -aq --format '{{.Names}}' | grep -E '^ndpresponder' | xargs -r docker rm -f
                docker images -aq --format '{{.Repository}}:{{.Tag}}' | grep -E '^ndpresponder' | xargs -r docker rmi
                rm -rf dclog
                ls

                sleep 2
                break_end
            ;;

            9)
                clear
                echo -e "${yellow}开始进行环境检测...${re}"
                install wget 

                output=$(bash <(wget -qO- --no-check-certificate https://raw.githubusercontent.com/oneclickvirt/incus/main/scripts/pre_check.sh))
                echo "$output"
                if echo "$output" | grep -q "本机符合作为incus母鸡的要求，可以批量开设incus容器"; then

                    echo -e "${green}你的vps符合开设incus要求，可以开设incus小鸡${re}"

                    read -p $'\033[1;35m确定要开设incus小鸡吗？ [y/n]: \033[0m' confirm

                        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then

                            # 固定 dns，防止修改导致失败开小鸡失败
                            systemctl disable systemd-resolved --now > /dev/null 2>&1
                            rm -rf /etc/resolv.conf > /dev/null 2>&1
                            cat >/etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 2606:4700:4700::1111
nameserver 2001:4860:4860::8888
EOF
                            chattr +i /etc/resolv.conf > /dev/null 2>&1
                            
                            echo -e "${yellow}开始进行安装incus主体...${re}"
                            sleep 1
                            curl -L https://raw.githubusercontent.com/oneclickvirt/incus/main/scripts/incus_install.sh -o incus_install.sh && chmod +x incus_install.sh && bash incus_install.sh
                            sleep 2
                            # 检查incus是否安装成功
                            check_incus(){
                                if which incus >/dev/null; then
                                    echo -e "${green}Incus主体已安装完成${re}"
                                    # incus --version 2>/dev/null
                                    sleep 1
                                    return 0
                                
                                else
                                    echo "Incus主体已安装失败，请更新系统后重试，正在清理缓存..."
                                    rm -rf /root/incus_install.sh
                                    sleep 2
                                    main_menu

                                fi
                            }

                            while true; do
                                clear
                                echo ""
                                echo -e "${yellow}温馨提醒:如果你开设的小鸡数量较多建议reboot重启一次系统使配置生效，再进入管理incus小鸡菜单${purple}新增即可${re}"
                                echo ""
                                read -p $'\033[1;35m选择哪种方式开设incus小鸡？\n1:普通批量生成(256RAM+1G+上下行300Mb)  \n2:自定义配置批量生成  \n3:取消开小鸡 \n4:重启系统 \n请选择： \033[0m' confirm

                                case $confirm in
                                    1)
                                        echo -e "${green}开始运行普通版本批量生成小鸡${yellow}(1核256MB内存1GB硬盘限速300Mbit)${re}"
                                        sleep 1
                                        curl -L https://raw.githubusercontent.com/oneclickvirt/incus/main/scripts/init.sh -o init.sh && chmod +x init.sh && dos2unix init.sh
                                        
                                        read -p $'\033[1;35m请输入你要生成小鸡的数量：\033[0m' number
                                        sleep 1
                                        install screen
                                        echo -e "${green}正在后台自动为你开设小鸡中，可关闭SSH，完成后运行cat log查看小鸡信息${re}"
                                        sleep 3
                                        screen bash init.sh nat $number 
                                        sleep 3
                                        cat log
                                        break
                                        ;;
                                    2)
                                        echo -e "${green}开始运行自定义批量生成小鸡${re}"
                                        sleep 1
                                        install screen curl wget sudo dos2unix jq > /dev/null 2>&1
                                        echo -e "${green}正在后台自动为你开设小鸡中，可关闭SSH，完成后运行cat log查看小鸡信息${re}"
                                        sleep 3
                                        curl -L https://github.com/oneclickvirt/incus/raw/main/scripts/add_more.sh -o add_more.sh && chmod +x add_more.sh && screen bash add_more.sh
                                        cat log
                                        break
                                        ;;
                                    3)
                                        echo -e "${green}你已取消了开设小鸡的操作${re}"
                                        exit 0
                                        ;;
                                    4)
                                        reboot
                                        ;;
                                    *)
                                        echo -e "${red}输入错误，请输入 1至4的数字${re}"
                                        ;;
                                esac
                            done

                        else
                            echo -e "${yellow}取消开设incus小鸡，正在退出...${re}"
                            sleep 2
                            main_menu
                            
                        fi
                else
                    echo ""
                    echo -e "${red}你的vps不符合开设incus要求，请选择LXD或Docker方式开设小鸡${re}"
                    sleep 2
                    break_end
                fi
            ;;

            10)
              while true; do
                clear
                echo -e "${purple}▶ 管理incus小鸡${re}"
                echo "------------------------"
                echo -e "${skyblue}1. 查看所有incus小鸡运行状态${re}"
                echo "------------------------"
                echo -e "${skyblue}2. 暂停所有incus小鸡${re}"
                echo -e "${skyblue}3. 启动所有incus小鸡${re}"
                echo "------------------------"
                echo -e "${skyblue}4. 暂停指定incus小鸡${re}"
                echo -e "${skyblue}5. 启动指定incus小鸡${re}"
                echo -e "${skyblue}6. 给指定小鸡重装系统${re}"
                echo "------------------------"
                echo -e "${skyblue}7. 新增开设incus小鸡${re}"
                echo -e "${red}8. 删除指定incus小鸡${re}"
                echo -e "${red}9. 删除所有incus小鸡和配置${re}" 
                echo "------------------------"
                echo -e "${white}0. 返回上一级菜单${re}"
                echo "------------------------"
                read -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                case $sub_choice in
                    1)
                        clear
                        echo -e "${green}所有incus小鸡运行状态：${re}"
                        incus list
                        echo -e "${green}所有incus小鸡密码端口信息${re}"
                        cat log
                        break_end
                    ;;

                    2)
                        clear
                        incus stop --all
                        break_end
                    ;;

                    3)
                        clear
                        incus start --all
                        break_end
                    ;;

                    4)
                        clear
                        read -p $'\033[1;35m请输入要暂停的小鸡的名字（如ex1，nat1等）：\033[0m' nat
                        incus stop $nat
                        info_output=$(incus info $nat)

                        # 检查指定暂停的小鸡状态
                        if echo "$info_output" | grep -q "Status: STOPPED"; then
                            echo -e "${green}已暂停${nat}小鸡${re}"
                            sleep 2
                            break_end
                        elif echo "$info_output" | grep -q "Status: RUNNING"; then
                            echo -e "${yellow}${nat}仍在运行，请重试${re}"
                            sleep 2
                        else
                            echo -e "${red}未知${nat}状态${re}"
                            sleep 2
                        fi
                    ;;

                    5)
                        clear
                        read -p $'\033[1;35m请输入要启动的小鸡的名字（如ex1，nat1等）: \033[0m' nat
                        incus start $nat
                        info_output=$(incus info ${nat})

                        # 检查指定启动的小鸡状态
                        if echo "$info_output" | grep -q "Status: RUNNING"; then
                            echo -e "${green}启动成功${nat}小鸡${re}"
                            sleep 2
                            break_end
                        elif echo "$info_output" | grep -q "Status: STOPPED"; then
                            echo -e "${yellow}${nat}暂停状态，请重新启动${re}"
                            sleep 2
                        else
                            echo -e "${red}未知${nat}状态${re}"
                            sleep 2
                        fi

                    ;;

                    6)
                        clear
                        read -p $'\033[1;35m请输入要重装系统的小鸡的名字（如ex1，nat1等）: \033[0m' nat
                        incus stop $nat && incus rebuild images:debian/11 $nat
                        sleep 2
                        incus start $nat
                        echo -e "${green}${nat}小鸡已重装系统完成${re}"
                        sleep 2
                        break_end
                    ;;
                    7)
                        read -p $'\033[1;35m确定要新增incus小鸡吗？ [y/n]: \033[0m' confirm

                        if [[ "$confirm" =~ ^[Yy]$ ]]; then   
                            echo -e "${green}输入配置后将进入后台为你新增incus小鸡，可关闭SSH，完成后cat log查看信息${re}"
                            install screen curl wget sudo dos2unix jq > /dev/null 2>&1
                            curl -L https://github.com/oneclickvirt/incus/raw/main/scripts/add_more.sh -o add_more.sh && chmod +x add_more.sh && screen bash add_more.sh
                            cat log
                        else 
                            echo -e "${green}已取消${re}"
                            break_end
                        fi
                    ;;
                    8)
                        clear
                        read -p $'\033[1;35m请输入要删除的小鸡的名字（如ex1，nat1等）: \033[0m' nat
                        incus delete -f $nat
                        sleep 2
                        echo -e "${green}${nat}小鸡已删除${re}"
                        sleep 2
                        break_end
                    ;;

                    9)
                        clear
                        read -p $'\033[1;35m删除后无法恢复，确定要继续删除所有incus小鸡吗 [y/n]: \033[0m' confirm

                        if [[ "$confirm" =~ ^[Yy]$ ]]; then   
                            incus list -c n --format csv | xargs -I {} incus delete -f {}

                            sudo find /var/log -type f -delete
                            sudo find /var/tmp -type f -delete
                            sudo find /tmp -type f -delete
                            sudo find /var/cache/apt/archives -type f -delete

                            # 删除配置
                            rm -rf /usr/local/bin/ssh_sh.sh
                            rm -rf /usr/local/bin/config.sh
                            rm -rf /usr/local/bin/ssh_bash.sh
                            rm -rf /usr/local/bin/check-dns.sh
                            rm -rf /root/ssh_sh.sh
                            rm -rf /root/config.sh
                            rm -rf /root/ssh_bash.sh
                            rm -rf /root/buildone.sh
                            rm -rf /root/add_more.sh
                            rm -rf /root/build_ipv6_network.sh

                            echo -e "${green}已删除所有incus小鸡${re}"
                            break_end
                        else 
                            echo -e "${green}已取消删除${re}"
                            break_end
                        fi 
                    ;;

                    0)
                        break
                    ;;
                    *)
                        echo -e "${red}无效选择，请重新输入。${re}"
                    ;;
                esac
              done
            ;;

            0)
                main_menu
            ;;
        esac
    done
}

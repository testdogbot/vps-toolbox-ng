#!/usr/bin/env bash
# vps-toolbox 模块：常用环境管理
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_env_manage() {
    while true; do
        clear
       echo -e "${skyblue}▶ 常用环境管理${re}"
        echo "------------------------"
        echo -e "${green}1. 一键安装Python最新版${re}"
        echo -e "${green}2. 一键安装Nodejs最新版${re}"
        echo -e "${green}3. 一键安装Golang最新版${re}"
        echo -e "${green}4. 一键安装Java最新版${re}"
        echo "------------------------"
        echo -e "${red}5. 一键卸载Python${re}"
        echo -e "${red}6. 一键卸载Nodejs${re}"
        echo -e "${red}7. 一键卸载Golang${re}"
        echo -e "${red}8. 一键卸载Java${re}"
        echo "------------------------"
        echo -e "${skyblue}0. 返回主菜单${re}"
        echo "------------------------"
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

        case $sub_choice in
            1)
             clear
                # 获取系统信息
                OS=$(grep -o -E "Debian|Ubuntu|CentOS|Alpine|Fedora|Rocky|AlmaLinux|Amazon" /etc/os-release 2>/dev/null | head -n 1)

                # 检查系统支持性
                if [[ -n $OS ]]; then
                    echo -e "${green}检测到你的系统是${yellow}${OS}${re}"
                else
                    echo -e "${red}很抱歉，暂不支持的系统！${re}"
                    sleep 2
                    main_menu
                fi

                # 检测安装Python3的版本
                VERSION=$(python3 -V 2>&1 | awk '{print $2}')

                # 获取最新Python3版本
                PY_VERSION=$(curl -s https://www.python.org/ | grep "downloads/release" | grep -o 'Python [0-9.]*' | grep -o '[0-9.]*')

                # 卸载Python3旧版本
                if [[ $VERSION == "3"* ]]; then
                    if [ "$VERSION" = "$PY_VERSION" ]; then
                        echo -e "${green}检测到你的Python3版本已经是最新版本:${red}${PY_VERSION}${green}，无需安装或升级${re}"
                        sleep 2
                        main_menu
                    else
                        echo -e "${yellow}检测到你的Python3版本:${red}${VERSION}${yellow},最新版本:${green}${PY_VERSION}${re}"
                        read -e -p $'\033[1;91m是否确认升级最新版Python3？[y/n]: \033[0m' confirm
                        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                            if [[ $OS == "CentOS" ]]; then
                                yum remove python3 -y
                                package-cleanup --leaves
                                package-cleanup --orphans
                                yum autoremove -y
                                rm-rf /usr/local/python3* >/dev/null 2>&1
                                
                            elif [[ $OS == "Alpine" ]]; then
                                apk del python3
                                apk info --installed | xargs apk info --installed -R | cut -d: -f1 | sort | uniq -c | sort -n | grep -v ' 1 ' | awk '{print $2}' | xargs apk del
                                rm -rf /usr/lib/python3.*
                                rm -rf /etc/python3
                                rm -rf /var/cache/apk/*
                                    
                            elif [[ $OS == "Fedora" ]] || [[ $OS == "Rocky" ]] || [[ $OS == "AlmaLinux" ]] || [[ $OS == "Amazon" ]]; then
                                dnf remove python3 -y
                                dnf autoremove -y
                                rm -rf ~/.local/lib/python3.*                  
                            else
                                apt --purge remove python3 python3-pip -y
                                rm-rf /usr/local/python3*
                            fi
                        else
                            echo -e "${yellow}已取消升级Python3${re}"
                            sleep 1
                            main_menu
                        fi
                    fi   
                else
                    echo -e "${red}检测到没有安装Python3。${re}"
                    read -e -p $'\033[1;91m是否确认安装最新版Python3？[y/n]: \033[0m' confirm
                    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                        echo -e "${green}开始安装最新版Python3...${re}"
                    else
                        echo -e "${yellow}已取消安装Python3${re}"
                        exit 1
                    fi
                fi

                # 安装相关依赖
                if [[ $OS == "CentOS" ]]; then
                    yum update -y
                    yum groupinstall -y "development tools"
                    yum install wget tar openssl-devel bzip2-devel libffi-devel zlib-devel -y
                elif [[ $OS == "Fedora" ]] || [[ $OS == "Rocky" ]] || [[ $OS == "AlmaLinux" ]] || [[ $OS == "Amazon" ]]; then
                    dnf update -y
                    dnf groupinstall -y "development tools"
                    dnf install wget tar openssl-devel bzip2-devel libffi-devel zlib-devel -y
                elif [[ $OS == "Alpine" ]]; then
                    apk update
                    apk add python3
                    apk add py3-pip
                    apk add wget tar openssl-dev bzip2-dev libffi-dev zlib-dev
                    sleep 2
                    break_end
                    exit 1
                else
                    apt update -y
                    apt install wget tar build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y
                fi
                
                # 安装python3
                install wget tar
                cd /root/
                wget https://www.python.org/ftp/python/${PY_VERSION}/Python-"$PY_VERSION".tgz
                tar -zxf Python-${PY_VERSION}.tgz
                cd Python-${PY_VERSION}
                ./configure --prefix=/usr/local/python3
                make -j $(nproc)
                make install
                if [ $? -eq 0 ];then
                    rm -f /usr/local/bin/python3*
                    rm -f /usr/local/bin/pip3*
                    ln -sf /usr/local/python3/bin/python3 /usr/bin/python3
                    ln -sf /usr/local/python3/bin/pip3 /usr/bin/pip3
                    clear
                    echo -e "${yellow}Python3安装${green}成功，${re}版本为: ${re}${green}${PY_VERSION}${re}"
                    sleep 2
                else
                    clear
                    echo -e "${red}Python3安装失败！${re}"
                    exit 1
                fi
                cd /root/ && rm -rf Python-${PY_VERSION}.tgz && rm -rf Python-${PY_VERSION}
            ;;

            2)
             clear
                # 检查系统中是否存在nodejs
                if command -v node &>/dev/null; then
                    # 获取当前nodejs版本
                    current_version=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

                    # 获取最新nodejs版本
                    install jq
                    json_data=$(curl -s https://nodejs.org/dist/index.json)
                    latest_version=$(echo "$json_data" | jq -r '.[] | select(.lts != null) | .version' | head -n 1 | sed 's/^v//')
                    # echo "$latest_version"
                    if [ "$current_version" = "$latest_version" ]; then
                        echo -e "${yellow}当前版本${green}$current_version${yellow}已经是最新版${green}${latest_version}${yellow}，无需更新！${re}"
                        sleep 2
                        main_menu
                    else
                        # 如果不是最新版本
                        echo -e "${yellow}你的nodejs版本是${re}${red}${current_version}${re}，${yellow}最新版本是${purple}${latest_version}${re}"                                 
                        read -e -p $'\033[1;91m是否卸载旧版nodejs并安装最新版？[y/n]: \033[0m' confirm
                        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                                                       
                            remove nodejs
                            sleep 1

                            # 安装新版nodejs
                            install_nodejs
                        else
                            main_menu 
                        fi
                    fi

                else
                    install_nodejs
                    break_end
                fi           
                
            ;;

            3)
            clear
                # 获取最新版Go的版本
                html=$(curl -s https://go.dev/dl/)
                latest_version=$(echo "$html" | grep -oP 'go[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)    
                
                # 根据系统架构选择不同的下载链接
                architecture=$(uname -m)
                case "$architecture" in
                    x86_64|amd64)
                        latest_version_url="https://golang.org/dl/${latest_version}.linux-amd64.tar.gz"
                        ;;
                    x86)
                        latest_version_url="https://golang.org/dl/${latest_version}.linux-386.tar.gz"
                        ;;
                    arm64|aarch64)
                        latest_version_url="https://golang.org/dl/${latest_version}.linux-arm64.tar.gz"
                        ;;
                    *)
                        echo -e "${red}暂不支持的系统架构：$architecture${re}"
                        sleep 2
                        main_menu
                        ;;
                esac
                
                # 检查是否已安装Go
                if command -v go &> /dev/null; then
                    # 获取当前已安装的Go版本
                    installed_version=$(go version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+')
                    echo -e "${yellow}当前已安装的Go版本：${red}$installed_version${re}"
                
                    # 比较已安装版本与最新版本
                    if [ "$installed_version" = "$latest_version" ]; then
                        echo -e "${green}当前Go已经是最新版本，无需更新。${re}"
                        sleep 2
                        main_menu
                    elif [ "$(printf "$installed_version\n$latest_version" | sort -V | head -n 1)" != "$installed_version" ]; then
                        echo -e "${yellow}发现新版本：$latest_version。${re}"
                        read -e -p $'\033[1;91m需要卸载当前版本 $installed_version 并安装新版本 $latest_version 吗 [y/n]: \033[0m' confirm
                        
                        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                            echo "卸载旧版Go：$installed_version"
                            rm -rf /usr/local/go
                        else
                            echo -e "${yellow}退出更新。${re}"
                            sleep 2
                            break_end
                        fi
                    fi
                else
                    echo -e "${yellow}系统中未安装Go，正在为你安装最新版Go...${re}"
                fi
                
                # 下载并安装最新版Go
                install tar
                wget -O go_latest.tar.gz "$latest_version_url"
                tar -C /usr/local -xzf go_latest.tar.gz
                
                # 设置环境变量
                GO_PATH="/usr/local/go/bin"
                if [[ ":$PATH:" != *":${GO_PATH}:"* ]]; then
                    if grep -qi alpine /etc/os-release; then
                        echo "export PATH=${GO_PATH}:\$PATH" > /etc/profile.d/go.sh
                        chmod +x /etc/profile.d/go.sh
                        source /etc/profile.d/go.sh
                    else
                        echo "export PATH=${GO_PATH}:\$PATH" | tee -a /etc/profile > /dev/null
                        source /etc/profile
                    fi
                fi
                
                rm go_latest.tar.gz
                
                # 验证安装
                if command -v go &> /dev/null; then
                    echo -e "${green}GO安装完成，当前Go版本：${red}$(go version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | cut -c 3-)${re}"
                    echo -e "${red}退出脚本后请手动执行以下命令使全局环境变量生效：${yellow}source /etc/profile${re}\n"
                else
                    echo -e "${red}Go安装完成，但全局环境变量未生效，请退出脚本后手动执行以下命令使全局环境变量生效：${yellow}source /etc/profile${re}\n"
                fi
              sleep 1
              break_end
            ;;            

            4)
              clear
                latest_version="17.0.10"
                if command -v java &>/dev/null; then
                    installed_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
                    echo -e "${green}当前Java版本是${yellow}${installed_version},最新版本是${green}${latest_version}${re}"

                    if [ "$installed_version" == "$latest_version" ]; then
                        echo -e "${green}当前已安装Java最新版：${yellow}${latest_version},无需更新${re}"
                        sleep 2
                        main_menu
                    else
                        echo -e "${red}"
                        read -e -p "是否卸载旧版java并安装最新版？[y/n]: " confirm
                        if [[ $confirm =~ ^[Yy]$ ]]; then
                            # 卸载旧版java
                            remove java
                            sleep 2
                            install_java                           

                        else
                            main_menu 
                        fi   
                    fi

                else
                    install_java
                fi
            ;;

            5)
             clear
                if command -v python3 &>/dev/null; then
                    # 获取当前安装的python版本
                    current_version=$(python3 --version 2>&1 | awk '{print $2}')   

                    echo -e "${yellow}当前已安装python${red}${current_version}"

                    read -e -p $'\033[1;91m确定卸载python？[y/n]: \033[0m' confirm
                    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                    
                        # 卸载python3
                        remove python3

                        # 清理缓存配置文件
                        rm -rf /usr/bin/pip3
                        rm -rf /usr/bin/python3
                        rm -rf /usr/share/python3
                        rm -rf /usr/local/python3
                        rm -rf /usr/share/man/man1/python3.1.gz
                        rm -rf /usr/local/bin/python
                        rm -rf /usr/local/lib/python*
                        rm -rf /usr/local/bin/python*

                        echo -e "${green}python已卸载${re}"
                        break_end
                    else
                        main_menu
                    fi
                else
                    echo -e "${yellow}系统中未安装python，无需卸载${re}"
                    sleep 2
                    main_menu
                fi           
            ;;

            6)
             clear
                if command -v node &>/dev/null; then
                    # 获取当前安装的nodjs版本
                    current_version=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')    

                    echo -e "${yellow}当前已安装nodejs${red}$current_version${re}"
                            
                    read -e -p $'\033[1;91m确定卸载nodejs？[y/n]: \033[0m' confirm
                    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                        
                        # 卸载
                        remove nodejs npm 
         
                        # 清理缓存配置文件
                        rm -rf ~/.npm
                        rm -rf ~/.nvm
                        rm -rf /usr/local/bin/node
                        rm -rf /usr/local/lib/node_modules

                        echo -e "${green}nodejs已卸载${re}"
                        break_end
                    else
                        main_menu
                    fi
                else
                    echo -e "${yellow}系统中未安装nodejs，无需卸载${re}"
                    sleep 2
                    main_menu
                fi           
            ;;

            7)
             clear
                if command -v go &> /dev/null; then
                    # 获取当前安装的Go版本
                    installed_version=$(go version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | cut -c 3-)   

                    echo -e "${yellow}当前已安装Go：${red}$installed_version${re}"
                            
                    read -e -p $'\033[1;91m确定卸载Go？[y/n]: \033[0m' confirm
                    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then

                        rm -rf /usr/local/go

                        # 清理环境变量
                        export PATH=$PATH:/usr/local/go/bin
                        export GOPATH=$HOME/go
                        export PATH=$PATH:$GOPATH/bin
                        source ~/.bashrc && source ~/.profile && source ~/.bash_profile

                        echo -e "${green}Go已卸载${re}"
                        sleep 1
                        break_end

                    else
                        main_menu
                    fi
                else
                    echo -e "${yellow}系统中未安装Go，无需卸载${re}"
                    sleep 2
                    main_menu
                fi           
            ;;

            8)
             clear
                if command -v java &> /dev/null; then
                    # 获取当前安装的Java版本
                    installed_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
                    echo -e "${yellow}你的Java版本：${red}${installed_version}${re}"

                    read -e -p $'\033[1;91m确定卸载Java？[y/n]: \033[0m' confirm
                    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then

                        remove_java() {
                            local remove_status=0

                            if command -v apt &>/dev/null; then
                                apt remove -y openjdk-17-jdk && apt autoremove -y openjdk-17-jdk
                            elif command -v yum &>/dev/null; then
                                yum remove -y java && yum autoremove -y java
                            elif command -v dnf &>/dev/null; then
                                dnf remove -y java && dnf autoremove -y java
                            elif command -v apk &>/dev/null; then
                                apk del openjdk17
                            else
                                echo -e "${red}暂不支持你的系统！${re}"
                                exit 1
                            fi
                            # 检查是否安装成功，如果没有成功则重新
                            if [ $remove_status -eq 0 ]; then
                                echo -e "${green}Java卸载成功！${re}"
                            else                    
                                echo -e "${red}Java卸载失败，请重试!${re}"
                                break_end
                            fi
                        }
                        remove_java

                        rm -rf /usr/lib/jvm/java-*
                        rm -rf /usr/local/java
                        rm -rf /opt/java
                        echo -e "${red}"
                        read -e -p $'\033[1;91m重启服务器配置才可生效，需要立即重启吗 [y/n]: \033[0m' confirm

                        if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
                            sleep 1
                            reboot
                        else
                            main_menu
                        fi

                    else
                        main_menu
                    fi
                else
                    echo -e "${yellow}系统中未安装Java，无需卸载${re}"
                    sleep 2
                fi           
            ;;

            0)
                main_menu
            ;;

            *)
            echo -e "${yellow}无效的输入!${re}"
            ;;
        esac
    done
}

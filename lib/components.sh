#!/usr/bin/env bash
# 运行环境组件：Node.js、Java

install_nodejs(){
    if command -v node &>/dev/null; then
        # 获取当前已安装nodejs版本
        installed_version=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        echo -e "${green}系统中已经安装Nodejs,版本:${red}${installed_version}${re}"
    else
        echo -e "${yellow}系统中未安装nodejs，正在为你安装...${re}"

        # 根据对应系统安装nodejs
        if command -v apt &>/dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && install nodejs
        elif command -v dnf &>/dev/null; then
            dnf install -y nodejs npm
        elif command -v yum &>/dev/null; then
            curl -fsSL https://rpm.nodesource.com/setup_21.x | sudo bash - && install nodejs
        elif command -v apk &>/dev/null; then
            apk add nodejs npm
        else
            echo -e "${red}暂不支持你的系统!${re}"
            return 1
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${green}nodejs安装成功!${re}"
            sleep 2
        else
            echo -e "${red}nodejs安装失败，尝试再次安装...${re}"
            install nodejs npm
            sleep 2
        fi
    fi 
}

# 安装java

install_java() {
    if command -v java &>/dev/null; then
        # 检查安装版本
        installed_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        echo -e "${green}系统已经安装Java${yellow}${installed_version}${re}"     

    else
        echo -e "${yellow}系统中未安装Java，正在为你安装...${re}"

        local install_status=0

        if command -v apt &>/dev/null; then
            apt install -y openjdk-17-jdk
        elif command -v yum &>/dev/null; then
            yum install -y java-17-openjdk
        elif command -v dnf &>/dev/null; then
            dnf install -y java-17-openjdk
        elif command -v apk &>/dev/null; then
            apk add openjdk17
        else
            echo -e "${red}暂不支持你的系统！${re}"
            exit 1
        fi

        if [ $install_status -eq 0 ]; then
            echo -e "${green}Java安装成功${re}"
            sleep 2
            break_end
        else                    
            echo -e "${red}Java安装失败，尝试为你再次安装...${re}"
            install java-17-openjdk
            sleep 2
            break_end
        fi
    fi   
}


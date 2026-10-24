#!/usr/bin/env bash
# 公共函数：依赖安装、返回/重载、端口检查、Docker 与防火墙基础操作

ip_address() {
    ipv4_address=$(curl -s -m 2 ipv4.ip.sb)
    ipv6_address=$(curl -s -m 2 ipv6.ip.sb)
}

# 安装依赖包

install() {
    if [ $# -eq 0 ]; then
        echo -e "${red}未提供软件包参数!${re}"
        return 1
    fi

    local package failed=0
    for package in "$@"; do
        if command -v "$package" &>/dev/null; then
            echo -e "${green}${package}已经安装了！${re}"
            continue
        fi
        echo -e "${yellow}正在安装 ${package}...${re}"
        if command -v apt &>/dev/null; then
            DEBIAN_FRONTEND=noninteractive apt install -y "$package" || failed=1
        elif command -v dnf &>/dev/null; then
            dnf install -y "$package" || failed=1
        elif command -v yum &>/dev/null; then
            yum install -y "$package" || failed=1
        elif command -v pacman &>/dev/null; then
            pacman -S --noconfirm --needed "$package" || failed=1
        elif command -v zypper &>/dev/null; then
            zypper install -y "$package" || failed=1
        elif command -v apk &>/dev/null; then
            apk add "$package" || failed=1
        elif command -v opkg &>/dev/null; then
            opkg update && opkg install "$package" || failed=1
        elif command -v pkg &>/dev/null; then
            pkg install -y "$package" || failed=1
        else
            echo -e "${red}暂不支持你的系统!${re}"
            return 1
        fi
        if [ "$failed" = "1" ]; then
            echo -e "${red}${package} 安装失败，请检查软件源${re}"
        fi
    done

    return "$failed"
}

# 卸载依赖包

remove() {
    if [ $# -eq 0 ]; then
        echo -e "${red}未提供软件包参数!${re}"
        return 1
    fi

    local package failed=0
    for package in "$@"; do
        if command -v apt &>/dev/null; then
            apt purge -y "$package" || failed=1
        elif command -v dnf &>/dev/null; then
            dnf remove -y "$package" || failed=1
        elif command -v yum &>/dev/null; then
            yum remove -y "$package" || failed=1
        elif command -v pacman &>/dev/null; then
            pacman -Rns --noconfirm "$package" || failed=1
        elif command -v zypper &>/dev/null; then
            zypper remove -y "$package" || failed=1
        elif command -v apk &>/dev/null; then
            apk del "$package" || failed=1
        elif command -v opkg &>/dev/null; then
            opkg remove "$package" || failed=1
        elif command -v pkg &>/dev/null; then
            pkg delete -y "$package" || failed=1
        else
            echo -e "${red}暂不支持你的系统!${re}"
            return 1
        fi
    done

    return "$failed"
}

# 安装nodejs

install_dependency() {
      clear
      install wget socat unzip tar
}

# 等待用户返回

break_end() {
    echo -e "${green}执行完成${re}"
    echo -e "${yellow}按任意键返回...${re}"
    read -n 1 -s -r -p ""
    echo ""
    clear
}

# 返回主菜单：重新加载本地入口脚本（不依赖远程下载）
main_menu() {
    cd ~
    exec bash "${VPS_TOOLBOX_ENTRY}"
}


check_port() {
    # 定义要检测的端口
    PORT=443

    # 检查端口占用情况
    result=$(ss -tulpn | grep ":$PORT")

    # 判断结果并输出相应信息
    if [ -n "$result" ]; then
        is_nginx_container=$(docker ps --format '{{.Names}}' | grep 'nginx')

        # 判断是否是Nginx容器占用端口
        if [ -n "$is_nginx_container" ]; then
            echo ""
        else
            clear
            echo -e "\e[1;31m端口 $PORT 已被占用，无法安装环境，卸载以下程序后重试！\e[0m"
            echo "$result"
            break_end
            main_menu
        fi
    else
        echo ""
    fi
}


# 定义安装 Docker 的函数

install_docker() {
    if ! command -v docker &>/dev/null; then
        curl -fsSL https://get.docker.com | sh && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin
        systemctl start docker
        systemctl enable docker
    else
        echo "Docker 已经安装"
    fi
}


iptables_open() {
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
}


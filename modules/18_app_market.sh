#!/usr/bin/env bash
# vps-toolbox 模块：应用市场
# 应用目录来自 kejilion/apps（Apache-2.0），运行时同步到本地后按配置安装
# 兼容 app 配置约定的 docker_app_plus / check_docker_app_ip 等入口

APP_CATALOG_SYNC_FAILED=0
# 兼容 0.2.0 升级上来的本机 branding：缺少这些键时使用内置默认值
APP_CATALOG_REPO="${APP_CATALOG_REPO:-https://github.com/kejilion/apps.git}"
APP_CATALOG_DIR="${APP_CATALOG_DIR:-$HOME/apps}"

app_market_field() {
    local line
    line=$(grep -m1 -E "^[[:space:]]*(local[[:space:]]+)?$2=" "$1" 2>/dev/null) || return 0
    line="${line#*=}"
    if [[ "$line" =~ ^\"([^\"]*)\" ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^\'([^\']*)\' ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
    else
        printf '%s\n' "${line%%[[:space:]]*}"
    fi
}

app_market_id_installed() {
    [ -n "$1" ] && grep -qx "$1" /home/docker/appno.txt 2>/dev/null
}

app_market_add_id() {
    mkdir -p /home/docker
    touch /home/docker/appno.txt
    grep -qx "$app_id" /home/docker/appno.txt 2>/dev/null || echo "$app_id" >> /home/docker/appno.txt
}

app_market_remove_id() {
    [ -f /home/docker/appno.txt ] && sed -i "/^${app_id}$/d" /home/docker/appno.txt 2>/dev/null
    return 0
}

app_market_container_exists() {
    command -v docker >/dev/null 2>&1 || return 1
    docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "$1"
}

app_market_port_in_use() {
    local port="$1"
    command -v ss >/dev/null 2>&1 || return 1
    ss -tuln 2>/dev/null | awk '{print $5}' | grep -qE "[:.]${port}$"
}

kpanel_app_port_in_use() {
    app_market_port_in_use "$1"
}

app_market_catalog_sync() {
    local dir="$APP_CATALOG_DIR" out stamp force="${1:-0}"
    APP_CATALOG_SYNC_FAILED=0
    install git >/dev/null 2>&1 || { echo -e "${red}git 安装失败，无法同步应用列表${re}"; return 1; }

    if [ -e "$dir" ] && [ ! -d "$dir/.git" ]; then
        echo -e "${red}${dir} 已存在但不是应用目录仓库，拒绝覆盖${re}"
        return 1
    fi

    if [ -d "$dir/.git" ]; then
        stamp="$dir/.vps-toolbox-sync"
        if [ "$force" != "1" ] && [ -n "$(find "$stamp" -mmin -1440 2>/dev/null)" ]; then
            return 0
        fi
        echo -e "${yellow}正在检查应用列表更新...${re}"
        if ! out=$(timeout 45s git -C "$dir" pull --ff-only 2>&1); then
            echo -e "${yellow}应用列表更新失败，继续使用本地已有版本${re}"
            APP_CATALOG_SYNC_FAILED=1
        fi
        date +%s > "$stamp" 2>/dev/null || true
        return 0
    fi

    mkdir -p "$(dirname "$dir")"
    echo -e "${yellow}正在下载应用列表（最长 90 秒）...${re}"
    if ! timeout 90s git clone --depth=1 "$APP_CATALOG_REPO" "$dir"; then
        echo -e "${red}应用列表下载失败${re}"
        return 1
    fi
    date +%s > "$dir/.vps-toolbox-sync" 2>/dev/null || true
    return 0
}

app_market_load_catalog() {
    APP_CONF_FILES=()
    APP_IDS=()
    local conf id
    for conf in "$APP_CATALOG_DIR"/*.conf; do
        [ -f "$conf" ] || continue
        id=$(app_market_field "$conf" app_id)
        [ -n "$id" ] || id=$(basename "$conf" .conf)
        APP_CONF_FILES+=("$conf")
        APP_IDS+=("$id")
    done
}

app_market_choose_port() {
    local input
    echo "默认端口: ${docker_port}"
    read -e -p "安装端口（回车使用默认）: " input
    input="${input:-$docker_port}"
    if ! [[ "$input" =~ ^[0-9]+$ ]] || [ "$input" -lt 1 ] || [ "$input" -gt 65535 ]; then
        echo -e "${red}端口无效${re}"
        return 1
    fi
    if app_market_port_in_use "$input"; then
        echo -e "${red}端口 ${input} 已被占用${re}"
        return 1
    fi
    docker_port="$input"
    return 0
}

check_docker_app_ip() {
    local port="${docker_port:-}"
    [ -n "$port" ] || port=$(cat "/home/docker/${docker_name}_port.conf" 2>/dev/null)
    ip_address
    echo "------------------------"
    echo "访问地址:"
    [ -n "$ipv4_address" ] && echo "http://${ipv4_address}:${port}"
    [ -n "$ipv6_address" ] && echo "http://[${ipv6_address}]:${port}"
    local conf
    for conf in /home/web/conf.d/*.conf; do
        [ -f "$conf" ] || continue
        if grep -q ":${port}[ ;]" "$conf" 2>/dev/null; then
            echo "https://$(basename "$conf" .conf)"
        fi
    done
}

app_market_install_flow() {
    app_market_choose_port || return 1
    echo -e "${yellow}正在安装 ${app_name}...${re}"
    install jq >/dev/null 2>&1
    install_docker || { echo -e "${red}Docker 安装失败${re}"; return 1; }
    mkdir -p /home/docker
    if docker_app_install; then
        echo "$docker_port" > "/home/docker/${docker_name}_port.conf"
        app_market_add_id
        echo -e "${green}${app_name} 安装完成${re}"
        check_docker_app_ip
        return 0
    fi
    echo -e "${red}安装失败，未登记应用状态，请根据上方错误修复后重试${re}"
    return 1
}

app_market_update_flow() {
    echo -e "${yellow}正在更新 ${app_name}...${re}"
    if docker_app_update; then
        app_market_add_id
        echo -e "${green}${app_name} 更新完成${re}"
        check_docker_app_ip
        return 0
    fi
    echo -e "${red}更新失败，已保留原应用登记状态${re}"
    return 1
}

app_market_uninstall_flow() {
    local confirm
    read -e -r -p "确认卸载 ${app_name}？相关数据会一并删除 [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "${yellow}已取消${re}"; return 0; }
    if docker_app_uninstall; then
        rm -f "/home/docker/${docker_name}_port.conf" "/home/docker/${docker_name}_access.conf"
        app_market_remove_id
        echo -e "${green}${app_name} 已卸载${re}"
        return 0
    fi
    echo -e "${red}卸载失败，已保留应用登记状态${re}"
    return 1
}

app_market_add_domain() {
    if [ ! -d /home/web/conf.d ] || ! app_market_container_exists nginx; then
        echo -e "${red}未检测到 LDNMP 建站环境，请先安装建站环境${re}"
        return 1
    fi
    add_yuming
    [ -n "$yuming" ] || { echo -e "${red}域名不能为空${re}"; return 1; }
    duankou="$docker_port"
    reverse_proxy
    echo -e "${green}已添加 https://${yuming}${re}"
}

app_market_del_domain() {
    local domain conf
    read -e -p "请输入要删除的域名: " domain
    conf="/home/web/conf.d/${domain}.conf"
    if [ -z "$domain" ] || [ ! -f "$conf" ]; then
        echo -e "${red}未找到该域名的反代配置${re}"
        return 1
    fi
    rm -f "$conf"
    app_market_container_exists nginx && docker restart nginx >/dev/null 2>&1
    echo -e "${green}已删除 ${domain} 的域名访问${re}"
}

docker_app_plus() {
    local container="${docker_app_service:-$docker_name}"
    local port_file="/home/docker/${docker_name}_port.conf"
    if [ -z "$docker_name" ]; then
        echo -e "${red}应用配置缺少 docker_name${re}"
        return 1
    fi

    while true; do
        clear
        echo "▶ ${app_name:-$docker_name}"
        [ -n "$app_text" ] && echo "$app_text"
        [ -n "$app_url" ] && echo "$app_url"
        echo "------------------------"
        local shown_port=""
        if app_market_container_exists "$container"; then
            shown_port=$(cat "$port_file" 2>/dev/null)
            if [ -z "$shown_port" ]; then
                shown_port=$(docker port "$container" 2>/dev/null | head -n1 | awk -F: '/->/ {print $NF; exit}')
                [ -n "$shown_port" ] && echo "$shown_port" > "$port_file"
            fi
            docker_port="${shown_port:-$docker_port}"
            echo -e "状态: ${green}已安装${re}"
            check_docker_app_ip
        else
            echo -e "状态: ${yellow}未安装${re}    默认端口: ${docker_port}"
        fi
        echo "------------------------"
        echo "1. 安装            2. 更新            3. 卸载"
        echo "5. 添加域名访问    6. 删除域名访问"
        echo "------------------------"
        echo -e "${skyblue}0. 返回应用列表${re}"
        echo "------------------------"
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice || return 0

        case "$sub_choice" in
            1) app_market_install_flow ;;
            2) app_market_update_flow ;;
            3) app_market_uninstall_flow ;;
            5) app_market_add_domain ;;
            6) app_market_del_domain ;;
            0) return 0 ;;
            *) echo -e "${red}无效的输入!${re}" ;;
        esac
        break_end
    done
}

app_market_open() {
    local conf="$1"
    if [ ! -f "$conf" ]; then
        echo -e "${red}应用配置不存在: ${conf}${re}"
        return 1
    fi
    echo "配置文件: ${conf}"
    echo -e "${yellow}该配置来自第三方应用目录，将以 root 权限在本机执行${re}"
    confirm_action "确认打开该应用？" || { echo -e "${yellow}已取消${re}"; return 0; }
    # 配置在函数作用域内 source：local 变量与末尾的 docker_app_plus 调用都依赖这一点
    source "$conf"
}

app_market_open_by_id() {
    local id="$1" conf i
    case "$id" in
        ''|*..*|*[!A-Za-z0-9._-]*)
            echo -e "${red}无效的应用 ID: ${id}${re}"
            return 1
            ;;
    esac
    conf="${APP_CATALOG_DIR}/${id}.conf"
    if [ ! -f "$conf" ]; then
        for i in "${!APP_IDS[@]}"; do
            if [ "${APP_IDS[i]}" = "$id" ]; then
                conf="${APP_CONF_FILES[i]}"
                break
            fi
        done
    fi
    app_market_open "$conf"
}

app_market_backup() {
    local file confirm
    file="/app_$(date +%Y%m%d%H%M%S).tar.gz"
    echo -e "${yellow}将打包 /home（含全部 Docker 应用数据），可能耗时较长${re}"
    read -e -r -p "确认备份？[y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "${yellow}已取消${re}"; return 0; }
    echo "正在打包到 ${file} ..."
    if tar czf "$file" -C / home; then
        echo -e "${green}备份完成: ${file}${re}"
    else
        rm -f "$file"
        echo -e "${red}备份失败${re}"
    fi
}

app_market_restore() {
    local file confirm
    echo "可用备份:"
    echo "------------------------"
    ls -1t /app*.tar.gz 2>/dev/null || { echo -e "${yellow}暂无备份文件${re}"; return 0; }
    echo "------------------------"
    read -e -p "输入备份文件路径（回车使用最新）: " file
    [ -n "$file" ] || file=$(ls -1t /app*.tar.gz 2>/dev/null | head -n1)
    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo -e "${red}备份文件不存在${re}"
        return 1
    fi
    case "$file" in
        /*) ;;
        *) echo -e "${red}请使用绝对路径${re}"; return 1 ;;
    esac
    if ! tar -tzf "$file" >/dev/null 2>&1; then
        echo -e "${red}备份文件无效或已损坏${re}"
        return 1
    fi
    echo -e "${red}还原会覆盖 /home 下的同名文件，请确认已完成当前数据备份${re}"
    read -e -r -p "确认还原 ${file}？[y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "${yellow}已取消${re}"; return 0; }
    if tar xzf "$file" -C /; then
        echo -e "${green}还原完成，请进入对应应用执行一次更新以恢复服务${re}"
    else
        echo -e "${red}还原失败${re}"
    fi
}

menu_app_market() {
    local synced=0
    if app_market_catalog_sync; then
        synced=1
    fi
    app_market_load_catalog

    while true; do
        clear
        echo "▶ 应用市场"
        echo "应用目录: ${APP_CATALOG_DIR}"
        if [ "$synced" = "0" ]; then
            echo -e "${yellow}目录同步失败，当前使用本地已有应用列表${re}"
        elif [ "$APP_CATALOG_SYNC_FAILED" = "1" ]; then
            echo -e "${yellow}在线更新失败，当前使用本地已有应用列表${re}"
        fi
        echo "共 ${#APP_CONF_FILES[@]} 个应用，应用由第三方目录提供，配置将以 root 权限在本机执行"
        if [ "${#APP_CONF_FILES[@]}" -eq 0 ]; then
            echo -e "${red}未找到应用配置，请检查网络或应用目录: ${APP_CATALOG_DIR}${re}"
        fi
        echo "------------------------"
        local i name state
        for i in "${!APP_CONF_FILES[@]}"; do
            name=$(app_market_field "${APP_CONF_FILES[i]}" app_name)
            [ -n "$name" ] || name="${APP_IDS[i]}"
            state=""
            app_market_id_installed "${APP_IDS[i]}" && state=" ${green}[已安装]${re}"
            printf "%2d. %s%b\n" "$((i + 1))" "$name" "$state"
        done
        echo "------------------------"
        echo "u. 更新应用列表    b. 备份全部应用    r. 还原应用备份"
        echo "------------------------"
        echo -e "${skyblue}0. 返回主菜单${re}"
        echo "------------------------"
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice || return 0

        case "$sub_choice" in
            0)
                main_menu
                ;;
            u|U)
                clear
                app_market_catalog_sync 1 && app_market_load_catalog
                break_end
                ;;
            b|B)
                clear
                app_market_backup
                break_end
                ;;
            r|R)
                clear
                app_market_restore
                break_end
                ;;
            '')
                ;;
            *[!0-9]*)
                clear
                app_market_open_by_id "$sub_choice"
                break_end
                ;;
            *)
                i=$((10#$sub_choice))
                if [ "$i" -ge 1 ] && [ "$i" -le "${#APP_CONF_FILES[@]}" ]; then
                    clear
                    app_market_open "${APP_CONF_FILES[i - 1]}"
                else
                    echo -e "${red}无效的编号!${re}"
                    sleep 1
                fi
                break_end
                ;;
        esac
    done
}

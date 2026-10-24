#!/usr/bin/env bash
# vps-toolbox 模块：服务器集群控制
# 服务器清单保存在 ~/cluster/servers.conf（name|host|port|user|password），批量命令按行顺序执行

CLUSTER_DIR="${CLUSTER_DIR:-$HOME/cluster}"
CLUSTER_FILE="${CLUSTER_DIR}/servers.conf"
CLUSTER_LINES=()

cluster_init() {
    mkdir -p "$CLUSTER_DIR" && chmod 700 "$CLUSTER_DIR"
    if [ ! -f "$CLUSTER_FILE" ]; then
        printf '# 格式: 名称|IP或域名|端口|用户|密码（密码留空则使用 SSH 密钥）\n' > "$CLUSTER_FILE"
        chmod 600 "$CLUSTER_FILE"
    fi
}

cluster_rows() {
    grep -v '^[[:space:]]*#' "$CLUSTER_FILE" 2>/dev/null | grep -v '^[[:space:]]*$'
}

cluster_load() {
    CLUSTER_LINES=()
    mapfile -t CLUSTER_LINES < <(cluster_rows)
}

cluster_count() {
    cluster_rows | wc -l
}

cluster_list() {
    cluster_load
    local i line name host port user
    echo "服务器列表（${CLUSTER_FILE}）"
    echo "------------------------"
    if [ "${#CLUSTER_LINES[@]}" -eq 0 ]; then
        echo -e "${yellow}暂无服务器${re}"
        return 0
    fi
    for i in "${!CLUSTER_LINES[@]}"; do
        IFS='|' read -r name host port user _ <<< "${CLUSTER_LINES[i]}"
        printf "%2d. %-16s %s:%s  %s\n" "$((i + 1))" "${name:-未命名}" "$host" "${port:-22}" "${user:-root}"
    done
}

cluster_add() {
    local name host port user pass
    read -e -p "服务器名称: " name
    read -e -p "服务器 IP 或域名: " host
    if [ -z "$host" ]; then
        echo -e "${red}主机地址不能为空${re}"
        return 1
    fi
    read -e -p "SSH 端口 [22]: " port
    port="${port:-22}"
    [[ "$port" =~ ^[0-9]+$ ]] || { echo -e "${red}端口无效${re}"; return 1; }
    read -e -p "SSH 用户 [root]: " user
    user="${user:-root}"
    read -r -s -p "SSH 密码（留空使用密钥）: " pass
    echo ""
    if [[ "$name$host$user$pass" == *"|"* ]]; then
        echo -e "${red}字段中不能包含 | 字符${re}"
        return 1
    fi
    printf '%s|%s|%s|%s|%s\n' "$name" "$host" "$port" "$user" "$pass" >> "$CLUSTER_FILE"
    echo -e "${green}已添加 ${name:-$host}${re}"
    [ -n "$pass" ] && echo -e "${yellow}密码以明文保存在 ${CLUSTER_FILE}，建议改用 SSH 密钥${re}"
    return 0
}

cluster_delete() {
    local target tmp
    cluster_list
    echo "------------------------"
    read -e -p "输入要删除的序号或匹配关键字（回车取消）: " target
    [ -n "$target" ] || { echo -e "${yellow}已取消${re}"; return 0; }
    cluster_load
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        if [ "$((10#$target))" -lt 1 ] || [ "$((10#$target))" -gt "${#CLUSTER_LINES[@]}" ]; then
            echo -e "${red}序号超出范围${re}"
            return 1
        fi
        tmp=$(mktemp)
        awk -v drop="$((10#$target))" 'BEGIN { idx = 0 }
            /^[[:space:]]*#/ || /^[[:space:]]*$/ { print; next }
            { idx++; if (idx != drop) print }' "$CLUSTER_FILE" > "$tmp" && mv "$tmp" "$CLUSTER_FILE"
        echo -e "${green}已删除第 ${target} 条记录${re}"
        return 0
    fi
    tmp=$(mktemp)
    grep -v -F -- "$target" "$CLUSTER_FILE" > "$tmp" || true
    local affected
    affected=$(grep -F -c -- "$target" "$CLUSTER_FILE" 2>/dev/null || echo 0)
    read -e -r -p "将删除 ${affected} 条匹配记录，确认？[y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        mv "$tmp" "$CLUSTER_FILE"
        echo -e "${green}已删除包含 ${target} 的记录${re}"
    else
        rm -f "$tmp"
        echo -e "${yellow}已取消${re}"
    fi
    return 0
}

cluster_edit() {
    if command -v nano >/dev/null 2>&1; then
        nano "$CLUSTER_FILE"
    elif command -v vi >/dev/null 2>&1; then
        vi "$CLUSTER_FILE"
    else
        echo -e "${red}未找到可用的编辑器，请手动编辑 ${CLUSTER_FILE}${re}"
        return 1
    fi
    chmod 600 "$CLUSTER_FILE"
}

cluster_run() {
    local cmd="$1"
    local line name host port user pass rc=0
    cluster_init
    if [ "$(cluster_count)" -eq 0 ]; then
        echo -e "${yellow}请先添加服务器${re}"
        return 1
    fi

    if cluster_rows | awk -F'|' '$5 != "" { found = 1 } END { exit !found }'; then
        if ! command -v sshpass >/dev/null 2>&1; then
            echo -e "${yellow}检测到密码登录，正在安装 sshpass...${re}"
            install sshpass || { echo -e "${red}sshpass 安装失败${re}"; return 1; }
        fi
    fi

    while IFS='|' read -r name host port user pass; do
        [ -n "$host" ] || continue
        echo ""
        echo -e "${skyblue}==> ${name:-$host} (${host}:${port:-22})${re}"
        if [ -n "$pass" ]; then
            sshpass -p "$pass" ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 \
                -p "${port:-22}" "${user:-root}@${host}" "$cmd"
        else
            ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 \
                -p "${port:-22}" "${user:-root}@${host}" "$cmd"
        fi
        if [ $? -eq 0 ]; then
            echo -e "${green}成功${re}"
        else
            echo -e "${red}失败${re}"
            rc=1
        fi
    done < <(cluster_rows)
    return "$rc"
}

cluster_run_custom() {
    local cmd
    read -e -p "请输入要在所有服务器执行的命令: " cmd
    [ -n "$cmd" ] || { echo -e "${red}命令不能为空${re}"; return 1; }
    echo -e "${red}即将在所有服务器执行: ${cmd}${re}"
    read -e -r -p "确认执行？[y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "${yellow}已取消${re}"; return 0; }
    cluster_run "$cmd"
}

menu_cluster() {
    cluster_init
    while true; do
        clear
        echo "▶ 服务器集群控制"
        echo "配置: ${CLUSTER_FILE}（格式 名称|地址|端口|用户|密码）"
        echo "共 $(cluster_count) 台服务器"
        echo "------------------------"
        echo " 1. 查看服务器        2. 添加服务器       3. 删除服务器"
        echo " 4. 编辑配置文件      5. 测试连接"
        echo "------------------------"
        echo "11. 更新系统         12. 清理系统        13. 安装 Docker"
        echo "14. 开放全部端口     15. 设置时区        16. 重启服务器"
        echo "17. 自定义命令"
        echo "------------------------"
        echo -e "${skyblue} 0. 返回主菜单${re}"
        echo "------------------------"
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice || return 0

        case "$sub_choice" in
            0) main_menu ;;
            1) clear; cluster_list; break_end ;;
            2) clear; cluster_add; break_end ;;
            3) clear; cluster_delete; break_end ;;
            4) clear; cluster_edit ;;
            5) clear; cluster_run 'echo connected: $(hostname) $(uptime -p 2>/dev/null || uptime)'; break_end ;;
            11)
                clear
                cluster_run 'if command -v apt >/dev/null 2>&1; then apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y; elif command -v dnf >/dev/null 2>&1; then dnf upgrade -y; elif command -v yum >/dev/null 2>&1; then yum update -y; elif command -v apk >/dev/null 2>&1; then apk update && apk upgrade; else echo "不支持的系统"; exit 1; fi'
                break_end
                ;;
            12)
                clear
                cluster_run 'if command -v apt >/dev/null 2>&1; then apt autoremove -y && apt clean; elif command -v dnf >/dev/null 2>&1; then dnf autoremove -y; elif command -v yum >/dev/null 2>&1; then yum autoremove -y; fi; command -v docker >/dev/null 2>&1 && docker system prune -af >/dev/null; journalctl --vacuum-time=3d >/dev/null 2>&1; echo done'
                break_end
                ;;
            13)
                clear
                cluster_run 'command -v docker >/dev/null 2>&1 && echo "Docker 已安装" || curl -fsSL https://get.docker.com | sh'
                break_end
                ;;
            14)
                clear
                cluster_run 'iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT; iptables -F; echo "端口已全部开放"'
                break_end
                ;;
            15)
                clear
                cluster_run 'timedatectl set-timezone Asia/Shanghai 2>/dev/null || ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; date'
                break_end
                ;;
            16)
                clear
                read -e -r -p "确认重启所有服务器？[y/N]: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    cluster_run 'reboot'
                else
                    echo -e "${yellow}已取消${re}"
                fi
                break_end
                ;;
            17) clear; cluster_run_custom; break_end ;;
            *) echo -e "${red}无效的输入!${re}"; sleep 1 ;;
        esac
    done
}

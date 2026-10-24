#!/usr/bin/env bash
# vps-toolbox 模块：脚本更新
# 参考 kejilion/sh 的更新流程：下载到临时目录 -> 校验 -> 备份 -> 替换 -> 失败回滚

show_changelog() {
    if [ -f "${VPS_TOOLBOX_ROOT}/CHANGELOG.md" ]; then
        head -40 "${VPS_TOOLBOX_ROOT}/CHANGELOG.md"
    else
        echo "未找到 CHANGELOG.md"
    fi
}

# 版本号比较：$1 < $2 时返回 0（版本号已校验为 X.Y.Z 数字）
update_version_lt() {
    local IFS='.'
    local i a b
    a=($1)
    b=($2)
    for i in 0 1 2; do
        [ "${a[i]:-0}" -lt "${b[i]:-0}" ] && return 0
        [ "${a[i]:-0}" -gt "${b[i]:-0}" ] && return 1
    done
    return 1
}

# 把新版 branding 中本地缺少的默认配置追加到本地文件（不覆盖已有配置）
merge_missing_branding_keys() {
    local target="$1" defaults="$2" line key
    [ -f "$target" ] && [ -f "$defaults" ] || return 0
    [ -n "$(tail -c 1 "$target" 2>/dev/null)" ] && printf '\n' >> "$target"
    while IFS= read -r line; do
        [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)= ]] || continue
        key="${BASH_REMATCH[1]}"
        if ! grep -qE "^[[:space:]]*(export[[:space:]]+)?${key}=" "$target"; then
            printf '%s\n' "$line" >> "$target"
        fi
    done < "$defaults"
}

# 删除目标目录中源目录已不存在的 lib/modules/scripts 文件，避免升级后旧模块仍被加载
update_remove_stale_files() {
    local src="$1" dst="$2" dir f rel
    for dir in lib modules scripts; do
        [ -d "${dst}/${dir}" ] || continue
        for f in "${dst}/${dir}"/*; do
            [ -f "$f" ] || continue
            rel="${f#"${dst}"/}"
            [ -e "${src}/${rel}" ] || rm -f "$f"
        done
    done
}

update_restore_tree() {
    update_remove_stale_files "$1" "${VPS_TOOLBOX_ROOT}"
    cp -a "$1"/. "${VPS_TOOLBOX_ROOT}"/
}

update_fix_permissions() {
    chmod +x "${VPS_TOOLBOX_ROOT}/vps-toolbox.sh" "${VPS_TOOLBOX_ROOT}/install.sh" 2>/dev/null
    if [ -d "${VPS_TOOLBOX_ROOT}/scripts" ]; then
        find "${VPS_TOOLBOX_ROOT}/scripts" -name '*.sh' -exec chmod +x {} \; 2>/dev/null
    fi
}

update_curl_hint() {
    case "$1" in
        6)  echo "DNS 解析失败" ;;
        7)  echo "无法连接（被拒绝或网络不通）" ;;
        22) echo "请求被中断或返回错误" ;;
        28) echo "超时" ;;
        35) echo "TLS 握手失败（可能被干扰）" ;;
        56) echo "连接被重置" ;;
        *)  echo "curl 退出码 $1" ;;
    esac
}

# 下载更新包：先直连 GitHub，失败或超时后自动回退镜像
update_download_archive() {
    local archive="$1" base label rc start elapsed total=0
    local bases=("${PROJECT_REPO_URL}")
    if [ -n "${PROJECT_GH_PROXY:-}" ]; then
        bases+=("${PROJECT_GH_PROXY%/}/${PROJECT_REPO_URL}")
    fi
    for base in "${bases[@]}"; do
        if [ "$base" = "${PROJECT_REPO_URL}" ]; then
            label="GitHub 直连"
        else
            label="镜像 ${PROJECT_GH_PROXY}"
        fi
        echo "正在从 ${label} 下载..."
        start=$SECONDS
        rc=0
        curl -fsSL --connect-timeout "${PROJECT_CONNECT_TIMEOUT:-10}" \
            --max-time "${PROJECT_DOWNLOAD_TIMEOUT:-60}" \
            -o "${archive}.part" "${base}/archive/refs/heads/${PROJECT_BRANCH}.tar.gz" || rc=$?
        elapsed=$((SECONDS - start))
        total=$((total + elapsed))
        if [ "$rc" -eq 0 ] && tar -tzf "${archive}.part" >/dev/null 2>&1; then
            mv -f "${archive}.part" "$archive"
            if [ "$elapsed" -ge "${PROJECT_SLOW_SECONDS:-20}" ]; then
                echo -e "${yellow}提示：${label} 耗时 ${elapsed} 秒，网络较慢${re}"
            fi
            UPDATE_DL_LABEL="$label"
            UPDATE_DL_SECONDS=$total
            return 0
        fi
        rm -f "${archive}.part"
        if [ "$rc" -eq 28 ]; then
            echo -e "${yellow}${label} 下载超时（上限 ${PROJECT_DOWNLOAD_TIMEOUT:-60} 秒）${re}"
        elif [ "$rc" -ne 0 ]; then
            echo -e "${yellow}${label} 下载失败：$(update_curl_hint "$rc")（耗时 ${elapsed} 秒）${re}"
        else
            echo -e "${yellow}${label} 返回的安装包不完整${re}"
        fi
    done
    UPDATE_DL_SECONDS=$total
    return 1
}


menu_update_self() {
    clear
    echo "▶ 脚本更新"
    echo "当前版本: ${PROJECT_VERSION}"
    echo "------------------------"

    if [ -z "${PROJECT_REPO_URL}" ]; then
        echo -e "${yellow}未配置更新源（lib/branding.sh 中的 PROJECT_REPO_URL），仅显示更新日志${re}"
        echo ""
        show_changelog
        return 0
    fi

    if [ -d "${VPS_TOOLBOX_ROOT}/.git" ]; then
        echo -e "${yellow}当前是 git 开发目录，请使用 git pull 更新${re}"
        return 0
    fi

    local tmp_dir archive new_version backup confirm
    tmp_dir="$(mktemp -d)"
    archive="${tmp_dir}/update.tar.gz"

    if ! update_download_archive "$archive"; then
        rm -rf "$tmp_dir"
        echo -e "${red}下载失败，已保留当前版本${re}"
        echo "可能原因：服务器无法访问 GitHub（国内节点常见）、DNS 异常或没有出网。"
        echo "可尝试："
        if [ -n "${PROJECT_GH_PROXY:-}" ]; then
            echo "  1) 换镜像：export PROJECT_GH_PROXY=https://你的镜像 后重试（当前 ${PROJECT_GH_PROXY}）"
        else
            echo "  1) 配置镜像：在 lib/branding.sh 设置 PROJECT_GH_PROXY=\"https://ghfast.top\""
        fi
        echo "  2) 使用代理：export https_proxy=http://127.0.0.1:端口 后重试"
        echo "  3) 无外网：手动上传新版覆盖 ${VPS_TOOLBOX_ROOT}"
        return 1
    fi
    if [ "$UPDATE_DL_SECONDS" -ge 30 ]; then
        echo -e "${yellow}提示：本次下载共耗时 ${UPDATE_DL_SECONDS} 秒，网络较慢${re}"
    fi

    if ! tar -xzf "$archive" -C "$tmp_dir" --strip-components=1 2>/dev/null || [ ! -f "${tmp_dir}/vps-toolbox.sh" ]; then
        rm -rf "$tmp_dir"
        echo -e "${red}更新包校验失败，已保留当前版本${re}"
        return 1
    fi
    rm -f "$archive"

    new_version=$(grep -m1 '^PROJECT_VERSION=' "${tmp_dir}/lib/branding.sh" | cut -d'"' -f2)
    if ! [[ "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        rm -rf "$tmp_dir"
        echo -e "${red}更新包版本信息无效，已保留当前版本${re}"
        return 1
    fi
    if [ "$new_version" = "$PROJECT_VERSION" ]; then
        rm -rf "$tmp_dir"
        echo -e "${green}当前已是最新版本 v${PROJECT_VERSION}${re}"
        echo ""
        show_changelog
        return 0
    fi
    if update_version_lt "$new_version" "$PROJECT_VERSION"; then
        if [ "${VPS_TOOLBOX_ALLOW_DOWNGRADE:-0}" != "1" ]; then
            rm -rf "$tmp_dir"
            echo -e "${red}远端版本 v${new_version} 低于当前 v${PROJECT_VERSION}，已取消以免降级${re}"
            echo "如确实需要降级，请设置 VPS_TOOLBOX_ALLOW_DOWNGRADE=1 后重试"
            return 1
        fi
        echo -e "${yellow}注意：将降级到 v${new_version}${re}"
    fi

    if [ "${VPS_TOOLBOX_CLI:-0}" != "1" ]; then
        read -e -r -p "确认更新到 v${new_version}？[y/N]: " confirm || { rm -rf "$tmp_dir"; return 0; }
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$tmp_dir"
            echo -e "${yellow}已取消更新${re}"
            return 0
        fi
    fi

    backup="${VPS_TOOLBOX_ROOT}.bak.$(date +%Y%m%d%H%M%S)"
    if ! cp -a "${VPS_TOOLBOX_ROOT}" "$backup"; then
        rm -rf "$tmp_dir"
        echo -e "${red}备份失败，已取消更新${re}"
        return 1
    fi

    # 保留本机品牌配置，同时补齐新版 branding 新增的默认键
    local meta_dir="${tmp_dir}/.update-meta"
    mkdir -p "$meta_dir"
    cp -f "${VPS_TOOLBOX_ROOT}/lib/branding.sh" "${meta_dir}/branding.local"
    cp -f "${tmp_dir}/lib/branding.sh" "${meta_dir}/branding.new"
    cp -f "${meta_dir}/branding.local" "${tmp_dir}/lib/branding.sh"
    merge_missing_branding_keys "${tmp_dir}/lib/branding.sh" "${meta_dir}/branding.new"
    sed -i "s|^PROJECT_VERSION=.*|PROJECT_VERSION=\"${new_version}\"|" "${tmp_dir}/lib/branding.sh"
    rm -rf "$meta_dir"

    update_remove_stale_files "$tmp_dir" "${VPS_TOOLBOX_ROOT}"
    if ! cp -a "${tmp_dir}"/. "${VPS_TOOLBOX_ROOT}"/; then
        update_restore_tree "$backup"
        rm -rf "$tmp_dir"
        echo -e "${red}写入失败，已回滚到 v${PROJECT_VERSION}${re}"
        return 1
    fi
    update_fix_permissions

    rm -rf "$tmp_dir"
    echo -e "${green}更新完成：v${PROJECT_VERSION} -> v${new_version}${re}"
    echo "旧版本备份: ${backup}"
    echo ""
    if [ "${VPS_TOOLBOX_CLI:-0}" = "1" ]; then
        return 0
    fi
    echo -e "${yellow}按任意键重新加载脚本${re}"
    read -n 1 -s -r
    main_menu
}

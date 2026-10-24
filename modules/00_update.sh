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

    local tmp_dir archive new_version backup
    tmp_dir="$(mktemp -d)"
    archive="${tmp_dir}/update.tar.gz"

    echo "正在从 ${PROJECT_REPO_URL} 下载..."
    if ! curl -fsSL --max-time 60 -o "$archive" "${PROJECT_REPO_URL}/archive/refs/heads/${PROJECT_BRANCH}.tar.gz"; then
        rm -rf "$tmp_dir"
        echo -e "${red}下载失败，已保留当前版本${re}"
        return 1
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

    backup="${VPS_TOOLBOX_ROOT}.bak.$(date +%Y%m%d%H%M%S)"
    if ! cp -a "${VPS_TOOLBOX_ROOT}" "$backup"; then
        rm -rf "$tmp_dir"
        echo -e "${red}备份失败，已取消更新${re}"
        return 1
    fi

    # 保留本机品牌配置（仓库地址、快捷命令、统计开关等）
    cp -f "${VPS_TOOLBOX_ROOT}/lib/branding.sh" "${tmp_dir}/lib/branding.sh"

    if ! cp -a "${tmp_dir}"/. "${VPS_TOOLBOX_ROOT}"/; then
        cp -a "${backup}"/. "${VPS_TOOLBOX_ROOT}"/
        rm -rf "$tmp_dir"
        echo -e "${red}写入失败，已回滚到 v${PROJECT_VERSION}${re}"
        return 1
    fi

    # 本地 branding 被保留，需单独同步版本号，否则下次更新会重复提示
    sed -i "s|^PROJECT_VERSION=.*|PROJECT_VERSION=\"${new_version}\"|" "${VPS_TOOLBOX_ROOT}/lib/branding.sh" \
        || cp -f "${tmp_dir}/lib/branding.sh" "${VPS_TOOLBOX_ROOT}/lib/branding.sh"

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

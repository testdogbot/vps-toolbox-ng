#!/usr/bin/env bash
# 创建快捷命令：/usr/local/bin/<PROJECT_NAME>.sh 包装器 + 短命令软链接
# 本项目是多文件结构，包装器只执行本地入口；在线更新由入口的 update 功能负责

shortcut_file_is_ours() {
    local file="$1"
    [ -f "$file" ] || return 1
    grep -qE '^# vps-toolbox shortcut wrapper$|^# .*快捷入口$' "$file" 2>/dev/null && return 0
    [ -n "${VPS_TOOLBOX_ENTRY:-}" ] && grep -qF "$VPS_TOOLBOX_ENTRY" "$file" 2>/dev/null && return 0
    return 1
}

create_shortcut() {
    local script_path="${SHORTCUT_TARGET}"
    local tmp

    if [ -e "$script_path" ] && ! shortcut_file_is_ours "$script_path"; then
        echo -e "${yellow}跳过 ${script_path}：已存在其他同名文件${re}" >&2
        return 0
    fi

    tmp="$(mktemp "${script_path}.XXXXXX" 2>/dev/null)" || return 0
    cat > "$tmp" <<EOF
#!/bin/bash
# vps-toolbox shortcut wrapper
exec bash "${VPS_TOOLBOX_ENTRY}" "\$@"
EOF
    if ! chmod +x "$tmp" 2>/dev/null || ! mv -f "$tmp" "$script_path" 2>/dev/null; then
        rm -f "$tmp"
        return 0
    fi

    local link_name link_path current
    for link_name in "${SHORTCUT_NAMES[@]}"; do
        link_path="/usr/local/bin/$link_name"
        if [ -L "$link_path" ]; then
            current=$(readlink "$link_path" 2>/dev/null || true)
            case "$current" in
                "$script_path"|"$VPS_TOOLBOX_ENTRY"|"$VPS_TOOLBOX_ROOT"/*)
                    if [ "$current" != "$script_path" ]; then
                        ln -sfn "$script_path" "$link_path" >/dev/null 2>&1
                    fi
                    ;;
                *)
                    echo -e "${yellow}跳过 ${link_path}：已指向其他程序（${current}）${re}" >&2
                    ;;
            esac
        elif [ -e "$link_path" ]; then
            echo -e "${yellow}跳过 ${link_path}：已存在同名文件${re}" >&2
        else
            ln -sfn "$script_path" "$link_path" >/dev/null 2>&1
        fi
    done
    hash -r >/dev/null 2>&1
}

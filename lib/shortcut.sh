#!/usr/bin/env bash
# 创建快捷命令：/usr/local/bin/<PROJECT_NAME>.sh 包装器 + 短命令软链接
# 本项目是多文件结构，包装器只执行本地入口；在线更新由入口的 update 功能负责

create_shortcut() {
    local script_path="${SHORTCUT_TARGET}"

    cat > "$script_path" 2>/dev/null <<EOF || return 0
#!/bin/bash
# ${PROJECT_TITLE} 快捷入口
exec bash "${VPS_TOOLBOX_ENTRY}" "\$@"
EOF
    chmod +x "$script_path" 2>/dev/null

    local link_name link_path
    for link_name in "${SHORTCUT_NAMES[@]}"; do
        link_path="/usr/local/bin/$link_name"
        if [ ! -L "$link_path" ] || [ "$(readlink "$link_path")" != "$script_path" ]; then
            ln -sf "$script_path" "$link_path" >/dev/null 2>&1
        fi
    done
    hash -r >/dev/null 2>&1
}

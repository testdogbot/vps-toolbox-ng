#!/usr/bin/env bash
# 本地运行次数统计：每次启动主菜单记一次，当日计数按自然日重置
# 不联网、不上报，记录在 STATS_FILE（默认 /etc/vps-toolbox/stats）

stats_file_path() {
    local file="${STATS_FILE:-/etc/vps-toolbox/stats}"
    local dir
    dir=$(dirname "$file")
    if mkdir -p "$dir" 2>/dev/null && [ -w "$dir" ]; then
        printf '%s' "$file"
    elif [ -w "${VPS_TOOLBOX_ROOT}" ]; then
        printf '%s' "${VPS_TOOLBOX_ROOT}/.stats"
    else
        return 1
    fi
}

sum_run_times() {
    local file last_date stored_today stored_total
    file=$(stats_file_path) || return 0

    if [ -r "$file" ]; then
        last_date=$(sed -n 's/^date=//p' "$file" | head -n 1)
        stored_today=$(sed -n 's/^today=//p' "$file" | head -n 1)
        stored_total=$(sed -n 's/^total=//p' "$file" | head -n 1)
    fi
    [[ "$stored_today" =~ ^[0-9]{1,9}$ ]] || stored_today=0
    [[ "$stored_total" =~ ^[0-9]{1,9}$ ]] || stored_total=0

    local today_date
    today_date=$(date +%F)
    if [ "$last_date" = "$today_date" ]; then
        TODAY=$((10#$stored_today + 1))
    else
        TODAY=1
    fi
    TOTAL=$((10#$stored_total + 1))

    local tmp="${file}.$$"
    if printf 'date=%s\ntoday=%s\ntotal=%s\n' "$today_date" "$TODAY" "$TOTAL" > "$tmp" 2>/dev/null; then
        mv -f "$tmp" "$file" 2>/dev/null || rm -f "$tmp"
    fi
}

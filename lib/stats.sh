#!/usr/bin/env bash
# 运行统计（默认关闭）
# 仅当 ENABLE_STATS=1 且 STATS_URL 指向你自己部署的计数服务时才会请求

sum_run_times() {
    if [ "${ENABLE_STATS:-0}" != "1" ] || [ -z "${STATS_URL:-}" ]; then
        return 0
    fi
    local COUNT
    COUNT=$(curl -s -m 2 "${STATS_URL}") || return 0
    TODAY=$(echo "$COUNT" | sed -n 's/.*"daily_count": \([0-9]\+\).*/\1/p')
    TOTAL=$(echo "$COUNT" | sed -n 's/.*"total_count": \([0-9]\+\).*/\1/p')
}

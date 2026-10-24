#!/usr/bin/env bash
# 项目品牌与部署配置。二次开发只改这一个文件即可完成改名/换仓库/换入口地址。

PROJECT_NAME="vps-toolbox"
PROJECT_TITLE="VPS 工具箱"
PROJECT_VERSION="0.1.0"
PROJECT_AUTHOR="your-name"

# 你的 GitHub 仓库（留空表示尚未发布，快捷键与更新功能会退化为本地模式）
PROJECT_REPO_URL=""
PROJECT_BRANCH="main"

# 安装/更新/快捷键使用的入口脚本地址；留空则使用本地路径
PROJECT_RAW_URL=""

# 安装目录（install.sh 与更新逻辑使用）
PROJECT_INSTALL_DIR="/opt/vps-toolbox"

# 快捷命令名称（启动时写入 /usr/local/bin）
SHORTCUT_NAMES=("vps" "vpst")

# 运行统计上报（默认关闭，不会向任何第三方发送信息）
# 如需启用，请自行部署计数服务并填入 STATS_URL（返回含 daily_count/total_count 的 JSON）
ENABLE_STATS="${ENABLE_STATS:-0}"
STATS_URL=""

VPS_TOOLBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export VPS_TOOLBOX_ROOT
VPS_TOOLBOX_ENTRY="${VPS_TOOLBOX_ROOT}/vps-toolbox.sh"
export VPS_TOOLBOX_ENTRY
SHORTCUT_TARGET="/usr/local/bin/${PROJECT_NAME}.sh"

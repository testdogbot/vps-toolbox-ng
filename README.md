# vps-toolbox

面向 Linux VPS 的 Bash 工具箱，基于 [eooce/ssh_tool](https://github.com/eooce/ssh_tool)（v8.8.8）做模块化二次开发。
原先 6978 行的单文件脚本按菜单分支拆分为 `lib/` + `modules/`，便于维护和继续加功能。

## 功能

主菜单 20 项：本机信息、系统更新/清理、组件管理、BBR、Docker、WARP、LDNMP 建站、面板工具、系统工具、工作区、节点搭建、测试脚本、甲骨文云、环境管理、NAT 小鸡、基础工具管理、应用市场、服务器集群、游戏开服。

参考 [kejilion/sh](https://github.com/kejilion/sh) v4.5.14 增强的部分：

- **应用市场**：同步 `kejilion/apps` 应用目录（24 小时内缓存，`u` 可强制刷新），动态列出应用与安装状态，支持安装/更新/卸载/域名反代/整机备份还原；执行第三方配置前会显示来源并要求确认。KPanel 以 `kpanel` 应用形式安装维护。
- **服务器集群**：一份服务器清单批量执行更新、清理、装 Docker、开放端口、时区、重启与自定义命令；系统更新、清理、开放端口前需二次确认。
- **游戏开服**：幻兽帕鲁、我的世界开服脚本入口，下载校验、显示来源并确认后执行。
- **基础工具管理**：20 个常用工具（htop、btop、ncdu、fzf、rsync 等）安装状态一览，支持单项/批量安装与指定卸载。
- **系统信息增强**：CPU 频率、系统负载、TCP/UDP 连接数、DNS 地址、时区。
- **工作区增强**：保留 5 个固定工作区，新增自定义工作区、会话列表、向会话注入命令、关闭指定会话。
- **底层健壮性**：包管理器覆盖 apt/dnf/yum/pacman/zypper/apk/opkg/pkg；交互输入支持行编辑与 EOF 退出；自更新带版本校验、降级保护、备份与回滚，保留并补齐本地 branding，更新后修复执行权限。

## 命令行

```bash
vps-toolbox            # 启动主菜单（需要 root）
vps-toolbox info       # 直接查看系统信息（无需 root）
vps-toolbox update     # 从仓库检查并更新（无需交互）
vps-toolbox help       # 查看用法
```

## 与上游的差异

| 项目 | 上游 | 本项目 |
|------|------|--------|
| 代码结构 | 单文件 6978 行 | `lib/` 公共函数 + `modules/` 按菜单分支拆分 |
| 快捷命令 | 固定 `k` / `K` | `lib/branding.sh` 可配置，默认 `vps` / `vpst` |
| 入口脚本 | 固定 `ssh_tool.sh` | `vps-toolbox.sh`，支持本地安装目录运行 |
| 自更新 | 从 eooce 仓库拉取更新日志 | 读取本项目 `CHANGELOG.md`；配置仓库后拉取压缩包，校验版本、备份、失败回滚 |
| 运行统计 | 每次启动上报 eooce 计数服务，显示全局次数 | 本地计数，显示本机当日/累计次数，不联网、不上报 |
| 资源限制脚本 | 每次从 eooce 仓库下载 | 优先使用内置 `scripts/`，缺失时才回退下载 |
| 菜单返回 | 重新下载远程脚本并执行 | 重新执行本地入口，无网络依赖 |
| 输入方式 | `read -p` | `read -e`，支持行编辑 |

## 安装

一行安装（从 GitHub 拉取并安装到 `/opt/vps-toolbox`）：

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/testdogbot/vps-toolbox-ng/main/install.sh)
vps
```

本地目录安装：

```bash
sudo bash install.sh
```

安装后可用 `vps`、`vpst` 或 `vps-toolbox` 启动。

也可以不安装，直接在项目目录运行：

```bash
sudo bash vps-toolbox.sh
```

## 应用市场 / 集群 / 游戏脚本

- 应用市场首次使用会把 `kejilion/apps` 克隆到 `~/apps`，之后 24 小时内直接使用本地列表，过期后再 `git pull`；按 `u` 可强制刷新。离线时沿用本地列表。仓库地址与目录可在 `lib/branding.sh` 的 `APP_CATALOG_REPO` / `APP_CATALOG_DIR` 修改。
- 应用配置由第三方目录提供，打开任一应用前会显示配置来源并要求确认；安装前请自行确认镜像来源。应用数据位于 `/home/docker`，域名反代依赖 LDNMP 建站环境。
- 集群清单保存在 `~/cluster/servers.conf`，格式 `名称|地址|端口|用户|密码`，密码留空则使用 SSH 密钥；文件权限为 600，但仍建议用密钥代替明文密码。系统更新、清理、开放端口、重启前均需二次确认。
- 游戏开服脚本下载到 `~` 目录后会显示来源并要求确认再执行，下载地址前缀由 `GAMES_SCRIPT_BASE` 控制。
- 自更新会保留本地 `lib/branding.sh` 并补齐新版新增的默认配置，禁止静默降级（确需降级时设置 `VPS_TOOLBOX_ALLOW_DOWNGRADE=1`），重装同样保留本机 branding。

## 目录结构

```
vps-toolbox.sh          入口：加载 lib 与 modules，启动主循环
install.sh              安装脚本
lib/
  branding.sh           品牌/仓库/快捷命令/统计配置（二次开发只改这里）
  colors.sh             颜色变量
  common.sh             包管理、返回重载、端口检查、Docker/防火墙基础操作
  components.sh         Node.js、Java 安装
  ldnmp.sh              LDNMP 建站辅助函数
  shortcut.sh           快捷命令与包装器
  stats.sh              运行统计（本地计数）
  menu.sh               主菜单展示与分支分派
modules/
  00_update.sh          脚本更新
  01_system_info.sh     1. 本机信息
  02_system_update.sh   2. 系统更新
  ...
  16_nat_vm.sh          16. 开设 NAT 小鸡
  17_basic_tools.sh     17. 基础工具管理
  18_app_market.sh      18. 应用市场（含 KPanel）
  19_cluster.sh         19. 服务器集群控制
  20_games.sh           20. 游戏开服脚本
scripts/                资源限制等辅助脚本（crond 调用）
```

## 二次开发约定

- 新增主菜单项：在 `modules/` 加文件定义 `menu_xxx()`，再到 `lib/menu.sh` 的 `main_loop` 里加一行分派和菜单文案。
- 所有模块在启动时 `source` 加载，模块文件内只定义函数和只读全局变量，不要写顶层执行语句。
- 改名/换仓库/换快捷命令/统计文件位置，只改 `lib/branding.sh`。
- 主菜单返回统一调用 `main_menu`，它会重新执行本地入口脚本。

## 已验证 / 未验证

- 已验证：全部 Bash 文件 `bash -n` 语法通过；Git Bash 下可加载全部 lib 与 modules，21 个菜单函数齐全；主菜单、基础工具、应用市场列表渲染正常；应用目录解析覆盖全部 50 个配置；`monitor` / `kpanel` 配置可在函数作用域内 source 并进入应用菜单；集群清单增删改查在临时目录跑通。
- 已验证（0.3.1 修复项，均为临时目录/本地压缩包模拟）：自更新成功路径（下载/校验/备份/保留 branding 并补齐新增键/版本号同步/清理旧模块/恢复执行权限/无临时文件残留）、降级拦截与强制降级、交互更新取消；`install.sh` 成功路径（保留本机 branding/补齐新键/版本同步/旧目录备份/快捷命令创建）与故障注入后的自动回滚；快捷命令不覆盖他人同名文件、包装器原子替换；主菜单与各子菜单在 Ctrl-D/EOF 下立即退出；应用市场 24 小时缓存跳过、拒绝打开第三方配置时不 source、非法应用 ID 被拒绝；集群关键字删除的记录数与二次确认。
- 未验证：Linux VPS 上的应用安装/卸载、KPanel 部署、集群批量执行、游戏开服脚本等均未实机执行（当前环境无 Docker/Linux systemd）。首次上机建议在快照/测试机上逐项验证。

## 许可证

本项目继承上游 Apache License 2.0，署名信息见 `NOTICE`。
WARP 菜单在运行时调用 [fscarmen/warp](https://gitlab.com/fscarmen/warp)，本项目不内置、不分发其代码。

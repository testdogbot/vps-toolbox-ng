# vps-toolbox

面向 Linux VPS 的 Bash 工具箱，基于 [eooce/ssh_tool](https://github.com/eooce/ssh_tool)（v8.8.8）做模块化二次开发。
原先 6978 行的单文件脚本按菜单分支拆分为 `lib/` + `modules/`，便于维护和继续加功能。

## 功能

主菜单 17 项：本机信息、系统更新/清理、组件管理、BBR、Docker、WARP、LDNMP 建站、面板工具、系统工具、工作区、节点搭建、测试脚本、甲骨文云、环境管理、NAT 小鸡，以及新增的基础工具管理。

参考 [kejilion/sh](https://github.com/kejilion/sh) v4.5.14 增强的部分：

- **基础工具管理**：20 个常用工具（htop、btop、ncdu、fzf、rsync 等）安装状态一览，支持单项/批量安装与指定卸载。
- **系统信息增强**：CPU 频率、系统负载、TCP/UDP 连接数、DNS 地址、时区。
- **工作区增强**：保留 5 个固定工作区，新增自定义工作区、会话列表、向会话注入命令、关闭指定会话。
- **底层健壮性**：包管理器覆盖 apt/dnf/yum/pacman/zypper/apk/opkg/pkg；交互输入支持行编辑；自更新带版本校验、备份与回滚。

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
| 运行统计 | 每次启动上报 eooce 计数服务 | 默认关闭（`ENABLE_STATS=0`），不向第三方发送信息 |
| 资源限制脚本 | 每次从 eooce 仓库下载 | 优先使用内置 `scripts/`，缺失时才回退下载 |
| 菜单返回 | 重新下载远程脚本并执行 | 重新执行本地入口，无网络依赖 |
| 输入方式 | `read -p` | `read -e`，支持行编辑 |

## 安装

一行安装（从 GitHub 拉取并安装到 `/opt/vps-toolbox`）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/testdogbot/vps-toolbox-ng/main/install.sh)
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

## 目录结构

```
vps-toolbox.sh          入口：加载 lib 与 modules，启动主循环
install.sh              安装脚本
lib/
  branding.sh           品牌/仓库/快捷命令/统计开关（二次开发只改这里）
  colors.sh             颜色变量
  common.sh             包管理、返回重载、端口检查、Docker/防火墙基础操作
  components.sh         Node.js、Java 安装
  ldnmp.sh              LDNMP 建站辅助函数
  shortcut.sh           快捷命令与包装器
  stats.sh              运行统计（默认不调用）
  menu.sh               主菜单展示与分支分派
modules/
  00_update.sh          脚本更新
  01_system_info.sh     1. 本机信息
  02_system_update.sh   2. 系统更新
  ...
  16_nat_vm.sh          16. 开设 NAT 小鸡
  17_basic_tools.sh     17. 基础工具管理
scripts/                资源限制等辅助脚本（crond 调用）
```

## 二次开发约定

- 新增主菜单项：在 `modules/` 加文件定义 `menu_xxx()`，再到 `lib/menu.sh` 的 `main_loop` 里加一行分派和菜单文案。
- 所有模块在启动时 `source` 加载，模块文件内只定义函数，不要写顶层执行语句。
- 改名/换仓库/换快捷命令/开关统计，只改 `lib/branding.sh`。
- 主菜单返回统一调用 `main_menu`，它会重新执行本地入口脚本。

## 已验证 / 未验证

- 已验证：全部 Bash 文件 `bash -n` 语法通过；Git Bash 下可加载全部 lib 与 modules，18 个菜单函数齐全；基础工具菜单渲染正常；自更新流程用本地压缩包模拟通过（下载/校验/备份/写入/保留 branding/版本号同步/已是最新短路）。
- 未验证：Linux VPS 上的交互流程、服务安装、防火墙与系统修改类功能均未实机执行。首次上机建议在快照/测试机上逐项验证。

## 许可证

本项目继承上游 Apache License 2.0，署名信息见 `NOTICE`。
WARP 菜单在运行时调用 [fscarmen/warp-sh](https://github.com/fscarmen/warp-sh)，该上游未提供明确许可证，本项目不分发其代码。

# Changelog

## 0.2.0 - 2026-10-25

参考 kejilion/sh v4.5.14 对底层健壮性、工具管理、系统信息与工作区四部分进行增强。

- 包管理器扩展：`install`/`remove` 支持 apt、dnf、yum、pacman、zypper、apk、opkg、pkg。
- 所有交互输入改为 `read -e`，支持行编辑与历史补全。
- 更新功能落地：从本仓库拉取分支压缩包，校验版本号，备份当前目录，失败自动回滚，保留本地 `lib/branding.sh`。
- 新增命令行入口：`vps-toolbox update`、`vps-toolbox info`、`vps-toolbox help`，`info` 与 `help` 无需 root。
- 新增「基础工具管理」（主菜单 17）：20 个常用工具安装状态一览，支持单项安装、批量安装、指定卸载。
- 系统信息增强：CPU 频率、系统负载、TCP/UDP 连接数、DNS 地址、时区。
- 工作区增强：新增自定义工作区、工作区列表、向工作区注入命令、关闭指定工作区；卸载前二次确认。
- 卸载软件包改用各包管理器的 purge/remove 语义，避免残留配置；安装/卸载失败会返回非零状态。

## 0.1.0 - 2026-10-24

- 以 eooce/ssh_tool v8.8.8 为基线创建项目，按菜单分支拆分为 `lib/` + `modules/` 结构。
- 主菜单 16 项功能逻辑与上游保持一致，菜单分支代码机械抽取、未做行为改动。
- 快捷命令、仓库地址、统计开关集中到 `lib/branding.sh`。
- 关闭上游默认的运行统计上报。
- `main_menu` 改为重新执行本地入口，不再下载远程脚本。
- 资源限制脚本优先使用内置 `scripts/`。
- 新增 `install.sh`，安装到 `/opt/vps-toolbox` 并创建 `vps` / `vpst` 命令。

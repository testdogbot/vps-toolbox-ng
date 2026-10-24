# Changelog

## 0.1.0 - 2026-10-24

- 以 eooce/ssh_tool v8.8.8 为基线创建项目，按菜单分支拆分为 `lib/` + `modules/` 结构。
- 主菜单 16 项功能逻辑与上游保持一致，菜单分支代码机械抽取、未做行为改动。
- 快捷命令、仓库地址、统计开关集中到 `lib/branding.sh`。
- 关闭上游默认的运行统计上报。
- `main_menu` 改为重新执行本地入口，不再下载远程脚本。
- 资源限制脚本优先使用内置 `scripts/`。
- 新增 `install.sh`，安装到 `/opt/vps-toolbox` 并创建 `vps` / `vpst` 命令。

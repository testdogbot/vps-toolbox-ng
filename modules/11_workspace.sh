#!/usr/bin/env bash
# vps-toolbox 模块：我的工作区
# 由 eooce/ssh_tool 的菜单分支抽取，并增强为通用的 tmux 会话管理

workspace_require_tmux() {
    if ! command -v tmux &>/dev/null; then
        echo -e "${red}未安装 tmux，请先选择 a 安装工作区环境${re}"
        return 1
    fi
    return 0
}

workspace_attach() {
    local session_name="$1"
    if [ -z "$session_name" ]; then
        echo -e "${red}工作区名不能为空${re}"
        return 1
    fi
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach-session -t "$session_name"
    else
        tmux new -s "$session_name"
    fi
}

menu_workspace() {
    while true; do
      clear
      echo "▶ 我的工作区"
      echo "系统将为你提供5个后台运行的工作区，你可以用来执行长时间的任务"
      echo "即使你断开SSH，工作区中的任务也不会中断，非常方便！来试试吧！"
      echo -e "${yellow}注意: 进入工作区后使用 Ctrl+b 再单独按 d，退出工作区！${re}"
      echo "------------------------"
      echo "a. 安装工作区环境"
      echo "b. 卸载工作区环境"
      echo "------------------------"
      echo "1. 1号工作区"
      echo "2. 2号工作区"
      echo "3. 3号工作区"
      echo "4. 4号工作区"
      echo "5. 5号工作区"
      echo "------------------------"
      echo "21. 创建自定义工作区"
      echo "22. 查看工作区列表"
      echo "23. 向工作区注入命令"
      echo "24. 关闭指定工作区"
      echo "------------------------"
      echo "8. 工作区状态"
      echo "------------------------"
      echo -e "${skyblue}0. 返回主菜单${re}"
      echo "------------------------"
      read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice || exit 0

      case $sub_choice in
          a)
              clear
              install tmux
              ;;
          b)
              clear
              echo -e "${yellow}将删除 tmux 及其全部工作区会话，确认继续？[y/N]${re}"
              read -e -r ws_confirm
              if [[ "$ws_confirm" =~ ^[Yy]$ ]]; then
                  remove tmux
              else
                  echo -e "${yellow}已取消${re}"
              fi
              ;;
          1)
              clear
              workspace_require_tmux && workspace_attach "work1"
              ;;
          2)
              clear
              workspace_require_tmux && workspace_attach "work2"
              ;;
          3)
              clear
              workspace_require_tmux && workspace_attach "work3"
              ;;
          4)
              clear
              workspace_require_tmux && workspace_attach "work4"
              ;;
          5)
              clear
              workspace_require_tmux && workspace_attach "work5"
              ;;
          21)
              clear
              if ! workspace_require_tmux; then
                  break_end
                  continue
              fi
              echo -e "${yellow}工作区名支持中文，但建议使用英文字母、数字、下划线${re}"
              read -e -p "请输入工作区名称: " ws_name
              if [ -z "$ws_name" ]; then
                  echo -e "${red}工作区名不能为空${re}"
              elif tmux has-session -t "$ws_name" 2>/dev/null; then
                  echo -e "${yellow}工作区 ${ws_name} 已存在，直接进入${re}"
                  tmux attach-session -t "$ws_name"
              else
                  workspace_attach "$ws_name"
              fi
              ;;
          22)
              clear
              if ! workspace_require_tmux; then
                  break_end
                  continue
              fi
              echo -e "${white}当前工作区列表${re}"
              echo "------------------------"
              tmux list-sessions 2>/dev/null || echo -e "${yellow}暂无工作区${re}"
              ;;
          23)
              clear
              if ! workspace_require_tmux; then
                  break_end
                  continue
              fi
              tmux list-sessions 2>/dev/null || { echo -e "${yellow}暂无工作区${re}"; break_end; continue; }
              echo "------------------------"
              read -e -p "请输入目标工作区名称: " ws_name
              if [ -z "$ws_name" ] || ! tmux has-session -t "$ws_name" 2>/dev/null; then
                  echo -e "${red}工作区 ${ws_name} 不存在${re}"
              else
                  read -e -p "请输入要执行的命令: " ws_cmd
                  if [ -z "$ws_cmd" ]; then
                      echo -e "${red}命令不能为空${re}"
                  else
                      tmux send-keys -t "$ws_name" "$ws_cmd" C-m
                      echo -e "${green}已向工作区 ${ws_name} 发送命令${re}"
                  fi
              fi
              ;;
          24)
              clear
              if ! workspace_require_tmux; then
                  break_end
                  continue
              fi
              tmux list-sessions 2>/dev/null || { echo -e "${yellow}暂无工作区${re}"; break_end; continue; }
              echo "------------------------"
              read -e -p "请输入要关闭的工作区名称: " ws_name
              if [ -z "$ws_name" ] || ! tmux has-session -t "$ws_name" 2>/dev/null; then
                  echo -e "${red}工作区 ${ws_name} 不存在${re}"
              else
                  read -e -r -p "确认关闭工作区 ${ws_name}？其中运行的进程会被终止 [y/N]: " ws_confirm
                  if [[ "$ws_confirm" =~ ^[Yy]$ ]]; then
                      tmux kill-session -t "$ws_name"
                      echo -e "${green}已关闭工作区 ${ws_name}${re}"
                  else
                      echo -e "${yellow}已取消${re}"
                  fi
              fi
              ;;
          8)
              clear
              if workspace_require_tmux; then
                  tmux list-sessions 2>/dev/null || echo -e "${yellow}暂无工作区${re}"
              fi
              ;;
          0)
              main_menu
              ;;
          *)
              echo -e "${red}无效的输入!${re}"
              ;;
      esac
      break_end

    done
}

#!/usr/bin/env bash
# vps-toolbox 模块：面板工具
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_panel_tools() {
    while true; do
      clear
      echo "▶ 面板工具"
      echo "------------------------"
      echo " 1. 宝塔面板官方版                        2. aaPanel宝塔国际版"
      echo " 3. 1Panel新一代管理面板                  4. NginxProxyManager可视化面板"
      echo " 5. AList多存储文件列表程序               6. Ubuntu远程桌面网页版"
      echo " 7. 哪吒探针VPS监控面板                   8. QB离线BT磁力下载面板"
      echo " 9. Poste.io邮件服务器程序               10. RocketChat多人在线聊天系统"
      echo "11. 禅道项目管理软件                     12. 青龙面板定时任务管理平台"
      echo "13. Cloudreve网盘系统                    14. 简单图床图片管理程序"
      echo "15. emby多媒体管理系统                   16. Speedtest测速服务面板"
      echo "17. AdGuardHome去广告软件                18. onlyoffice在线办公OFFICE"
      echo "19. 雷池WAF防火墙面板                    20. portainer容器管理面板"
      echo "21. VScode网页版                         22. UptimeKuma监控工具"
      echo "23. Memos网页备忘录                      "
      echo "------------------------"
      echo -e "${skyblue} 0. 返回主菜单${re}"
      echo "------------------------"
      read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

      case $sub_choice in
          1)
            if [ -f "/etc/init.d/bt" ] && [ -d "/www/server/panel" ]; then
                clear
                echo "宝塔面板已安装，应用操作"
                echo ""
                echo "------------------------"
                echo "1. 管理宝塔面板           2. 卸载宝塔面板"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                case $sub_choice in
                    1)
                        clear
                        # 更新宝塔面板操作
                        bt
                        ;;
                    2)
                        clear
                        curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1
                        chmod +x bt-uninstall.sh
                        ./bt-uninstall.sh
                        ;;
                    0)
                        break  # 跳出循环，退出菜单
                        ;;
                    *)
                        break  # 跳出循环，退出菜单
                        ;;
                esac
            else
                clear
                echo "安装提示"
                echo "如果您已经安装了其他面板工具或者LDNMP建站环境，建议先卸载，再安装宝塔面板！"
                echo "会根据系统自动安装，支持Debian，Ubuntu，Centos"
                echo "官网介绍: https://www.bt.cn/new/index.html"
                echo ""

                # 获取当前系统类型
                get_system_type() {
                    if [ -f /etc/os-release ]; then
                        . /etc/os-release
                        if [ "$ID" == "centos" ]; then
                            echo "centos"
                        elif [ "$ID" == "ubuntu" ]; then
                            echo "ubuntu"
                        elif [ "$ID" == "debian" ]; then
                            echo "debian"
                        else
                            echo "unknown"
                        fi
                    else
                        echo "unknown"
                    fi
                }

                system_type=$(get_system_type)

                if [ "$system_type" == "unknown" ]; then
                    echo "不支持的操作系统类型"
                else
                    read -e -p "确定安装宝塔吗？(Y/N): " choice
                    case "$choice" in
                        [Yy])
                            iptables_open
                            install wget
                            if [ "$system_type" == "centos" ]; then
                                yum install -y wget && wget -O install.sh https://download.bt.cn/install/install_6.0.sh && sh install.sh ed8484bec
                            elif [ "$system_type" == "ubuntu" ]; then
                                wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && bash install.sh ed8484bec
                            elif [ "$system_type" == "debian" ]; then
                                wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh && bash install.sh ed8484bec
                            fi
                            ;;
                        [Nn])
                            ;;
                        *)
                            ;;
                    esac
                fi
            fi

              ;;
          2)
            if [ -f "/etc/init.d/bt" ] && [ -d "/www/server/panel" ]; then
                clear
                echo "aaPanel已安装，应用操作"
                echo ""
                echo "------------------------"
                echo "1. 管理aaPanel           2. 卸载aaPanel"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                case $sub_choice in
                    1)
                        clear
                        # 更新aaPanel操作
                        bt
                        ;;
                    2)
                        clear
                        curl -o bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh > /dev/null 2>&1
                        chmod +x bt-uninstall.sh
                        ./bt-uninstall.sh
                        ;;
                    0)
                        break  # 跳出循环，退出菜单
                        ;;
                    *)
                        break  # 跳出循环，退出菜单
                        ;;
                esac
            else
                clear
                echo "安装提示"
                echo "如果您已经安装了其他面板工具或者LDNMP建站环境，建议先卸载，再安装aaPanel！"
                echo "会根据系统自动安装，支持Debian，Ubuntu，Centos"
                echo "官网介绍: https://www.aapanel.com/new/index.html"
                echo ""

                # 获取当前系统类型
                get_system_type() {
                    if [ -f /etc/os-release ]; then
                        . /etc/os-release
                        if [ "$ID" == "centos" ]; then
                            echo "centos"
                        elif [ "$ID" == "ubuntu" ]; then
                            echo "ubuntu"
                        elif [ "$ID" == "debian" ]; then
                            echo "debian"
                        else
                            echo "unknown"
                        fi
                    else
                        echo "unknown"
                    fi
                }

                system_type=$(get_system_type)

                if [ "$system_type" == "unknown" ]; then
                    echo "不支持的操作系统类型"
                else
                    read -e -p "确定安装aaPanel吗？(Y/N): " choice
                    case "$choice" in
                        [Yy])
                            iptables_open
                            install wget
                            if [ "$system_type" == "centos" ]; then
                                yum install -y wget && wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh aapanel
                            elif [ "$system_type" == "ubuntu" ]; then
                                wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
                            elif [ "$system_type" == "debian" ]; then
                                wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel
                            fi
                            ;;
                        [Nn])
                            ;;
                        *)
                            ;;
                    esac
                fi
            fi
              ;;
          3)
            if command -v 1pctl &> /dev/null; then
                clear
                echo "1Panel已安装，应用操作"
                echo ""
                echo "------------------------"
                echo "1. 查看1Panel信息           2. 卸载1Panel"
                echo "------------------------"
                echo "0. 返回上一级选单"
                echo "------------------------"
                read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                case $sub_choice in
                    1)
                        clear
                        1pctl user-info
                        1pctl update password
                        ;;
                    2)
                        clear
                        1pctl uninstall

                        ;;
                    0)
                        break  # 跳出循环，退出菜单
                        ;;
                    *)
                        break  # 跳出循环，退出菜单
                        ;;
                esac
            else

                clear
                echo "安装提示"
                echo "如果您已经安装了其他面板工具或者LDNMP建站环境，建议先卸载，再安装1Panel！"
                echo "会根据系统自动安装，支持Debian，Ubuntu，Centos"
                echo "官网介绍: https://1panel.cn/"
                echo ""
                # 获取当前系统类型
                get_system_type() {
                  if [ -f /etc/os-release ]; then
                    . /etc/os-release
                    if [ "$ID" == "centos" ]; then
                      echo "centos"
                    elif [ "$ID" == "ubuntu" ]; then
                      echo "ubuntu"
                    elif [ "$ID" == "debian" ]; then
                      echo "debian"
                    else
                      echo "unknown"
                    fi
                  else
                    echo "unknown"
                  fi
                }

                system_type=$(get_system_type)

                if [ "$system_type" == "unknown" ]; then
                  echo "不支持的操作系统类型"
                else
                  read -e -p "确定安装1Panel吗？(Y/N): " choice
                  case "$choice" in
                    [Yy])
                      iptables_open
                      install_docker
                      if [ "$system_type" == "centos" ]; then
                        curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sh quick_start.sh
                      elif [ "$system_type" == "ubuntu" ]; then
                        curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh
                      elif [ "$system_type" == "debian" ]; then
                        curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh
                      fi
                      ;;
                    [Nn])
                      ;;
                    *)
                      ;;
                  esac
                fi
            fi
            ;;
          4)

            docker_name="npm"
            docker_img="jc21/nginx-proxy-manager:latest"
            docker_port=81
            docker_rum="docker run -d \
                          --name=$docker_name \
                          -p 80:80 \
                          -p 81:$docker_port \
                          -p 443:443 \
                          -v /home/docker/npm/data:/data \
                          -v /home/docker/npm/letsencrypt:/etc/letsencrypt \
                          --restart=always \
                          $docker_img"
            docker_describe="如果您已经安装了其他面板工具或者LDNMP建站环境，建议先卸载，再安装npm！"
            docker_url="官网介绍: https://nginxproxymanager.com/"
            docker_use="echo \"初始用户名: admin@example.com\""
            docker_passwd="echo \"初始密码: changeme\""

            docker_app

              ;;

          5)

            docker_name="alist"
            docker_img="xhofe/alist:latest"
            docker_port=5244
            docker_rum="docker run -d \
                                --restart=always \
                                -v /home/docker/alist:/opt/alist/data \
                                -p 5244:5244 \
                                -e PUID=0 \
                                -e PGID=0 \
                                -e UMASK=022 \
                                --name="alist" \
                                xhofe/alist:latest"
            docker_describe="一个支持多种存储，支持网页浏览和 WebDAV 的文件列表程序，由 gin 和 Solidjs 驱动"
            docker_url="官网介绍: https://alist.nn.ci/zh/"
            docker_use="docker exec -it alist ./alist admin random"
            docker_passwd=""

            docker_app

              ;;

          6)
            docker_name="ubuntu-novnc"
            docker_img="fredblgr/ubuntu-novnc:20.04"
            docker_port=6080
            rootpasswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)
            docker_rum="docker run -d \
                                --name ubuntu-novnc \
                                -p 6080:80 \
                                -v /home/docker/ubuntu-novnc:/workspace:rw \
                                -e HTTP_PASSWORD=$rootpasswd \
                                -e RESOLUTION=1280x720 \
                                --restart=always \
                                fredblgr/ubuntu-novnc:20.04"
            docker_describe="一个网页版Ubuntu远程桌面，挺好用的！"
            docker_url="官网介绍: https://hub.docker.com/r/fredblgr/ubuntu-novnc"
            docker_use="echo \"用户名: root\""
            docker_passwd="echo \"密码: $rootpasswd\""

            docker_app

              ;;
          7)
            clear
            curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh  -o nezha.sh && chmod +x nezha.sh
            ./nezha.sh
              ;;

          8)

            docker_name="qbittorrent"
            docker_img="lscr.io/linuxserver/qbittorrent:latest"
            docker_port=8081
            docker_rum="docker run -d \
                                  --name=qbittorrent \
                                  -e PUID=1000 \
                                  -e PGID=1000 \
                                  -e TZ=Etc/UTC \
                                  -e WEBUI_PORT=8081 \
                                  -p 8081:8081 \
                                  -p 6881:6881 \
                                  -p 6881:6881/udp \
                                  -v /home/docker/qbittorrent/config:/config \
                                  -v /home/docker/qbittorrent/downloads:/downloads \
                                  --restart unless-stopped \
                                  lscr.io/linuxserver/qbittorrent:latest"
            docker_describe="qbittorrent离线BT磁力下载服务"
            docker_url="官网介绍: https://hub.docker.com/r/linuxserver/qbittorrent"
            docker_use="sleep 3"
            docker_passwd="docker logs qbittorrent"

            docker_app

              ;;

          9)
            if docker inspect mailserver &>/dev/null; then

                    clear
                    echo "poste.io已安装，访问地址: "
                    yuming=$(cat /home/docker/mail.txt)
                    echo "https://$yuming"
                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                    case $sub_choice in
                        1)
                            clear
                            docker rm -f mailserver
                            docker rmi -f analogic/poste.io
                            install_docker
                            yuming=$(cat /home/docker/mail.txt)
                            docker run \
                                --net=host \
                                -e TZ=Europe/Prague \
                                -v /home/docker/mail:/data \
                                --name "mailserver" \
                                -h "$yuming" \
                                --restart=always \
                                -d analogic/poste.io

                            clear
                            echo "poste.io已经安装完成"
                            echo "------------------------"
                            echo "您可以使用以下地址访问poste.io:"
                            echo "https://$yuming"
                            echo ""
                            ;;
                        2)
                            clear
                            docker rm -f mailserver
                            docker rmi -f analogic/poste.io
                            rm /home/docker/mail.txt
                            rm -rf /home/docker/mail
                            echo "应用已卸载"
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                install telnet

                clear
                echo ""
                echo "端口检测"
                port=25
                timeout=3

                if echo "quit" | timeout $timeout telnet smtp.qq.com $port | grep 'Connected'; then
                  echo -e "\e[32m端口$port当前可用\e[0m"
                else
                  echo -e "\e[31m端口$port当前不可用\e[0m"
                fi
                echo "------------------------"
                echo ""


                echo "安装提示"
                echo "poste.io一个邮件服务器，确保80和443端口没被占用，确保25端口开放"
                echo "官网介绍: https://hub.docker.com/r/analogic/poste.io"
                echo ""

                # 提示用户确认安装
                read -e -p "确定安装poste.io吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear

                    read -e -p "请设置邮箱域名 例如 mail.yuming.com : " yuming
                    mkdir -p /home/docker      # 递归创建目录
                    echo "$yuming" > /home/docker/mail.txt  # 写入文件
                    echo "------------------------"
                    ip_address
                    echo "先解析这些DNS记录"
                    echo "A           mail            $ipv4_address"
                    echo "CNAME       imap            $yuming"
                    echo "CNAME       pop             $yuming"
                    echo "CNAME       smtp            $yuming"
                    echo "MX          @               $yuming"
                    echo "TXT         @               v=spf1 mx ~all"
                    echo "TXT         ?               ?"
                    echo ""
                    echo "------------------------"
                    echo "按任意键继续..."
                    read -n 1 -s -r -p ""

                    install_docker

                    docker run \
                        --net=host \
                        -e TZ=Europe/Prague \
                        -v /home/docker/mail:/data \
                        --name "mailserver" \
                        -h "$yuming" \
                        --restart=always \
                        -d analogic/poste.io

                    clear
                    echo "poste.io已经安装完成"
                    echo "------------------------"
                    echo "您可以使用以下地址访问poste.io:"
                    echo "https://$yuming"
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi
              ;;

          10)
            if docker inspect rocketchat &>/dev/null; then


                    clear
                    echo "rocket.chat已安装，访问地址: "
                    ip_address
                    echo "http:$ipv4_address:3897"
                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                    case $sub_choice in
                        1)
                            clear
                            docker rm -f rocketchat
                            docker rmi -f rocket.chat:6.3
                            install_docker

                            docker run --name rocketchat --restart=always -p 3897:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat

                            clear
                            ip_address
                            echo "rocket.chat已经安装完成"
                            echo "------------------------"
                            echo "多等一会，您可以使用以下地址访问rocket.chat:"
                            echo "http:$ipv4_address:3897"
                            echo ""
                            ;;
                        2)
                            clear
                            docker rm -f rocketchat
                            docker rmi -f rocket.chat
                            docker rmi -f rocket.chat:6.3
                            docker rm -f db
                            docker rmi -f mongo:latest
                            # docker rmi -f mongo:6
                            rm -rf /home/docker/mongo
                            echo "应用已卸载"
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                echo "安装提示"
                echo "rocket.chat国外知名开源多人聊天系统"
                echo "官网介绍: https://www.rocket.chat"
                echo ""

                # 提示用户确认安装
                read -e -p "确定安装rocket.chat吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear
                    install_docker
                    docker run --name db -d --restart=always \
                        -v /home/docker/mongo/dump:/dump \
                        mongo:latest --replSet rs5 --oplogSize 256
                    sleep 1
                    docker exec -it db mongosh --eval "printjson(rs.initiate())"
                    sleep 5
                    docker run --name rocketchat --restart=always -p 3897:3000 --link db --env ROOT_URL=http://localhost --env MONGO_OPLOG_URL=mongodb://db:27017/rs5 -d rocket.chat:6.3

                    clear

                    ip_address
                    echo "rocket.chat已经安装完成"
                    echo "------------------------"
                    echo "多等一会，您可以使用以下地址访问rocket.chat:"
                    echo "http:$ipv4_address:3897"
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi
              ;;



          11)
            docker_name="zentao-server"
            docker_img="idoop/zentao:latest"
            docker_port=82
            docker_rum="docker run -d -p 82:80 -p 3308:3306 \
                              -e ADMINER_USER="root" -e ADMINER_PASSWD="password" \
                              -e BIND_ADDRESS="false" \
                              -v /home/docker/zentao-server/:/opt/zbox/ \
                              --add-host smtp.exmail.qq.com:163.177.90.125 \
                              --name zentao-server \
                              --restart=always \
                              idoop/zentao:latest"
            docker_describe="禅道是通用的项目管理软件"
            docker_url="官网介绍: https://www.zentao.net/"
            docker_use="echo \"初始用户名: admin\""
            docker_passwd="echo \"初始密码: 123456\""
            docker_app

              ;;

          12)
            docker_name="qinglong"
            docker_img="whyour/qinglong:latest"
            docker_port=5700
            docker_rum="docker run -d \
                      -v /home/docker/qinglong/data:/ql/data \
                      -p 5700:5700 \
                      --name qinglong \
                      --hostname qinglong \
                      --restart unless-stopped \
                      whyour/qinglong:latest"
            docker_describe="青龙面板是一个定时任务管理平台"
            docker_url="官网介绍: https://github.com/whyour/qinglong"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;
          13)
            if docker inspect cloudreve &>/dev/null; then

                    clear
                    echo "cloudreve已安装，访问地址: "
                    ip_address
                    echo "http:$ipv4_address:5212"
                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                    case $sub_choice in
                        1)
                            clear
                            docker rm -f cloudreve
                            docker rmi -f cloudreve/cloudreve:latest
                            docker rm -f aria2
                            docker rmi -f p3terx/aria2-pro
                            install_docker
                            cd /home/ && mkdir -p docker/cloud && cd docker/cloud && mkdir temp_data && mkdir -vp cloudreve/{uploads,avatar} && touch cloudreve/conf.ini && touch cloudreve/cloudreve.db && mkdir -p aria2/config && mkdir -p data/aria2 && chmod -R 777 data/aria2
                            curl -o /home/docker/cloud/docker-compose.yml https://raw.githubusercontent.com/kejilion/docker/main/cloudreve-docker-compose.yml
                            cd /home/docker/cloud/ && docker-compose up -d


                            clear
                            echo "cloudreve已经安装完成"
                            echo "------------------------"
                            echo "您可以使用以下地址访问cloudreve:"
                            ip_address
                            echo "http:$ipv4_address:5212"
                            sleep 3
                            docker logs cloudreve
                            echo ""
                            ;;
                        2)
                            clear
                            docker rm -f cloudreve
                            docker rmi -f cloudreve/cloudreve:latest
                            docker rm -f aria2
                            docker rmi -f p3terx/aria2-pro
                            rm -rf /home/docker/cloud
                            echo "应用已卸载"
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                echo "安装提示"
                echo "cloudreve是一个支持多家云存储的网盘系统"
                echo "官网介绍: https://cloudreve.org/"
                echo ""

                # 提示用户确认安装
                read -e -p "确定安装cloudreve吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear
                    install_docker
                    cd /home/ && mkdir -p docker/cloud && cd docker/cloud && mkdir temp_data && mkdir -vp cloudreve/{uploads,avatar} && touch cloudreve/conf.ini && touch cloudreve/cloudreve.db && mkdir -p aria2/config && mkdir -p data/aria2 && chmod -R 777 data/aria2
                    curl -o /home/docker/cloud/docker-compose.yml https://raw.githubusercontent.com/kejilion/docker/main/cloudreve-docker-compose.yml
                    cd /home/docker/cloud/ && docker-compose up -d


                    clear
                    echo "cloudreve已经安装完成"
                    echo "------------------------"
                    echo "您可以使用以下地址访问cloudreve:"
                    ip_address
                    echo "http:$ipv4_address:5212"
                    sleep 3
                    docker logs cloudreve
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi

              ;;

          14)
            docker_name="easyimage"
            docker_img="ddsderek/easyimage:latest"
            docker_port=85
            docker_rum="docker run -d \
                      --name easyimage \
                      -p 85:80 \
                      -e TZ=Asia/Shanghai \
                      -e PUID=1000 \
                      -e PGID=1000 \
                      -v /home/docker/easyimage/config:/app/web/config \
                      -v /home/docker/easyimage/i:/app/web/i \
                      --restart unless-stopped \
                      ddsderek/easyimage:latest"
            docker_describe="简单图床是一个简单的图床程序"
            docker_url="官网介绍: https://github.com/icret/EasyImages2.0"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          15)
            docker_name="emby"
            docker_img="linuxserver/emby:latest"
            docker_port=8096
            docker_rum="docker run -d --name=emby --restart=always \
                        -v /homeo/docker/emby/config:/config \
                        -v /homeo/docker/emby/share1:/mnt/share1 \
                        -v /homeo/docker/emby/share2:/mnt/share2 \
                        -v /mnt/notify:/mnt/notify \
                        -p 8096:8096 -p 8920:8920 \
                        -e UID=1000 -e GID=100 -e GIDLIST=100 \
                        linuxserver/emby:latest"
            docker_describe="emby是一个主从式架构的媒体服务器软件，可以用来整理服务器上的视频和音频，并将音频和视频流式传输到客户端设备"
            docker_url="官网介绍: https://emby.media/"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          16)
            docker_name="looking-glass"
            docker_img="wikihostinc/looking-glass-server"
            docker_port=89
            docker_rum="docker run -d --name looking-glass --restart always -p 89:80 wikihostinc/looking-glass-server"
            docker_describe="Speedtest测速面板是一个VPS网速测试工具，多项测试功能，还可以实时监控VPS进出站流量"
            docker_url="官网介绍: https://github.com/wikihost-opensource/als"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;
          17)

            docker_name="adguardhome"
            docker_img="adguard/adguardhome"
            docker_port=3000
            docker_rum="docker run -d \
                            --name adguardhome \
                            -v /home/docker/adguardhome/work:/opt/adguardhome/work \
                            -v /home/docker/adguardhome/conf:/opt/adguardhome/conf \
                            -p 53:53/tcp \
                            -p 53:53/udp \
                            -p 3000:3000/tcp \
                            --restart always \
                            adguard/adguardhome"
            docker_describe="AdGuardHome是一款全网广告拦截与反跟踪软件，未来将不止是一个DNS服务器。"
            docker_url="官网介绍: https://hub.docker.com/r/adguard/adguardhome"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;


          18)

            docker_name="onlyoffice"
            docker_img="onlyoffice/documentserver"
            docker_port=8082
            docker_rum="docker run -d -p 8082:80 \
                        --restart=always \
                        --name onlyoffice \
                        -v /home/docker/onlyoffice/DocumentServer/logs:/var/log/onlyoffice  \
                        -v /home/docker/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  \
                         onlyoffice/documentserver"
            docker_describe="onlyoffice是一款开源的在线office工具，太强大了！"
            docker_url="官网介绍: https://www.onlyoffice.com/"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;

          19)

            if docker inspect safeline-tengine &>/dev/null; then

                    clear
                    echo "雷池已安装，访问地址: "
                    ip_address
                    echo "http:$ipv4_address:9443"
                    echo ""

                    echo "应用操作"
                    echo "------------------------"
                    echo "1. 更新应用             2. 卸载应用"
                    echo "------------------------"
                    echo "0. 返回上一级选单"
                    echo "------------------------"
                    read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice

                    case $sub_choice in
                        1)
                            clear
                            echo "暂不支持"
                            echo ""
                            ;;
                        2)

                            clear
                            echo "cd命令到安装目录下执行: docker compose down"
                            echo ""
                            ;;
                        0)
                            break  # 跳出循环，退出菜单
                            ;;
                        *)
                            break  # 跳出循环，退出菜单
                            ;;
                    esac
            else
                clear
                echo "安装提示"
                echo "雷池是长亭科技开发的WAF站点防火墙程序面板，可以反代站点进行自动化防御"
                echo "80和443端口不能被占用，无法与宝塔，1panel，npm，ldnmp建站共存"
                echo "官网介绍: https://github.com/chaitin/safeline"
                echo ""

                # 提示用户确认安装
                read -e -p "确定安装吗？(Y/N): " choice
                case "$choice" in
                    [Yy])
                    clear
                    install_docker
                    bash -c "$(curl -fsSLk https://waf-ce.chaitin.cn/release/latest/setup.sh)"

                    clear
                    echo "雷池WAF面板已经安装完成"
                    echo "------------------------"
                    echo "您可以使用以下地址访问:"
                    ip_address
                    echo "http:$ipv4_address:9443"
                    echo ""

                        ;;
                    [Nn])
                        ;;
                    *)
                        ;;
                esac
            fi

              ;;

          20)
            docker_name="portainer"
            docker_img="portainer/portainer"
            docker_port=9050
            docker_rum="docker run -d \
                    --name portainer \
                    -p 9050:9000 \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v /home/docker/portainer:/data \
                    --restart always \
                    portainer/portainer"
            docker_describe="portainer是一个轻量级的docker容器管理面板"
            docker_url="官网介绍: https://www.portainer.io/"
            docker_use=""
            docker_passwd=""
            docker_app

              ;;

          21)
            docker_name="vscode-web"
            docker_img="codercom/code-server"
            docker_port=8180
            docker_rum="docker run -d -p 8180:8080 -v /home/docker/vscode-web:/home/coder/.local/share/code-server --name vscode-web --restart always codercom/code-server"
            docker_describe="VScode是一款强大的在线代码编写工具"
            docker_url="官网介绍: https://github.com/coder/code-server"
            docker_use="sleep 3"
            docker_passwd="docker exec vscode-web cat /home/coder/.config/code-server/config.yaml"
            docker_app
              ;;
          22)
            docker_name="uptime-kuma"
            docker_img="louislam/uptime-kuma:latest"
            docker_port=3003
            docker_rum="docker run -d \
                            --name=uptime-kuma \
                            -p 3003:3001 \
                            -v /home/docker/uptime-kuma/uptime-kuma-data:/app/data \
                            --restart=always \
                            louislam/uptime-kuma:latest"
            docker_describe="Uptime Kuma 易于使用的自托管监控工具"
            docker_url="官网介绍: https://github.com/louislam/uptime-kuma"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          23)
            docker_name="memos"
            docker_img="ghcr.io/usememos/memos:latest"
            docker_port=5230
            docker_rum="docker run -d --name memos -p 5230:5230 -v /home/docker/memos:/var/opt/memos --restart always ghcr.io/usememos/memos:latest"
            docker_describe="Memos是一款轻量级、自托管的备忘录中心"
            docker_url="官网介绍: https://github.com/usememos/memos"
            docker_use=""
            docker_passwd=""
            docker_app
              ;;

          24)
            clear 
                echo "${red}项目已失效${re}"
            ;;
          0)
              main_menu
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac
      break_end

    done
}

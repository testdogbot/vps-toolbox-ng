#!/usr/bin/env bash
# vps-toolbox 模块：LDNMP 建站
# 由 eooce/ssh_tool 的菜单分支机械抽取，逻辑保持原样
menu_ldnmp() {
  clear
  while true; do
    clear
    echo -e "${purple}▶ LDNMP建站${re}"
    echo  "------------------------"
    echo  " 1. 安装LDNMP环境"
    echo  "------------------------"
    echo  " 2. 安装WordPress"
    echo  " 3. 安装Discuz论坛"
    echo  " 4. 安装可道云桌面"
    echo  " 5. 安装苹果CMS网站"
    echo  " 6. 安装独角数发卡网"
    echo  " 7. 安装BingChatAI聊天网站"
    echo  " 8. 安装flarum论坛网站"
    echo  " 9. 安装Bitwarden密码管理平台"
    echo  "10. 安装Halo博客网站"
    echo  "11. 安装typecho轻量博客网站"
    echo  "12. 安装Pbootcms企业站"
    echo  "13. 安装极致CMS企业站"
    echo  "14. 安装易优CMS企业站"
    echo  "------------------------"
    echo  "21. 仅安装nginx "
    echo  "22. 站点重定向"
    echo  "23. 站点反向代理"
    echo -e "24. 自定义静态站点"
    echo  "------------------------"
    echo  "31. 站点数据管理"
    echo  "32. 备份全站数据"
    echo  "33. 定时远程备份"
    echo  "34. 还原全站数据"
    echo  "------------------------"
    echo  "35. 站点防御程序"
    echo  "------------------------"
    echo  "36. 优化LDNMP环境"
    echo  "37. 更新LDNMP环境"
    echo  -e "${red}38. 卸载LDNMP环境${re}"
    echo  "------------------------"
    echo  -e "${yellow} 0. 返回主菜单${re}"
    echo  "------------------------"
    read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice


    case $sub_choice in
      1)
      check_port
      install_dependency
      install_docker
      install_certbot

      # 创建必要的目录和文件
      cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/redis web/log/nginx && touch web/docker-compose.yml

      wget -O /home/web/nginx.conf https://raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf
      wget -O /home/web/conf.d/default.conf https://raw.githubusercontent.com/kejilion/nginx/main/default10.conf
      default_server_ssl

      # 下载 docker-compose.yml 文件并进行替换
      wget -O /home/web/docker-compose.yml https://raw.githubusercontent.com/kejilion/docker/main/LNMP-docker-compose-10.yml

      dbrootpasswd=$(openssl rand -base64 16) && dbuse=$(openssl rand -hex 4) && dbusepasswd=$(openssl rand -base64 8)

      # 在 docker-compose.yml 文件中进行替换
      sed -i "s/webroot/$dbrootpasswd/g" /home/web/docker-compose.yml
      sed -i "s/kejilionYYDS/$dbusepasswd/g" /home/web/docker-compose.yml
      sed -i "s/kejilion/$dbuse/g" /home/web/docker-compose.yml

      install_ldnmp

        ;;
      2)
      clear
      # wordpress
      add_yuming
      install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/wordpress.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget -O latest.zip https://cn.wordpress.org/latest-zh_CN.zip
      unzip latest.zip
      rm latest.zip

      echo "define('FS_METHOD', 'direct'); define('WP_REDIS_HOST', 'redis'); define('WP_REDIS_PORT', '6379');" >> /home/web/html/$yuming/wordpress/wp-config-sample.php

      restart_ldnmp

      clear
      echo "您的WordPress搭建好了！"
      echo "https://$yuming"
      echo "------------------------"
      echo "WP安装信息如下: "
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库地址: mysql"
      echo "表前缀: wp_"
      nginx_status
        ;;

      3)
      clear
      # Discuz论坛
      add_yuming
      install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/discuz.com.conf

      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget https://github.com/kejilion/Website_source_code/raw/main/Discuz_X3.5_SC_UTF8_20230520.zip
      unzip -o Discuz_X3.5_SC_UTF8_20230520.zip
      rm Discuz_X3.5_SC_UTF8_20230520.zip

      restart_ldnmp


      clear
      echo "您的Discuz论坛搭建好了！"
      echo "https://$yuming"
      echo "------------------------"
      echo "安装信息如下: "
      echo "数据库地址: mysql"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "表前缀: discuz_"
      nginx_status

        ;;

      4)
      clear
      # 可道云桌面
      add_yuming
      install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/kdy.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget https://github.com/kalcaddle/kodbox/archive/refs/tags/1.42.04.zip
      unzip -o 1.42.04.zip
      rm 1.42.04.zip

      restart_ldnmp


      clear
      echo "您的可道云桌面搭建好了！"
      echo "https://$yuming"
      echo "------------------------"
      echo "安装信息如下: "
      echo "数据库地址: mysql"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库名: $dbname"
      echo "redis主机: redis"
      nginx_status
        ;;

      5)
      clear
      # 苹果CMS
      add_yuming
      install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/maccms.com.conf

      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget https://github.com/magicblack/maccms_down/raw/master/maccms10.zip && unzip maccms10.zip && rm maccms10.zip
      cd /home/web/html/$yuming/maccms10-master/template/ && wget https://github.com/kejilion/Website_source_code/raw/main/DYXS2.zip && unzip DYXS2.zip && rm /home/web/html/$yuming/maccms10-master/template/DYXS2.zip
      cp /home/web/html/$yuming/maccms10-master/template/DYXS2/asset/admin/Dyxs2.php /home/web/html/$yuming/maccms10-master/application/admin/controller
      cp /home/web/html/$yuming/maccms10-master/template/DYXS2/asset/admin/dycms.html /home/web/html/$yuming/maccms10-master/application/admin/view/system
      mv /home/web/html/$yuming/maccms10-master/admin.php /home/web/html/$yuming/maccms10-master/vip.php && wget -O /home/web/html/$yuming/maccms10-master/application/extra/maccms.php https://raw.githubusercontent.com/kejilion/Website_source_code/main/maccms.php

      restart_ldnmp


      clear
      echo "您的苹果CMS搭建好了！"
      echo "https://$yuming"
      echo "------------------------"
      echo "安装信息如下: "
      echo "数据库地址: mysql"
      echo "数据库端口: 3306"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库前缀: mac_"
      echo "------------------------"
      echo "安装成功后登录后台地址"
      echo "https://$yuming/vip.php"
      nginx_status
        ;;

      6)
      clear
      # 独脚数卡
      add_yuming
      install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/dujiaoka.com.conf

      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget https://github.com/assimon/dujiaoka/releases/download/2.0.6/2.0.6-antibody.tar.gz && tar -zxvf 2.0.6-antibody.tar.gz && rm 2.0.6-antibody.tar.gz

      restart_ldnmp


      clear
      echo "您的独角数卡网站搭建好了！"
      echo "https://$yuming"
      echo "------------------------"
      echo "安装信息如下: "
      echo "数据库地址: mysql"
      echo "数据库端口: 3306"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo ""
      echo "redis地址: redis"
      echo "redis密码: 默认不填写"
      echo "redis端口: 6379"
      echo ""
      echo "网站url: https://$yuming"
      echo "后台登录路径: /admin"
      echo "------------------------"
      echo "用户名: admin"
      echo "密码: admin"
      echo "------------------------"
      echo "登录时右上角如果出现红色error0请使用如下命令: "
      echo "我也很气愤独角数卡为啥这么麻烦，会有这样的问题！"
      echo "sed -i 's/ADMIN_HTTPS=false/ADMIN_HTTPS=true/g' /home/web/html/$yuming/dujiaoka/.env"
      nginx_status
        ;;

      7)
      clear
      # BingChat
      add_yuming
      install_ssltls

      docker run -d -p 3099:8080 --name go-proxy-bingai --restart=unless-stopped adams549659584/go-proxy-bingai
      duankou=3099
      reverse_proxy

      clear
      echo "您的BingChat网站搭建好了！"
      echo "https://$yuming"
      nginx_status
        ;;

      8)
      clear
      # flarum论坛
      add_yuming
      install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/flarum.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming

      docker exec php sh -c "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\""
      docker exec php sh -c "php composer-setup.php"
      docker exec php sh -c "php -r \"unlink('composer-setup.php');\""
      docker exec php sh -c "mv composer.phar /usr/local/bin/composer"

      docker exec php composer create-project flarum/flarum /var/www/html/$yuming
      docker exec php sh -c "cd /var/www/html/$yuming && composer require flarum-lang/chinese-simplified"
      docker exec php sh -c "cd /var/www/html/$yuming && composer require fof/polls"

      restart_ldnmp


      clear
      echo "您的flarum论坛网站搭建好了！"
      echo "https://$yuming"
      echo "------------------------"
      echo "安装信息如下: "
      echo "数据库地址: mysql"
      echo "数据库名: $dbname"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "表前缀: flarum_"
      echo "管理员信息自行设置"
      nginx_status
        ;;

      9)
      clear
      # Bitwarden
      add_yuming
      install_ssltls

      docker run -d \
        --name bitwarden \
        --restart always \
        -p 3280:80 \
        -v /home/web/html/$yuming/bitwarden/data:/data \
        vaultwarden/server
      duankou=3280
      reverse_proxy

      clear
      echo "您的Bitwarden网站搭建好了！"
      echo "https://$yuming"
      nginx_status
        ;;

      10)
      clear
      # halo
      add_yuming
      install_ssltls

      docker run -d --name halo --restart always --network web_default -p 8010:8090 -v /home/web/html/$yuming/.halo2:/root/.halo2 halohub/halo:2.9
      duankou=8010
      reverse_proxy

      clear
      echo "您的Halo网站搭建好了！"
      echo "https://$yuming"
      nginx_status
        ;;

      11)
      clear
      # typecho
      add_yuming
      install_ssltls
      add_db

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/typecho.com.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming
      wget -O latest.zip https://github.com/typecho/typecho/releases/latest/download/typecho.zip
      unzip latest.zip
      rm latest.zip

      restart_ldnmp


      clear
      echo "您的typecho搭建好了！"
      echo "https://$yuming"
      echo "------------------------"
      echo "安装信息如下: "
      echo "数据库前缀: typecho_"
      echo "数据库地址: mysql"
      echo "用户名: $dbuse"
      echo "密码: $dbusepasswd"
      echo "数据库名: $dbname"
      nginx_status
        ;;



      12)
      clear
        echo -e "${red}很抱歉，该模块正在开发中${re}"
        sleep 2
        main_menu
      ;;


      13)
      clear
        echo -e "${red}很抱歉，该模块正在开发中${re}"
        sleep 2
        main_menu

      ;;

      13)
      clear
        echo -e "${red}很抱歉，该模块正在开发中${re}"
        sleep 2
        main_menu

      ;;

      14)
      clear
        echo -e "${red}很抱歉，该模块正在开发中${re}"
        sleep 2
        main_menu

      ;;

      15)
      clear
        echo -e "${red}很抱歉，该模块正在开发中${re}"
        sleep 2
        main_menu

      ;;



      21)
      check_port
      install_dependency
      install_docker
      install_certbot

      cd /home && mkdir -p web/html web/mysql web/certs web/conf.d web/redis web/log/nginx && touch web/docker-compose.yml

      wget -O /home/web/nginx.conf https://raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf
      wget -O /home/web/conf.d/default.conf https://raw.githubusercontent.com/kejilion/nginx/main/default10.conf
      default_server_ssl
      docker rm -f nginx >/dev/null 2>&1
      docker rmi nginx >/dev/null 2>&1
      docker run -d --name nginx --restart always -p 80:80 -p 443:443 -v /home/web/nginx.conf:/etc/nginx/nginx.conf -v /home/web/conf.d:/etc/nginx/conf.d -v /home/web/certs:/etc/nginx/certs -v /home/web/html:/var/www/html -v /home/web/log/nginx:/var/log/nginx nginx

      clear
      nginx_version=$(docker exec nginx nginx -v 2>&1)
      nginx_version=$(echo "$nginx_version" | grep -oP "nginx/\K[0-9]+\.[0-9]+\.[0-9]+")
      echo "nginx已安装完成"
      echo "当前版本: v$nginx_version"
      echo ""
        ;;

      22)
      clear
      ip_address
      echo -e "先将域名解析到本机IP: \033[33m$ipv4_address\033[0m"
      read -e -p "请输入你的域名: " yuming
      read -e -p "请输入跳转域名: " reverseproxy

      install_ssltls

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/rewrite.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      sed -i "s/baidu.com/$reverseproxy/g" /home/web/conf.d/$yuming.conf

      docker restart nginx

      clear
      echo "您的重定向网站做好了！"
      echo "https://$yuming"
      nginx_status

        ;;

      23)
      clear
      ip_address
      echo -e "先将域名解析到本机IP: \033[33m$ipv4_address\033[0m"
      read -e -p "请输入你的域名: " yuming
      read -e -p "请输入你的反代IP: " reverseproxy
      read -e -p "请输入你的反代端口: " port

      install_ssltls

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/reverse-proxy.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf
      sed -i "s/0.0.0.0/$reverseproxy/g" /home/web/conf.d/$yuming.conf
      sed -i "s/0000/$port/g" /home/web/conf.d/$yuming.conf

      docker restart nginx

      clear
      echo "您的反向代理网站做好了！"
      echo "https://$yuming"
      nginx_status
        ;;

      24)
      clear
      # 静态界面
      add_yuming
      install_ssltls

      wget -O /home/web/conf.d/$yuming.conf https://raw.githubusercontent.com/kejilion/nginx/main/html.conf
      sed -i "s/yuming.com/$yuming/g" /home/web/conf.d/$yuming.conf

      cd /home/web/html
      mkdir $yuming
      cd $yuming

      install lrzsz
      clear
      echo -e "目前只允许上传\033[33mindex.html\033[0m文件，请提前准备好，按任意键继续..."
      read -n 1 -s -r -p ""
      rz

      docker exec nginx chmod -R 777 /var/www/html
      docker restart nginx

      clear
      echo "您的静态网站搭建好了！"
      echo "https://$yuming"
      nginx_status
        ;;

    31)
    while true; do
        clear
        echo "LDNMP环境"
        echo "------------------------"
        # 获取nginx版本
        nginx_version=$(docker exec nginx nginx -v 2>&1)
        nginx_version=$(echo "$nginx_version" | grep -oP "nginx/\K[0-9]+\.[0-9]+\.[0-9]+")
        echo -n "nginx : v$nginx_version"
        # 获取mysql版本
        dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
        mysql_version=$(docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SELECT VERSION();" 2>/dev/null | tail -n 1)
        echo -n "            mysql : v$mysql_version"
        # 获取php版本
        php_version=$(docker exec php php -v 2>/dev/null | grep -oP "PHP \K[0-9]+\.[0-9]+\.[0-9]+")
        echo -n "            php : v$php_version"
        # 获取redis版本
        redis_version=$(docker exec redis redis-server -v 2>&1 | grep -oP "v=+\K[0-9]+\.[0-9]+")
        echo "            redis : v$redis_version"
        echo "------------------------"
        echo ""


        # ls -t /home/web/conf.d | sed 's/\.[^.]*$//'
        echo "站点信息                      证书到期时间"
        echo "------------------------"
        for cert_file in /home/web/certs/*_cert.pem; do
          domain=$(basename "$cert_file" | sed 's/_cert.pem//')
          if [ -n "$domain" ]; then
            expire_date=$(openssl x509 -noout -enddate -in "$cert_file" | awk -F'=' '{print $2}')
            formatted_date=$(date -d "$expire_date" '+%Y-%m-%d')
            printf "%-30s%s\n" "$domain" "$formatted_date"
          fi
        done

        echo "------------------------"
        echo ""
        echo "数据库信息"
        echo "------------------------"
        dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
        docker exec mysql mysql -u root -p"$dbrootpasswd" -e "SHOW DATABASES;" 2> /dev/null | grep -Ev "Database|information_schema|mysql|performance_schema|sys"

        echo "------------------------"
        echo ""
        echo "操作"
        echo "------------------------"
        echo "1. 申请/更新域名证书               2. 更换站点域名"
        echo -e "3. 清理站点缓存                    4. 查看站点分析报告 \033[33mNEW\033[0m"
        echo "------------------------"
        echo "7. 删除指定站点                    8. 删除指定数据库"
        echo "------------------------"
        echo "0. 返回上一级选单"
        echo "------------------------"
        read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice
        case $sub_choice in
            1)
                read -e -p "请输入你的域名: " yuming
                install_ssltls

                ;;

            2)
                read -e -p "请输入旧域名: " oddyuming
                read -e -p "请输入新域名: " yuming
                mv /home/web/conf.d/$oddyuming.conf /home/web/conf.d/$yuming.conf
                sed -i "s/$oddyuming/$yuming/g" /home/web/conf.d/$yuming.conf
                mv /home/web/html/$oddyuming /home/web/html/$yuming

                rm /home/web/certs/${oddyuming}_key.pem
                rm /home/web/certs/${oddyuming}_cert.pem
                install_ssltls

                ;;


            3)
                docker exec -it nginx rm -rf /var/cache/nginx
                docker restart nginx
                ;;
            4)
                install goaccess
                goaccess --log-format=COMBINED /home/web/log/nginx/access.log

                ;;

            7)
                read -e -p "请输入你的域名: " yuming
                rm -r /home/web/html/$yuming
                rm /home/web/conf.d/$yuming.conf
                rm /home/web/certs/${yuming}_key.pem
                rm /home/web/certs/${yuming}_cert.pem
                docker restart nginx
                ;;
            8)
                read -e -p "请输入数据库名: " shujuku
                dbrootpasswd=$(grep -oP 'MYSQL_ROOT_PASSWORD:\s*\K.*' /home/web/docker-compose.yml | tr -d '[:space:]')
                docker exec mysql mysql -u root -p"$dbrootpasswd" -e "DROP DATABASE $shujuku;" 2> /dev/null
                ;;
            0)
                break  # 跳出循环，退出菜单
                ;;
            *)
                break  # 跳出循环，退出菜单
                ;;
        esac
    done

      ;;


    32)
      clear
      cd /home/ && tar czvf web_$(date +"%Y%m%d%H%M%S").tar.gz web

      while true; do
        clear
        read -e -p "要传送文件到远程服务器吗？(Y/N): " choice
        case "$choice" in
          [Yy])
            read -e -p "请输入远端服务器IP:  " remote_ip
            if [ -z "$remote_ip" ]; then
              echo "错误: 请输入远端服务器IP。"
              continue
            fi
            latest_tar=$(ls -t /home/*.tar.gz | head -1)
            if [ -n "$latest_tar" ]; then
              ssh-keygen -f "/root/.ssh/known_hosts" -R "$remote_ip"
              sleep 2  # 添加等待时间
              scp -o StrictHostKeyChecking=no "$latest_tar" "root@$remote_ip:/home/"
              echo "文件已传送至远程服务器home目录。"
            else
              echo "未找到要传送的文件。"
            fi
            break
            ;;
          [Nn])
            break
            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
      done
      ;;

    33)
      clear
      read -e -p "输入远程服务器IP: " useip
      read -e -p "输入远程服务器密码: " usepasswd

      wget -O ${useip}_beifen.sh https://raw.githubusercontent.com/kejilion/sh/main/beifen.sh > /dev/null 2>&1
      chmod +x ${useip}_beifen.sh

      sed -i "s/0.0.0.0/$useip/g" ${useip}_beifen.sh
      sed -i "s/123456/$usepasswd/g" ${useip}_beifen.sh

      echo "------------------------"
      echo "1. 每周备份                 2. 每天备份"
      read -e -p $'\033[1;91m请输入你的选择: \033[0m' dingshi

      case $dingshi in
          1)
              read -e -p "选择每周备份的星期几 (0-6，0代表星期日): " weekday
              (crontab -l ; echo "0 0 * * $weekday ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
              ;;
          2)
              read -e -p "选择每天备份的时间（小时，0-23）: " hour
              (crontab -l ; echo "0 $hour * * * ./${useip}_beifen.sh") | crontab - > /dev/null 2>&1
              ;;
          *)
              break  # 跳出
              ;;
      esac

      install sshpass

      ;;

    34)
      clear
      cd /home/ && ls -t /home/*.tar.gz | head -1 | xargs -I {} tar -xzf {}
      check_port
      install_dependency
      install_docker
      install_certbot
      install_ldnmp

      ;;

    35)
      if [ -x "$(command -v fail2ban-client)" ] && [ -d "/etc/fail2ban" ]; then
          while true; do
              clear
              echo "服务器防御程序已启动"
              echo "------------------------"
              echo "1. 开启SSH防暴力破解              2. 关闭SSH防暴力破解"
              echo "3. 开启网站保护                   4. 关闭网站保护"
              echo "------------------------"
              echo "5. 查看SSH拦截记录                6. 查看网站拦截记录"
              echo "7. 查看防御规则列表               8. 查看日志实时监控"
              echo "------------------------"
              echo "9. 卸载防御程序"
              echo "------------------------"
              echo "0. 退出"
              echo "------------------------"
              read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice
              case $sub_choice in
                  1)
                      sed -i 's/false/true/g' /etc/fail2ban/jail.d/sshd.local
                      systemctl restart fail2ban
                      sleep 1
                      fail2ban-client status
                      ;;
                  2)
                      sed -i 's/true/false/g' /etc/fail2ban/jail.d/sshd.local
                      systemctl restart fail2ban
                      sleep 1
                      fail2ban-client status
                      ;;
                  3)
                      sed -i 's/false/true/g' /etc/fail2ban/jail.d/nginx.local
                      systemctl restart fail2ban
                      sleep 1
                      fail2ban-client status
                      ;;
                  4)
                      sed -i 's/true/false/g' /etc/fail2ban/jail.d/nginx.local
                      systemctl restart fail2ban
                      sleep 1
                      fail2ban-client status
                      ;;
                  5)
                      echo "------------------------"
                      fail2ban-client status sshd
                      echo "------------------------"
                      ;;
                  6)
                      echo "------------------------"
                      fail2ban-client status nginx-bad-request
                      echo "------------------------"
                      fail2ban-client status nginx-botsearch
                      echo "------------------------"
                      fail2ban-client status nginx-http-auth
                      echo "------------------------"
                      fail2ban-client status nginx-limit-req
                      echo "------------------------"
                      fail2ban-client status php-url-fopen
                      echo "------------------------"
                      ;;

                  7)
                      fail2ban-client status
                      ;;
                  8)
                      tail -f /var/log/fail2ban.log

                      ;;
                  9)
                      remove fail2ban
                      break
                      ;;
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入。"
                      ;;
              esac
              break_end

          done
      else
          clear
          # 安装Fail2ban
          if [ -f /etc/debian_version ]; then
              # Debian/Ubuntu系统
              install fail2ban
          elif [ -f /etc/redhat-release ]; then
              # CentOS系统
              install epel-release fail2ban
          else
              echo "不支持的操作系统类型"
              exit 1
          fi

          # 启动Fail2ban
          systemctl start fail2ban

          # 设置Fail2ban开机自启
          systemctl enable fail2ban

          # 配置Fail2ban
          rm -rf /etc/fail2ban/jail.d/*
          cd /etc/fail2ban/jail.d/
          curl -sS -O https://raw.githubusercontent.com/kejilion/sh/main/sshd.local
          systemctl restart fail2ban
          docker rm -f nginx

          wget -O /home/web/nginx.conf https://raw.githubusercontent.com/kejilion/nginx/main/nginx10.conf
          wget -O /home/web/conf.d/default.conf https://raw.githubusercontent.com/kejilion/nginx/main/default10.conf
          default_server_ssl
          docker run -d --name nginx --restart always --network web_default -p 80:80 -p 443:443 -v /home/web/nginx.conf:/etc/nginx/nginx.conf -v /home/web/conf.d:/etc/nginx/conf.d -v /home/web/certs:/etc/nginx/certs -v /home/web/html:/var/www/html -v /home/web/log/nginx:/var/log/nginx nginx
          docker exec -it nginx chmod -R 777 /var/www/html

          # 获取宿主机当前时区
          HOST_TIMEZONE=$(timedatectl show --property=Timezone --value)

          # 调整多个容器的时区
          docker exec -it nginx ln -sf "/usr/share/zoneinfo/$HOST_TIMEZONE" /etc/localtime
          docker exec -it php ln -sf "/usr/share/zoneinfo/$HOST_TIMEZONE" /etc/localtime
          docker exec -it php74 ln -sf "/usr/share/zoneinfo/$HOST_TIMEZONE" /etc/localtime
          docker exec -it mysql ln -sf "/usr/share/zoneinfo/$HOST_TIMEZONE" /etc/localtime
          docker exec -it redis ln -sf "/usr/share/zoneinfo/$HOST_TIMEZONE" /etc/localtime
          rm -rf /home/web/log/nginx/*
          docker restart nginx

          curl -sS -O https://raw.githubusercontent.com/kejilion/sh/main/nginx.local
          systemctl restart fail2ban
          sleep 1
          fail2ban-client status
          echo "防御程序已开启"
      fi

        ;;

    36)
          while true; do
              clear
              echo "优化LDNMP环境"
              echo "------------------------"
              echo "1. 标准模式              2. 高性能模式 (推荐2H2G以上)"
              echo "------------------------"
              echo "0. 退出"
              echo "------------------------"
              read -e -p $'\033[1;91m请输入你的选择: \033[0m' sub_choice
              case $sub_choice in
                  1)
                  # nginx调优
                  sed -i 's/worker_connections.*/worker_connections 1024;/' /home/web/nginx.conf

                  # php调优
                  wget -O /home/www.conf https://raw.githubusercontent.com/kejilion/sh/main/www-1.conf
                  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
                  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
                  rm -rf /home/www.conf

                  # mysql调优
                  wget -O /home/custom_mysql_config.cnf https://raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config-1.cnf
                  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
                  rm -rf /home/custom_mysql_config.cnf

                  docker restart nginx
                  docker restart php
                  docker restart php74
                  docker restart mysql

                  echo "LDNMP环境已设置成 标准模式"

                      ;;
                  2)

                  # nginx调优
                  sed -i 's/worker_connections.*/worker_connections 131072;/' /home/web/nginx.conf

                  # php调优
                  wget -O /home/www.conf https://raw.githubusercontent.com/kejilion/sh/main/www.conf
                  docker cp /home/www.conf php:/usr/local/etc/php-fpm.d/www.conf
                  docker cp /home/www.conf php74:/usr/local/etc/php-fpm.d/www.conf
                  rm -rf /home/www.conf

                  # mysql调优
                  wget -O /home/custom_mysql_config.cnf https://raw.githubusercontent.com/kejilion/sh/main/custom_mysql_config.cnf
                  docker cp /home/custom_mysql_config.cnf mysql:/etc/mysql/conf.d/
                  rm -rf /home/custom_mysql_config.cnf

                  docker restart nginx
                  docker restart php
                  docker restart php74
                  docker restart mysql

                  echo "LDNMP环境已设置成 高性能模式"

                      ;;
                  0)
                      break
                      ;;
                  *)
                      echo "无效的选择，请重新输入。"
                      ;;
              esac
              break_end

          done
        ;;


    37)
      clear
      docker rm -f nginx php php74 mysql redis
      docker rmi nginx php:fpm php:7.4.33-fpm mysql redis

      check_port
      install_dependency
      install_docker
      install_certbot
      install_ldnmp
      ;;



    38)
        clear
        read -e -p "强烈建议先备份全部网站数据，再卸载LDNMP环境。确定删除所有网站数据吗？(Y/N): " choice
        case "$choice" in
          [Yy])
            docker rm -f nginx php php74 mysql redis
            docker rmi nginx php:fpm php:7.4.33-fpm mysql redis
            rm -r /home/web
            ;;
          [Nn])

            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
        ;;

    0)
        main_menu
      ;;

    *)
        echo "无效的输入!"
    esac
    break_end

    done
}

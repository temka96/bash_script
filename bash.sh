#!/usr/bin/env bash

PORT="Port 31337"
USER="serviceuser"

#apt update && apt upgrade tzdata
#dpkg-reconfigure tzdata
echo Europe/Moscow > /etc/timezone
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

locale-gen en_US.UTF-8 ru_RU.UTF-8

sed -i "s/#Port 22/${PORT}/" /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
systemctl restart ssh

useradd -s /bin/bash $USER 
echo "${USER} ALL=(root) NOPASSWD: /bin/systemctl" > /etc/sudoers.d/$USER

apt update

apt install nginx -y
systemctl enable nginx
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
cat << EOF > /etc/nginx/sites-available/default

server {                                        
        listen 80;                          
        server_name monit;                  
        location / {                         
                proxy_pass http://localhost:2812;
        }
}
EOF
systemctl restart nginx

apt install monit -y
systemctl enable monit
sed -i "s/# set httpd port 2812 and/set httpd port 2812 and/" /etc/monit/monitrc
sed -i "s/#     allow admin:monit/allow admin:qwerty/" /etc/monit/monitrc
systemctl restart monit

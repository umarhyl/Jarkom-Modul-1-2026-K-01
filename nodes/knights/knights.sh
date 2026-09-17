#!/bin/sh

# Question 12 - 13
# ssh (port 22)
apk update
apk add openssh

adduser -D -s /bin/ash mika_admin
echo "mika_admin:mika123" | chpasswd

ssh-keygen -A

mkdir -p /home/mika_admin/.ssh
chmod 700 /home/mika_admin/.ssh
chown -R mika_admin:mika_admin /home/mika_admin/.ssh

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sed -i '/^#*PubkeyAuthentication /d' /etc/ssh/sshd_config
sed -i '/^#*PasswordAuthentication /d' /etc/ssh/sshd_config
sed -i '/^#*PermitRootLogin /d' /etc/ssh/sshd_config

cat >> /etc/ssh/sshd_config <<EOF
PubkeyAuthentication yes
PasswordAuthentication yes
PermitRootLogin no
EOF

pkill sshd 2>/dev/null || true
/usr/sbin/sshd

# http (port 80)
mkdir -p /www
echo "Knights HTTP Server" > /www/index.html
httpd -p 80 -h /www

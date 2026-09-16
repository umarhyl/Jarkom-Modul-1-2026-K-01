#!/bin/sh

# Question 10
ping -c 77 -s 128 -i 0.3 10.64.2.2

# Question 12 - 13
# ssh (port 22)
apk update
apk add openssh
ssh-keygen -A

id mika_admin >/dev/null 2>&1 || adduser -D mika_admin
echo "mika_admin:mika123" | chpasswd

sed -i \
    -e 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' \
    -e 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' \
    /etc/ssh/sshd_config

grep -q '^PubkeyAuthentication ' /etc/ssh/sshd_config ||
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

grep -q '^PasswordAuthentication ' /etc/ssh/sshd_config ||
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

pkill sshd 2>/dev/null || true
/usr/sbin/sshd


# http (port 80)
mkdir -p /www
echo "Knights HTTP Server" > /www/index.html
httpd -p 80 -h /www



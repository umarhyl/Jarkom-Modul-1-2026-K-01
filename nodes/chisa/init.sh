#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.2.2
    netmask 255.255.255.0
    gateway 10.64.2.1
    up echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

# telnet
# Question 11

# add telnetd
apk update
apk add telnetd

# add user phantom_user
adduser -D phantom_user
echo "phantom_user:wired_ghost" | chpasswd

# run telnetd
telnetd -p 23 &
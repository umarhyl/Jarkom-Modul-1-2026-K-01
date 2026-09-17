#!/bin/sh

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.64.3.2
    netmask 255.255.255.0
    gateway 10.64.3.1
    up echo "nameserver 8.8.8.8" > /etc/resolv.conf
EOF
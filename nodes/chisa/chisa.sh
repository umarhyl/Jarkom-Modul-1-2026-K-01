#!/bin/sh

# Question 11

# add telnetd
apk update
apk add telnetd

# add user phantom_user
adduser -D phantom_user
echo "phantom_user:wired_ghost" | chpasswd

# run telnetd
telnetd -p 23 &
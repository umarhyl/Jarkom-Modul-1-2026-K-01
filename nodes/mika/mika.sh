#!/bin/sh

apk update
apk add openssh-client

mkdir -p ~/.ssh
chmod 700 ~/.ssh

ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub
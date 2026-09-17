#!/bin/sh

apk update
apk add openssh-client

mkdir -p ~/.ssh
chmod 700 ~/.ssh

ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

ssh-copy-id -o StrictHostKeyChecking=no mika_admin@10.64.3.2

ssh mika_admin@10.64.3.2
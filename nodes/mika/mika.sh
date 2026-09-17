#!/bin/sh

apk update
apk add openssh-client

id mika_admin >/dev/null 2>&1 || adduser -D mika_admin

su - mika_admin -c '
mkdir -p ~/.ssh
chmod 700 ~/.ssh

ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
'

su - mika_admin -c "ssh-copy-id -o StrictHostKeyChecking=no mika_admin@10.64.3.2"

su - mika_admin -c "ssh mika_admin@10.64.3.2"
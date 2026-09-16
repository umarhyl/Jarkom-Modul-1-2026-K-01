#!/bin/sh

FTP_DIR="/var/wired/data"
VSFTPD_CONF="/etc/vsftpd/vsftpd.conf"
VSFTPD_USERS="/etc/vsftpd/users"
USERLIST="/etc/vsftpd/user_list"

apk update
apk add vsftpd

id alice >/dev/null 2>&1 || adduser -D alice
echo "alice:alice123" | chpasswd

id mika >/dev/null 2>&1 || adduser -D mika
echo "mika:mika123" | chpasswd

id eiri >/dev/null 2>&1 || adduser -D eiri
echo "eiri:eiri123" | chpasswd

mkdir -p "$FTP_DIR"

chown alice:alice "$FTP_DIR"
chmod 755 "$FTP_DIR"


mkdir -p /etc/vsftpd
mkdir -p "$VSFTPD_USERS"

cat <<EOF > "$VSFTPD_CONF"
listen=YES
listen_address=0.0.0.0
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_root=$FTP_DIR
chroot_local_user=YES
allow_writeable_chroot=YES
user_config_dir=$VSFTPD_USERS
userlist_enable=YES
userlist_deny=YES
userlist_file=$USERLIST
pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100
local_umask=022
EOF

cat <<EOF > "$VSFTPD_USERS/alice"
write_enable=YES
EOF

cat <<EOF > "$VSFTPD_USERS/mika"
write_enable=NO
EOF

cat <<EOF > "$USERLIST"
eiri
EOF

pkill vsftpd 2>/dev/null || true

vsftpd "$VSFTPD_CONF" &
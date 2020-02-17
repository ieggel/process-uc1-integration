#!/bin/bash

# Configure autoselection for davfs2 package
cat <<EOF | sudo debconf-set-selections
davfs2 davfs2/suid_file boolean false
EOF

#Install davfs2
sudo apt install -y davfs2

#Define lobcder webdav credentials
WEBDAV_SERVER_URL=
WEBDAV_USERNAME=
WEBDAV_PASSWORD=

#Add line of credentials to /etc/davfs2/secrets if it does not exist it, so they credentials will not be asked for each time we mount
# -q => quiet, -x => match whole line, -F => pattern is plain string
grep -qxF "${WEBDAV_SERVER_URL} ${WEBDAV_USERNAME} ${WEBDAV_PASSWORD}" /etc/davfs2/secrets || echo "${WEBDAV_SERVER_URL} ${WEBDAV_USERNAME} ${WEBDAV_PASSWORD}">> /etc/davfs2/secrets

#Change permissions for secrets file (only visible to root)
chmod 600 /etc/davfs2/secrets

#Create target mount dir
mkdir -p /mnt/lobcder

#Add line to /etc/fstab if does not exist yet
grep -qxF "${WEBDAV_SERVER_URL} /mnt/lobcder davfs _netdev,x-systemd.automount 0 0" /etc/fstab || echo "${WEBDAV_SERVER_URL} /mnt/lobcder davfs _netdev,x-systemd.automount 0 0">> /etc/fstab

#Mount manually for first time
mount /mnt/lobcder

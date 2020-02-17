#!/bin/bash

#NOTES
#**************************************************************
# This script does the following:
# - Install webdav client
# - Configure lobcder webdav access
# - Mount lobcder webdav to target mount dir (/mnt/lobcder)
# - Launch docker container for UC1 (patch extraction)
# - Unmount mounted lobcder dir
#**************************************************************

# Configure autoselection for davfs2 package
cat <<EOF | debconf-set-selections 
davfs2 davfs2/suid_file boolean false 
EOF

#Install davfs2
apt install -y davfs2

#Define lobcder webdav credentials
WEBDAV_SERVER_URL=
WEBDAV_USERNAME=
WEBDAV_PASSWORD=

#Write credentials to secrets file, so they will not be asked for during execution
# -q => quiet, -x => match whole line, -F => pattern is plain string
grep -qxF "${WEBDAV_SERVER_URL} ${WEBDAV_USERNAME} ${WEBDAV_PASSWORD}" /etc/davfs2/secrets || echo "${WEBDAV_SERVER_URL} ${WEBDAV_USERNAME} ${WEBDAV_PASSWORD}">> /etc/davfs2/secrets

#Change permissions for secrets file (only visible to root)
chmod 600 /etc/davfs2/secrets

#Create target mount dir
mkdir -p /mnt/lobcder

#Mount lobcder via webdav to target mount dir
mount -t davfs "$WEBDAV_SERVER_URL" /mnt/lobcder

#--LAUNCH DOCKER CONTAINER

#-------------------------

#Unmount target mount dir (write cache content)




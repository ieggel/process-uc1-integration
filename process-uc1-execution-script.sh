
#!/bin/bash

#NOTES
#******************************************************************************
# * This script does the following:
#  - Define lobcder webdav credentials
#  - Install and configure webdav client
#  - Mount lobcder webdav to target mount dir (/mnt/lobcder)
#  - Launch docker container for UC1 (patch extraction)
#  - Unmount mounted lobcder dir (in order to write cash to remote resource)
#
#
# * Before executing this script you have to provide the lobcder credentails,
#   by defining values for the following variables:
#  - WEBDAV_SERVER_URL
#  - WEBDAV_USERNAME
#  - WEBDAV_PASSWORD
#
# * Script should be called from current directory
#   - ./process-uc1-execution-script.sh
#******************************************************************************

#Define lobcder webdav credentials
#WEBDAV_SERVER_URL=
#WEBDAV_USERNAME=
#WEBDAV_PASSWORD=

# Configure autoselection for davfs2 package
cat <<EOF | sudo debconf-set-selections 
davfs2 davfs2/suid_file boolean false 
EOF

#Install davfs2
sudo apt install -y davfs2

#Write credentials to secrets file, so they will not be asked for during execution
# -q => quiet, -x => match whole line, -F => pattern is plain string
sudo grep -qxF "${WEBDAV_SERVER_URL} ${WEBDAV_USERNAME} ${WEBDAV_PASSWORD}" /etc/davfs2/secrets || echo "${WEBDAV_SERVER_URL} ${WEBDAV_USERNAME} ${WEBDAV_PASSWORD}" | sudo tee -a /etc/davfs2/secrets >/dev/null

#Increase davfs2 cache size to 10GB
#(davfs2 fully downloads each file that is accessed to a cache dir, if cache size is not big enough, redownload will be triggered indefinitely)
sudo grep -qxF "cache_size	15000" /etc/davfs2/davfs2.conf || echo "cache_size	15000" | sudo tee -a /etc/davfs2/davfs2.conf

#Change permissions for secrets file (only visible to root)
sudo chmod 600 /etc/davfs2/secrets

#Create target mount dir
sudo mkdir -p /mnt/lobcder
#Mount lobcder via webdav to target mount dir

sudo mount -t davfs "$WEBDAV_SERVER_URL" /mnt/lobcder

#Build Docker image
docker build -t medgift/process-uc1-patch-extraction ./docker

#--LAUNCH DOCKER CONTAINER
docker run --rm -v /mnt/lobcder/snedtn/camelyon17:/process-uc1/data/camelyon17 -v  /mnt/lobcder/snedtn/uc1-results:/process-uc1/results medgift/process-uc1-patch-extraction
#-------------------------

#Unmount target mount dir (write cache content)
sudo umount /mnt/lobcder



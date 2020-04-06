
#!/bin/bash

#NOTES
#******************************************************************************
# SSHFS VERSION
#
# * This script does the following:
#  - Define lobcder webdav credentials
#  - Install and configure webdav client
#  - Mount lobcder webdav to target mount dir (/mnt/lobcder)
#  - Launch docker container for UC1 (patch extraction)
#  - Unmount mounted lobcder dir (in order to write cash to remote resource)
#
#
# * Before executing this script you have to make sure that the private key
#   is placed on the machne that executes this script
#
# * Script should be called from current directory
#   - ./process-uc1-execution-script-sshfs.sh
#******************************************************************************

set -euxo pipefail

ssh_server_host=sne-dtn-03.vlan7.uvalight.net
ssh_server_port_nbr=30909
target_mnt_dir=/mnt/snedtn

#Install sshfs client
sudo apt install -y sshfs

#Create target mount dir if necessary
if [[ -d "$target_mnt_dir" ]]; then
    echo "Target mount dir ${target_mnt_dir} already exist. Skip creation."
else
    echo "Creating target mount dir ${target_mnt_dir}."
    sudo mkdir -p $target_mnt_dir
    sudo chown -R $USER:$USER $target_mnt_dir
fi


#Add 'user_allow_other' to fuse.conf. This is need so a fuse dir can be specified as docker host mount
sudo grep -qxF "user_allow_other" /etc/fuse.conf || echo "user_allow_other" | sudo tee -a /etc/fuse.conf

#Mount snetdn via sshfs to target mount dir
ssh-keyscan -p $ssh_server_port_nbr -H $ssh_server_host >> ~/.ssh/known_hosts
sshfs -o allow_other root@$ssh_server_host:/mnt $target_mnt_dir -o IdentityFile=~/.ssh/id_rsa_process_uc1 -p $ssh_server_port_nbr

#Build Docker image
docker build -t medgift/process-uc1-patch-extraction ./docker

#--LAUNCH DOCKER CONTAINER, OVERRIDE DEFAULT COMMAND BECAUSE WE WANT TO PROVIDE SPECIFIC PATIENTS
patients=$(ls $target_mnt_dir/camelyon17/lesion_annotations | xargs -I '{}' basename '{}' .xml | tr '\n' ' ')
echo "Running patch extract for following patients: $patients"
#docker run --rm -v $target_mnt_dir/camelyon17:/process-uc1/data/camelyon17 -v  $target_mnt_dir/uc1-results:/process-uc1/results medgift/process-uc1-patch-extraction  bin/cnn --config-file etc/config.ini extract --patients $patients
docker run -it --rm -v $target_mnt_dir/camelyon17:/process-uc1/data/camelyon17 -v  $target_mnt_dir/uc1-results:/process-uc1/results medgift/process-uc1-patch-extraction  /bin/bash
#-------------------------

function cleanup {
  echo "Unmounting $target_mnt_dir..."
  sudo umount $target_mnt_dir
}
trap cleanup EXIT
trap cleanup ERROR

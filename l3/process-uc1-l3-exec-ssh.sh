#!/bin/bash

#NOTES
#******************************************************************************
# SSHFS VERSION
#
# * This script does the following:
#  - Install and configure sshfs client
#  - Mount snetdn target mount dir (/mnt/snedtn) via sshfs
#  - Build & Launch docker container for UC1-L3 (interpretation)
#
#
# * Before executing this script you have to make sure that the private key (for sshfs)
#   is placed on the machine that executes this script
#
# * Script should be called from current directory
#   - ./process-uc1-execution-script-sshfs.sh
#******************************************************************************

set -euo pipefail

ssh_server_host=sne-dtn-03.vlan7.uvalight.net
ssh_server_port_nbr=30909
target_mnt_dir="${HOME}/snedtn"
camelyon17_data_dir="${target_mnt_dir}/camelyon17/working_subset"
intermediate_results_data_dir="${target_mnt_dir}/L3/data/IntermediateResults"
output_results_dir="${target_mnt_dir}/L3/results"


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

#Add 'user_allow_other' to fuse.conf. This is needed so a fuse dir can be specified as docker host mount
sudo grep -qxF "user_allow_other" /etc/fuse.conf || echo "user_allow_other" | sudo tee -a /etc/fuse.conf

#Add key to known hosts
ssh-keyscan -p $ssh_server_port_nbr -H $ssh_server_host >> ~/.ssh/known_hosts

#Check if snetdn already mounted
if grep -qs "${target_mnt_dir} " /proc/mounts; then
    echo "Snetdn already mounted."
else
    #Mount snetdn via sshfs to target mount dir
    sshfs -o allow_other root@$ssh_server_host:/mnt $target_mnt_dir -o IdentityFile=~/.ssh/id_rsa_process_uc1 -p $ssh_server_port_nbr
    echo "Mounting snetdn."
    
fi


#Build Docker image
#Pass random number for REDO_CLONE arg. This triggers a new clone of the git repo
#where (REDO_CLONE previous)!= (REDO_CLONE_current)
docker build --build-arg="REDO_CLONE=${RANDOM}" -t medgift/process-uc1-interpretability -f ./docker/Dockerfile ./docker


#--LAUNCH DOCKER CONTAINER
docker run \
-it \
--gpus all \
--rm \
-v ${intermediate_results_data_dir}:/IntermediateResults \
-v ${camelyon17_data_dir}:/CAMELYON17 \
-v ${output_results_dir}:/code/PROCESS_L3/results \
medgift/process-uc1-interpretability \
python DHeatmap.py
#-------------------------


function cleanup {
  echo "Unmounting $target_mnt_dir..."
  sudo umount $target_mnt_dir
}
trap cleanup EXIT
trap cleanup ERR

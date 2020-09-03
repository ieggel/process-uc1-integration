#!/bin/bash

#NOTES
#******************************************************************************
# NAS VERSION
#
# * This script does the following:
#  - Install and configure sshfs client
#  - Mount snetdn target mount dir (/mnt/snedtn) via sshfs
#  - Build & Launch docker container for UC1-L2 (training)
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
target_mnt_dir=/mnt/snetdn

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

#Mount snetdn via sshfs to target mount dir
ssh-keyscan -p $ssh_server_port_nbr -H $ssh_server_host >> ~/.ssh/known_hosts
sshfs -o allow_other root@$ssh_server_host:/mnt $target_mnt_dir -o IdentityFile=~/.ssh/id_rsa_process_uc1 -p $ssh_server_port_nbr

experiment_type="exp-$(date +'%Y-%m-%d_%H_%M_%S')"

#Build Docker image
#Pass random number for REDO_CLONE arg. This triggers a new clone of the git repo
#where (REDO_CLONE previous)!= (REDO_CLONE_current)
#docker build --build-arg="REDO_CLONE=${RANDOM}" -t medgift/process-uc1-training ./docker
docker build --build-arg="REDO_CLONE=${RANDOM}" -t medgift/process-uc1-training -f ./docker/Dockerfile ./docker

#Define options for Horovod. Those will be passed as an argument to the docker container
#When using multiple worker nodes, make sure horovod is running on all of those
#E.g. docker run -it --gpus all --network=host -v /mnt/share/ssh:/root/.ssh horovod:latest \
#    bash -c "/usr/sbin/sshd -p 12345; sleep infinity
hvd_opts="-np 2 -H localhost:2 --verbose"

#--LAUNCH DOCKER CONTAINER
docker run \
--privileged \
-it \
--network=host \
--gpus all \
--rm \
-v /mnt/snetdn/L2:/results \
-v /mnt/snetdn/L2/results:/code/PROCESS_L2/results \
medgift/process-uc1-training \
/bin/bash hvd_train.sh $experiment_type "$hvd_opts"
#-------------------------








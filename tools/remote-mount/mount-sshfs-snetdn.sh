#!/bin/bash

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

#Add 'user_allow_other' to fuse.conf. This is needed so a fuse dir can be specified as docker host mount
sudo grep -qxF "user_allow_other" /etc/fuse.conf || echo "user_allow_other" | sudo tee -a /etc/fuse.conf

#Mount snetdn via sshfs to target mount dir
sshfs -o allow_other root@$ssh_server_host:/mnt $target_mnt_dir -o IdentityFile=~/.ssh/id_rsa_process_uc1 -p $ssh_server_port_nbr

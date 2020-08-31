#!/bin/bash

#NOTES
#******************************************************************************
# NAS VERSION
#
# * This script does the following:
#  - Build & Launch docker container for UC1-L2 (training)
##
#
# * Script should be called from current directory
#   - ./process-uc1-l2-exec-nas.sh
#******************************************************************************

set -euo pipefail

experiment_type="exp-$(date +'%Y-%m-%d_%H_%M_%S')"

#Build Docker image
#Pass random number for REDO_CLONE arg. This triggers a new clone of the git repo
#where (REDO_CLONE previous)!= (REDO_CLONE_current)
#docker build --build-arg="REDO_CLONE=${RANDOM}" -t medgift/process-uc1-training ./docker
docker build --build-arg="REDO_CLONE=${RANDOM}" -t medgift/process-uc1-training -f ./docker/Dockerfile.gpu ./docker

#Define GPU options for Horovod. Those will be passed as an argument to the docker container
#When using multiple worker nodes, make sure horovod is running on all of those
#E.g. dockerr run -it --gpus all --network=host -v /mnt/share/ssh:/root/.ssh horovod:latest \
#    bash -c "/usr/sbin/sshd -p 12345; sleep infinity
#hvd_opts="-np 7 -H localhost:4,lxhultrafast.hevs.ch:2,lxhevenfaster.hevs.ch:1 -p12345 --start-timeout 300 --verbose"
hvd_opts="-np 4 -H localhost:4"

#--LAUNCH DOCKER CONTAINER
docker run \
--privileged \
-it \
--network=host \
--gpus all \
--rm \
-v /mnt/nas2/results/00_TEST-IVAN/horovod-ssh-keys/.ssh:/root/.ssh \
-v /mnt/nas2/results/00_TEST-IVAN:/results \
-v /mnt/nas2/results/00_TEST-IVAN/results:/code/PROCESS_L2/results \
medgift/process-uc1-training \
/bin/bash hvd_train.sh $experiment_type "$hvd_opts"
#-------------------------


#!/bin/bash

#NOTES
#******************************************************************************
# SSHFS VERSION
#
# * This script does the following:
#  - Install and configure sshfs client
#  - Mount snetdn target mount dir (/mnt/snedtn) via sshfs
#  - Launch docker container for UC1 (patch extraction)
#  - Unmount mounted snetdn dir (in order to write cash to remote resource)
#
#
# * Before executing this script you have to make sure that the private key
#   is placed on the machne that executes this script
#
# * Script should be called from current directory
#   - ./process-uc1-execution-script-sshfs.sh
#******************************************************************************

set -euo pipefail

experiment_type="exp-$(date +'%Y-%m-%d_%H_%M_%S')"


#Build Docker image
#Pass random number for REDO_CLONE arg. This triggers a new clone of the git repo
#where (REDO_CLONE previous)!= (REDO_CLONE_current)
docker build --build-arg="REDO_CLONE=${RANDOM}" -t medgift/process-uc1-training ./docker

#--LAUNCH DOCKER CONTAINER
docker run \
--gpus all \
--rm \
-v /mnt/nas2/results/00_TEST-IVAN:/results \
-v /mnt/nas2/results/00_TEST-IVAN/results:/code/PROCESS_L2/results \
medgift/process-uc1-training \
$experiment_type
#-------------------------


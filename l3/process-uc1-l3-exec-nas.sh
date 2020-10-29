#!/bin/bash

#NOTES
#******************************************************************************
# NAS VERSION
#
# * This script does the following:
#  - Build & Launch docker container for UC1-L3 (interpretability)
##
#
# * Script should be called from current directory
#   - ./process-uc1-l3-exec-nas.sh
#******************************************************************************

set -euo pipefail


#Build Docker image
#Pass random number for REDO_CLONE arg. This triggers a new clone of the git repo
#where (REDO_CLONE previous)!= (REDO_CLONE_current)
docker build --build-arg="REDO_CLONE=${RANDOM}" -t medgift/process-uc1-interpretability -f ./docker/Dockerfile ./docker


#--LAUNCH DOCKER CONTAINER
docker run \
-it \
--gpus all \
--rm \
-v /mnt/nas2/results/IntermediateResults:/IntermediateResults \
-v /mnt/nas4/datasets/ToReadme/CAMELYON17:/CAMELYON17 \
-v /mnt/nas2/results/Results/PROCESS_L3:/code/PROCESS_L3/results \
medgift/process-uc1-interpretability \
python DHeatmap.py
#-------------------------


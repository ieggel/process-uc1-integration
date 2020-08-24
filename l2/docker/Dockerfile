# This image includes Ubuntu 18.04, CUDA 10.0 devel, tensorflow 1.14
# Use sha256 checksum in order to make sure the exact same image is used each time. In case the tag links to another image in the future, it will still use the original image specified by the checksum.
FROM horovod/horovod:0.18.1-tf1.14.0-torch1.2.0-mxnet1.5.0-py2.7@sha256:b31517bd08a9f9cd67b20d82f35a7767cfcb20ff91c2d7c5e6b44d22e7f734bb



# Env variables used during build only. Not available in running containers using this image.
# Prefixes: C=Container, H=Host. This should clarify if file/dir that is referenced in variable referes to host or container.
#---------------------------
#ARG C_PROJECT_DIR=/process-uc1-l2
ARG C_BASE_CODE_DIR=/code
ARG C_UC1_L2_CODE_DIR=${C_BASE_CODE_DIR}/PROCESS_L2
ARG CODE_GITHUB_URL=https://github.com/medgift/PROCESS_L2.git
ARG H_PIP_REQUIREMENTS=./requirements.txt
ARG H_CONFIG_FILE=./config.cfg
ARG H_DATA_CONFIG_FILE=./data-config.cfg



# Install libs/applications
#---------------------------
RUN apt update && apt install -y \
	openslide-tools \
    libcurl4-openssl-dev \
	libssl-dev \
	libsm6 \
	libxext6



# Create code dir
#---------------------------
RUN mkdir -p "$C_BASE_CODE_DIR"




# Override requirements.txt with adapted one from host.
#---------------------------
COPY "$H_PIP_REQUIREMENTS" /requirements.txt


# Install python libs specified in requirements.txt
#---------------------------
RUN pip install -r /requirements.txt --no-cache-dir


# Clone GitHub repo. 
# Make sure this step is reexecuted each time a new REDO_CLONE value is provided as build argument.
# This is useful for having the code in the container up to date
#---------------------------
ARG CODE_GIT_BRANCH=origin/horovod
ARG REDO_CLONE=no
WORKDIR "$C_BASE_CODE_DIR"
RUN git clone "$CODE_GITHUB_URL"
WORKDIR "$C_UC1_L2_CODE_DIR"

# Checkout specific branch
RUN git checkout "$CODE_GIT_BRANCH"


# Override config files from from host to container
#---------------------------
WORKDIR "$C_UC1_L2_CODE_DIR"
COPY "$H_CONFIG_FILE" lib/config.ini 
COPY "$H_DATA_CONFIG_FILE" data/data.cfg


# Run process-uc1 patch extraction with default: process all patients. This CMD  can be overriden at runtime.
#---------------------------
CMD /bin/bash hvd_train.sh my-exp

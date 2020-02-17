# This image includes Ubuntu 18.04, CUDA 10.0 devel, tensorflow 1.14
# Use sha256 checksum in order to make sure the exact same image is used each time. In case the tag links to another image in the future, it will still use the original image specified by the checksum.
FROM horovod/horovod:0.18.1-tf1.14.0-torch1.2.0-mxnet1.5.0-py2.7@sha256:b31517bd08a9f9cd67b20d82f35a7767cfcb20ff91c2d7c5e6b44d22e7f734bb


# Env variables used during build only. Not available in running containers using this image.
# Prefixes: C=Container, H=Host. This should clarify if file/dir that is referenced in variable referes to host or container.
#---------------------------
ARG C_PROJECT_DIR=/process-uc1
ARG C_BASE_CODE_DIR=${C_PROJECT_DIR}/code
ARG C_UC1_CODE_DIR=${C_BASE_CODE_DIR}/PROCESS_UC1
ARG CODE_GITHUB_URL=https://github.com/medgift/PROCESS_UC1.git
ARG H_PIP_REQUIREMENTS=./requirements-adapted.txt
ARG H_CONFIG_INI=./config-adapted.ini




# Create symbolic link for python2 pointing to python2.7, because process uc1 scripts makes use of /usr/bin/python2
RUN ln -s /usr/bin/python2.7 /usr/bin/python2



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


# Clone GitHub repo
#---------------------------
WORKDIR "$C_BASE_CODE_DIR"
RUN git clone "$CODE_GITHUB_URL"



# Override requirements.txt with adapted one from host.
#---------------------------
WORKDIR "$C_UC1_CODE_DIR"
COPY "$H_PIP_REQUIREMENTS" requirements.txt



# Install python libs specified in requirements.txt
#---------------------------
RUN pip install -r requirements.txt --no-cache-dir



# Override config file from from host to container to path C_FULL_CODE_DIR/config.ini.
#---------------------------
WORKDIR "$C_UC1_CODE_DIR"
COPY "$H_CONFIG_INI" /etc/config.ini 

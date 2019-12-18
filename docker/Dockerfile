FROM nvidia/cuda:10.2-devel-ubuntu18.04

ENV HOME /root
#NCCL v2.5.6, for CUDA 10.2, Nov 19,2019
ENV NCCL_REPO_DEB nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb

RUN apt update && apt install -y \
	openslide-tools \
	python \
	python-pip \
	libcurl4-openssl-dev \
	libssl-dev \
	cmake \
	libsm6 \
	libxext6 \
	libxrender-dev \
	libglib2.0-0 \
	wget

#wget

WORKDIR $HOME
#Copy nccl repo to home
#COPY ./"$NCCL_REPO_DEB" .
#Install repo
#RUN dpkg -i ./"$NCCL_REPO_DEB"
#RUN apt update
#RUN apt install -y libnccl2=2.5.6-1+cuda10.2 libnccl-dev=2.5.6-1+cuda10.2
#RUN rm ./"$NCCL_REPO_DEB"

RUN \
	wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz && \
	tar -xzf openmpi-4.0.0.tar.gz && \
	cd openmpi-4.0.0 && \
	./configure --prefix=/usr/local --with-cuda && \
	make all install && \
    ldconfig
	

#COPY CODE to /process-uc1-code
#WORKDIR /process-uc1-code
#RUN pip install -r requirements.txt --no-cache-dir

#openmpi-bin
#libopenmpi-dev


#Cuda devel image needed because we need header files for OpenMPI compilation

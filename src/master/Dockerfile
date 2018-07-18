# Pull base image.
FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    apt-utils \
    ca-certificates  \
    autoconf \
    build-essential \
    cmake \
    cython \
    git \
    libltdl-dev \
    libncurses5-dev \
    libpcre3 \
    libpcre3-dev \
    libreadline6-dev \
    locales \
    pep8 \
    software-properties-common \
    vera++ \
    wget

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN if [ "$NEST_PYTHON_VERSION" = "3" ] \
    ; then apt-get install -y \
        python3 \
        python3-h5py \
        python3-nose \
        python3-numpy \
        python3-pandas \
        python3-pip \
        python3-sphinx \
        python3-wheel && \
        pip3 install --upgrade pip jupyter \
    ; else apt-get install -y \
        python-h5py \
        python-nose \
        python-numpy \
        python-pandas \
        python-pip \
        python-sphinx \
        python-wheel && \
        pip install --upgrade pip jupyter \
    ; fi

WORKDIR /tmp/
COPY ./libneurosim .
RUN if [ "$NEST_WITH_GSL" = "On" ] \
    ; then apt-get install -y \
        libgsl-dev \
    ; fi && \
    if [ "$NEST_WITH_MPI" = "On" ] \
    ; then apt-get install -y \
        libopenmpi-dev \
        openmpi-bin \
    ; fi && \
    if [ "$NEST_WITH_MUSIC" = "On" ] \
    ; then apt-get install -y \
        libmusic-dev \
        libmusic1v5 \
        music-bin \
    ; fi && \
    if [ "$NEST_WITH_LIBNEUROSIM" = "On" ] \
    ; then bash ./libneurosim/install.sh \
    ; fi

RUN apt-get autoremove -y && rm -rf /tmp/*

# add user 'nest'
RUN adduser --disabled-login --gecos 'NEST' --home /home/nest nest && \
    adduser nest sudo && \
    mkdir /home/nest/data && \
    chown -R nest:nest /home/nest && \
    chown -R nest:nest /home/nest/data

EXPOSE 8080
WORKDIR /home/nest

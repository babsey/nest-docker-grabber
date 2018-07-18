# Pull base image.
FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    apt-utils \
    ca-certificates  \
    pep8 \
    python3 \
    python3-h5py \
    python3-nose \
    python3-numpy \
    python3-pandas \
    python3-pip \
    python3-sphinx \
    python3-wheel \
    software-properties-common && \
    apt-get autoremove -y && \
    pip3 install --upgrade pip setuptools jupyter

# install nest
RUN add-apt-repository "deb http://ppa.launchpad.net/nest-simulator/nest-nightly/ubuntu xenial main" && \
    apt-get update && \
    apt-get install nest -y --allow-unauthenticated && \
    locale-gen en_US.UTF-8

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# add user 'nest'
RUN adduser --disabled-login --gecos 'NEST' --home /home/nest nest && \
    adduser nest sudo && \
    mkdir /home/nest/data && \
    chown -R nest:nest /home/nest

COPY ./entrypoint-py3.sh /home/nest/entrypoint.sh
RUN chown nest:nest /home/nest/entrypoint.sh && \
    chmod +x /home/nest/entrypoint.sh

USER nest
WORKDIR /home/nest/data

EXPOSE 8080
ENTRYPOINT ["/home/nest/entrypoint.sh"]

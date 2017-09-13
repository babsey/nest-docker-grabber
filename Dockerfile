# Pull base image.
FROM ubuntu:16.04

ARG WITH_MPI
ARG WITH_GSL
ARG WITH_MUSIC
ARG WITH_LIBNEUROSIM

RUN apt-get update
# RUN apt-get upgrade

# install basics
RUN apt-get install -y software-properties-common \
  git \
  wget \
  gcc \
  python \
  python-dev \
  clang-format \
  autoconf

RUN apt-get install -y build-essential \
  cmake \
  libltdl7-dev \
  libreadline6-dev \
  libncurses5-dev \
  libgsl0-dev \
  python-all-dev \
  python-numpy \
  python-scipy \
  python-matplotlib \
  ipython

RUN apt-get autoremove

# Install pip and Cython.
WORKDIR /tmp
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install setuptools
RUN pip install cython==0.23.4

# Install OpenMPI.
# TODO: conditional install
RUN apt-get install -y openmpi-bin libopenmpi-dev

# Install nose framework for the Python testsuite.
RUN apt-get install -y python-nose

#Install VERA++ and pep8 for static code analysis.
RUN apt-get install -y vera++ pep8

# Required for building cppcheck-1.69.
RUN apt-get install -y libpcre3 libpcre3-dev

# Install jq to process JSON output from GitHub API.
RUN apt-get install -y jq

# Install current MUSIC version  (/usr/local/lib)
# TODO: conditional install
WORKDIR /tmp
RUN apt-get install -y python-mpi4py
RUN git clone https://github.com/INCF/MUSIC.git music
WORKDIR /tmp/music
RUN chmod +x autogen.sh
RUN ./autogen.sh 
RUN chmod +x configure
RUN ./configure
RUN make
RUN make install

# Install libneurosim (/usr/local/lib)
# TODO: conditional install
WORKDIR /tmp
RUN git clone https://github.com/INCF/libneurosim.git libneurosim
WORKDIR /tmp/libneurosim
RUN chmod +x autogen.sh
RUN ./autogen.sh 
RUN chmod +x configure
RUN ./configure
RUN make
RUN make install

# add user 'nest'
RUN adduser --disabled-login --gecos 'NEST' nest

# Install NEST 2.12.0
WORKDIR /home/nest
RUN su nest -c 'wget https://github.com/nest/nest-simulator/releases/download/v2.12.0/nest-2.12.0.tar.gz'
RUN su nest -c 'tar -xvzf nest-2.12.0.tar.gz'
RUN su nest -c 'mkdir /home/nest/nest-build'
RUN su nest -c 'mkdir /home/nest/nest-install'
WORKDIR /home/nest/nest-build
RUN su nest -c 'cmake -DCMAKE_INSTALL_PREFIX:PATH=/home/nest/nest-install \
    -Dwith-mpi:BOOL=$WITH_MPI \
    -Dwith-gsl:BOOL=$WITH_GSL /usr/local/lib \
    -Dwith-libneurosim:BOOL=$WITH_LIBNEUROSIM /usr/local/lib \
    -Dwith-music=$WITH_MUSIC /usr/local/lib ../nest-2.12.0'
RUN su nest -c 'make'
RUN su nest -c 'make install'
# RUN su nest -c 'make installcheck'

WORKDIR /home/nest/
RUN mkdir data
RUN chown -R nest:nest data/

# Load NEST with every start.
RUN su nest -c "echo '. /home/nest/nest-install/bin/nest_vars.sh' >> /home/nest/.bashrc"

RUN apt-get install nano -y
RUN apt-get autoremove

COPY ./script/entrypoint.sh /home/nest/
RUN chown nest:nest /home/nest/entrypoint.sh
RUN chmod +x /home/nest/entrypoint.sh
ENTRYPOINT ["/home/nest/entrypoint.sh"]
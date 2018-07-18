FROM nest/docker-nest-master:latest

ARG PYTHON_VERSION
ARG WITH_MPI
ARG WITH_GSL
ARG WITH_LIBNEUROSIM
ARG WITH_MUSIC

COPY . /tmp/nest-simulator

WORKDIR /tmp/nest-build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/nest \
    -Dwith-python=$PYTHON_VERSION \
    -Dwith-mpi:BOOL=$WITH_MPI \
    -Dwith-gsl:BOOL=$WITH_GSL /usr/local/lib \
    -Dwith-libneurosim:BOOL=$WITH_LIBNEUROSIM /usr/local/lib \
    -Dwith-music:BOOL=$WITH_MUSIC /usr/local/lib \
    /tmp/nest-simulator && \
    make && make install && \
    echo '. /opt/nest/bin/nest_vars.sh' >> /home/nest/.bashrc && \
    rm -rf /tmp/*

COPY ./entrypoint.sh /home/nest/entrypoint.sh
RUN chown nest:nest /home/nest/entrypoint.sh && \
    chmod +x /home/nest/entrypoint.sh

WORKDIR /home/nest/data
ENTRYPOINT ["/home/nest/entrypoint.sh"]

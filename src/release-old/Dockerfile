FROM nest/docker-nest-master:latest

ARG NEST_VERSION
ARG PYTHON_VERSION

WORKDIR /tmp
ARG DOWNLOAD_URL=https://github.com/nest/nest-simulator/releases/download
RUN wget $DOWNLOAD_URL/v$NEST_VERSION/nest-$NEST_VERSION.tar.gz && \
    tar -xvzf nest-$NEST_VERSION.tar.gz && \
    mkdir /tmp/nest-build

WORKDIR /tmp/nest-build
RUN /tmp/nest-$NEST_VERSION/configure \
    # --without-python \
    --prefix=/opt/nest && \
    make && make install && \
    echo '. /opt/nest/bin/nest_vars.sh' >> /home/nest/.bashrc && \
    rm -rf /tmp/*

COPY ./entrypoint-py$PYTHON_VERSION.sh /home/nest/entrypoint.sh
RUN chown nest:nest /home/nest/entrypoint.sh && \
    chmod +x /home/nest/entrypoint.sh

USER nest
WORKDIR /home/nest/data
ENTRYPOINT ["/home/nest/entrypoint.sh"]

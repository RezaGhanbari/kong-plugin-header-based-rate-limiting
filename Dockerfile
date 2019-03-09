FROM kong:0.14.1-centos

ENV SET_CONTAINER_TIMEZONE_ON_START=false
ENV CONTAINER_TIMEZONE=CET

RUN yum update -y && \
    yum install -y \
        gcc \
        git \
        postgresql \
        rsyslog \
        rsyslog-elasticsearch \
        rsyslog-imptcp \
        rsyslog-imrelp \
        rsyslog-mmjsonparse \
        rsyslog-omrelp \
        rsyslog-omstdout \
        unzip \
        wget \
        zip && \
    yum clean all

RUN cd /etc/yum.repos.d/ && \
    wget http://rpms.adiscon.com/v8-stable/rsyslog.repo

RUN rm /etc/rsyslog.d/listen.conf
COPY ./docker/rsyslog.conf /etc/rsyslog.conf

COPY ./docker/wait-for-it.sh /wait-for-it.sh
COPY ./docker/migrate.sh /migrate.sh

RUN chmod +x /wait-for-it.sh && \
    chmod +x /migrate.sh

ENV PATH=$PATH:/usr/local/bin:/usr/local/openresty/bin:/opt/stap/bin:/usr/local/stapxx:/usr/local/openresty/nginx/sbin

# prevent "Warning: The directory '/root/.cache/luarocks'..." errors
ENV USER=root

EXPOSE 8000 8001 8443 8444

RUN git clone https://github.com/Kong/kong && \
    cd kong && \
    git checkout 0.14.1 && \
    make dev

RUN luarocks install classic && \
    luarocks install kong-lib-logger --deps-mode=none && \
    luarocks install kong-client 1.1.0

#CMD ["/kong/bin/kong", "start", "--v"]
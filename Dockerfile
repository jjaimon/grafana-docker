FROM debian:jessie

ENV RELEASE_VERSION 4.2.0

ARG GRAFANA_HOME
ENV GRAFANA_HOME ${GRAFANA_HOME:-/var/share/grafana}

ARG user=grafana
ARG group=grafana
ARG uid=1001
ARG gid=1001

# grafana version being bundled in this docker image
ARG GRAFANA_VERSION
ENV GRAFANA_VERSION ${GRAFANA_VERSION:-4.2.0}

ARG DOWNLOAD_URL=https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN groupadd -g ${gid} ${group} \
    && useradd -d "$GRAFANA_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN apt-get update && \
    apt-get -y --no-install-recommends install libfontconfig curl ca-certificates && \
    apt-get install -y adduser libfontconfig && \
    apt-get clean && \
    curl ${DOWNLOAD_URL} > /tmp/grafana.deb && \
    dpkg -i /tmp/grafana.deb && \
    rm /tmp/grafana.deb && \
    curl -L https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 > /usr/sbin/gosu && \
    chmod +x /usr/sbin/gosu && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

COPY ./run.sh /run.sh

ENTRYPOINT ["/run.sh"]

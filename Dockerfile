# Create docker image used for provisioning Apache Nifi into Alpine-based linux container

FROM alpine:3.12.0
LABEL io.qabsu.description="Apache NiFi container provisioned on Alpine Linux"
LABEL io.qabsu.maintainer="qabsu.io"
LABEL io.qabsu.organisation="qabsu pty limited"
LABEL io.qabsu.contributor="grant priestley"
LABEL io.qabsu.email="grant.priestley@qabsu.io"
LABEL io.qabsu.url="https://www.qabsu.io/"

# set container arguments
ARG NIFI_VERSION=1.12.1
## set path for binaries from mirror, sha256 from backup site
ARG NIFI_BINARY=https://apache.mirror.digitalpacific.com.au/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz
ARG NIFI_BINARY_SHA=https://downloads.apache.org/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz.sha256
ARG NIFI_TOOLKIT_BINARY=https://apache.mirror.digitalpacific.com.au/nifi/$NIFI_VERSION/nifi-toolkit-$NIFI_VERSION-bin.tar.gz
ARG NIFI_TOOLKIT_BINARY_SHA=https://downloads.apache.org/nifi/$NIFI_VERSION/nifi-toolkit-$NIFI_VERSION-bin.tar.gz.sha256
ARG UID=1000
ARG GID=1000

# set container environment variables
ENV NIFI_BASE_DIR=/opt/nifi
ENV NIFI_HOME ${NIFI_BASE_DIR}/nifi-current
ENV NIFI_TOOLKIT_HOME ${NIFI_BASE_DIR}/nifi-toolkit-current
ENV NIFI_PID_DIR=${NIFI_HOME}/run
ENV NIFI_LOG_DIR=${NIFI_HOME}/logs

# execute operating system tasks
## copy the scripts an make them executable
COPY scripts/* ${NIFI_BASE_DIR}/scripts/
RUN chmod -R +x ${NIFI_BASE_DIR}/scripts/*.sh
## create necessary group & user, as well as requred directories with correct ownership
RUN addgroup -g ${GID} nifi \
    && adduser --shell /bin/bash -S nifi -u ${UID} -G nifi \
    && mkdir -p ${NIFI_BASE_DIR} \
    && chown -R nifi:nifi ${NIFI_BASE_DIR}
## install apline linux operating system dependencies for Apache NiFi
RUN apk --update add bash git tar curl ca-certificates sudo openssh rsync openjdk8 \
    && rm -rf /var/cache/apk/*

# set container user
USER nifi

# install binaries
## fetch, validate and install Apache NiFi toolkit
RUN curl -fSL ${NIFI_TOOLKIT_BINARY} -o ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.tar.gz \
    && echo "$(curl ${NIFI_TOOLKIT_BINARY_SHA}) *${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.tar.gz" | sha256sum -c - \
    && tar xzf ${NIFI_BASE_DIR}/nifi-toolkit-$NIFI_VERSION-bin.tar.gz -C ${NIFI_BASE_DIR} \
    && rm ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.tar.gz \
    && mv ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION} ${NIFI_TOOLKIT_HOME} \
    && ln -s ${NIFI_TOOLKIT_HOME} ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}
## fetch, validate and install Apache NiFi
RUN curl -fSL ${NIFI_BINARY} -o ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.tar.gz \
    && echo "$(curl ${NIFI_BINARY_SHA}) *${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.tar.gz" | sha256sum -c - \
    && tar xzf ${NIFI_BASE_DIR}/nifi-$NIFI_VERSION-bin.tar.gz -C ${NIFI_BASE_DIR} \
    && rm ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.tar.gz \
    && mv ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION} ${NIFI_HOME} \
    && mkdir -p ${NIFI_HOME}/conf \
    && mkdir -p ${NIFI_HOME}/database-repository \
    && mkdir -p ${NIFI_HOME}/flowfile-repository \
    && mkdir -p ${NIFI_HOME}/content-repository \
    && mkdir -p ${NIFI_HOME}/provenance-repository \
    && mkdir -p ${NIFI_HOME}/state \
    && mkdir -p ${NIFI_LOG_DIR} \
    && ln -s ${NIFI_HOME} ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}

# set the container volumes
VOLUME ${NIFI_LOG_DIR} \
       ${NIFI_HOME}/conf \
       ${NIFI_HOME}/database-repository \
       ${NIFI_HOME}/flowfile-repository \
       ${NIFI_HOME}/content-repository \
       ${NIFI_HOME}/provenance-repository \
       ${NIFI_HOME}/state

# configure all environment variables via Dockerfile, instead of nifi-env.sh
RUN echo "#!/bin/sh\n" > $NIFI_HOME/bin/nifi-env.sh

# configure the exposed ports of the container
EXPOSE 8080 8443 10000 8000

# set working directory
WORKDIR ${NIFI_HOME}

# apply configuration and start Apache NiFi
ENTRYPOINT ["../scripts/start.sh"]
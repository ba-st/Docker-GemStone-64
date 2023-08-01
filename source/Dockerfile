# Runs on a multi-stage build: https://docs.docker.com/develop/develop-images/multistage-build/
# - Prepare a base image with all dependencies installed
# - Download and prepare environment
# - Copy prepared environment onto the final image

FROM debian:12-slim AS base

ENV SHELL=/bin/bash
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

ENV GS_USER=gemstone
ENV GS_UID=1001
ENV GS_GID=100

RUN  apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
     ca-certificates \
     gosu \
     locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && echo "en_US.ISO-8859-15 ISO-8859-15" >> /etc/locale.gen \
  && locale-gen \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd --uid ${GS_UID} --gid ${GS_GID} --no-create-home --no-user-group ${GS_USER} \
  ;

## Donwload GemStone 64 bits release
FROM alpine:3.18 as download

ARG GS_VERSION
ENV GEMSTONE_GLOBAL_DIR=/opt/gemstone
ENV GEMSTONE=${GEMSTONE_GLOBAL_DIR}/product
ENV DOWNLOAD_LOCATION=/tmp

# Download official release
RUN wget https://downloads.gemtalksystems.com/pub/GemStone64/${GS_VERSION}/GemStone64Bit${GS_VERSION}-x86_64.Linux.zip \
  -O ${DOWNLOAD_LOCATION}/GemStone.zip

#Extract it
RUN mkdir - ${GEMSTONE_GLOBAL_DIR} \
  && unzip -qq ${DOWNLOAD_LOCATION}/GemStone.zip -d ${DOWNLOAD_LOCATION} \
  && mv ${DOWNLOAD_LOCATION}/GemStone64Bit${GS_VERSION}-x86_64.Linux ${GEMSTONE}

# Create required directories
RUN mkdir -p \
  ${GEMSTONE_GLOBAL_DIR}/conf/ \
  ${GEMSTONE_GLOBAL_DIR}/data/ \
  ${GEMSTONE_GLOBAL_DIR}/locks/ \
  ${GEMSTONE_GLOBAL_DIR}/logs/ \
  ;

# Remove non-essential files to keep the final image size small
RUN rm -rf \
  ${GEMSTONE}/bin32/ \
  ${GEMSTONE}/examples/ \
  ${GEMSTONE}/include/ \
  ${GEMSTONE}/install/ \
  ${GEMSTONE}/lib32/ \
  ${GEMSTONE}/rowan/ \
  ${GEMSTONE}/seaside/ \
  ${GEMSTONE}/upgrade/ \
  ${GEMSTONE}/bin/vsd* \
  ${GEMSTONE}/lib/tcl* \
  ${GEMSTONE}/lib/tk* \
  ${GEMSTONE}/lib/Tix* \
  ${GEMSTONE}/lib/pkgconfig/tcl* \
  ${GEMSTONE}/lib/pkgconfig/tk* \
  ${GEMSTONE}/lib/rbc* \
  ${GEMSTONE}/doc/man1/vsd.1 \
&& mv ${GEMSTONE}/bin/extent0*.dbf ${DOWNLOAD_LOCATION} \
;

# Replace `data` location in the default system.conf
RUN sed -ri 's|\$GEMSTONE/data|\$GEMSTONE_GLOBAL_DIR/data|g' ${GEMSTONE}/data/system.conf

# Copy startup scripts
COPY start-gemstone.sh ${GEMSTONE_GLOBAL_DIR}/start-gemstone.sh
COPY entrypoint.sh ${GEMSTONE_GLOBAL_DIR}/entrypoint.sh

## Prepare server image
FROM base as docker-gs64-server
LABEL maintainer="Buenos Aires Smalltalk <github@fast.org.ar>"

ENV GEMSTONE_GLOBAL_DIR=/opt/gemstone
ENV GEMSTONE=${GEMSTONE_GLOBAL_DIR}/product
ENV GEMSTONE_EXE_CONF=${GEMSTONE_GLOBAL_DIR}/conf
ENV GEMSTONE_SYS_CONF=${GEMSTONE_GLOBAL_DIR}/conf
ENV GEMSTONE_LOG_DIR=${GEMSTONE_GLOBAL_DIR}/logs

ENV PATH=$GEMSTONE/bin:$PATH
# Used to determine what shell to use for an exec, such as by System class>>performOnServer:.
ENV SHELL=/usr/bin/bash

ENV NETLDI_SERVICE_NAME=gs64ldi
ENV NETLDI_PORT=50384
ENV STONE_SERVICE_NAME=gs64stone
ENV STONE_PORT=50385

ENV DATA_CURATOR_PASSWORD=swordfish
# By default `docker stop` will wait 10 seconds for the container to handle
# SIGTERM signals, after the grace period docker will send a SIGKILL.
# By default we wait 8 seconds to allow a clean shutdown of the Stone.
# If your installation needs a greater timeout change the docker wait time
# and this timet-out in consequence
ENV STOPSTONE_TIMEOUT_SECONDS=8

ENV GS_FORCE_CLEAN_LOG_FILE_DELETE=true
ENV GEMSTONE_NRS_ALL=#netldi:$NETLDI_SERVICE_NAME#dir:$GEMSTONE_LOG_DIR/#log:$GEMSTONE_LOG_DIR/%N_%P.log

COPY --from=download --chown=${GS_USER}:users ${GEMSTONE_GLOBAL_DIR} ${GEMSTONE_GLOBAL_DIR}
RUN ln -s ${GEMSTONE}/bin/gemsetup.sh /etc/profile.d/gemstone.sh


WORKDIR ${GEMSTONE_GLOBAL_DIR}
VOLUME ${GEMSTONE_GLOBAL_DIR}/data/
CMD ["./entrypoint.sh"]

## Prepare server base image
FROM docker-gs64-server as docker-gs64-base

COPY --from=download --chown=${GS_USER}:users /tmp/extent0.dbf ${GEMSTONE_GLOBAL_DIR}/data/extent0.dbf
CMD ["./entrypoint.sh"]

## Prepare server rowan image
FROM docker-gs64-server as docker-gs64-rowan

# Install git
RUN  apt-get update \
  && apt-get install --assume-yes --no-install-recommends git \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  ;

ENV ROWAN_PROJECTS_HOME=${GEMSTONE_GLOBAL_DIR}/projects

RUN install -d --owner=${GS_USER} --group=users ${ROWAN_PROJECTS_HOME}
COPY --chown=${GS_USER}:users load-rowan-project.sh ${GEMSTONE_GLOBAL_DIR}/load-rowan-project.sh

COPY --from=download --chown=${GS_USER}:users /tmp/extent0.rowan.dbf ${GEMSTONE_GLOBAL_DIR}/data/extent0.dbf
CMD ["./entrypoint.sh"]

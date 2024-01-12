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
     libcap2-bin \
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

# Remove non-essential files to keep the final image size small
RUN rm -rf \
  ${GEMSTONE}/bin32/ \
  ${GEMSTONE}/examples/ \
  ${GEMSTONE}/include/ \
  ${GEMSTONE}/install/ \
  ${GEMSTONE}/lib32/ \
  ${GEMSTONE}/projects/ \
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

#########################
### GS64 Server Image ###
#########################

FROM base as docker-gs64-server
ARG GS_NETLDI_SERVICE_NAME=gs64ldi
ARG GS_NETLDI_PORT=50384
ARG GS_STONE_SERVICE_NAME=gs64stone
ARG GS_STONE_PORT=50385
LABEL maintainer="Buenos Aires Smalltalk <github@fast.org.ar>"

ENV GEMSTONE_GLOBAL_DIR=/opt/gemstone
ENV GEMSTONE=${GEMSTONE_GLOBAL_DIR}/product
ENV GEMSTONE_EXE_CONF=${GEMSTONE_GLOBAL_DIR}/conf
ENV GEMSTONE_SYS_CONF=${GEMSTONE_GLOBAL_DIR}/conf
ENV GEMSTONE_LOG_DIR=${GEMSTONE_GLOBAL_DIR}/logs

ENV PATH=$GEMSTONE/bin:$PATH
# Used to determine what shell to use for an exec, such as by System class>>performOnServer:.
ENV SHELL=/usr/bin/bash

ENV NETLDI_SERVICE_NAME=${GS_NETLDI_SERVICE_NAME}
ENV NETLDI_PORT=${GS_NETLDI_PORT}
ENV STONE_SERVICE_NAME=${GS_STONE_SERVICE_NAME}
ENV STONE_PORT=${GS_STONE_PORT}

ENV GS64_DATA_CURATOR_PASSWORD=swordfish
ENV GS64_SYSTEM_USER_PASSWORD=swordfish
# By default `docker stop` will wait 10 seconds for the container to handle
# SIGTERM signals, after the grace period docker will send a SIGKILL.
# By default we wait 8 seconds to allow a clean shutdown of the Stone.
# If your installation needs a greater timeout change the docker wait time
# and this timet-out in consequence
ENV GS64_STOPSTONE_TIMEOUT_SECONDS=8

ENV GS_FORCE_CLEAN_LOG_FILE_DELETE=true
ENV GEMSTONE_NRS_ALL=#netldi:$NETLDI_SERVICE_NAME#dir:$GEMSTONE_LOG_DIR/#log:$GEMSTONE_LOG_DIR/%N_%P.log

COPY --from=download --chown=${GS_USER}:users ${GEMSTONE_GLOBAL_DIR} ${GEMSTONE_GLOBAL_DIR}
COPY --chown=${GS_USER}:users stone-init.sh ${GEMSTONE_GLOBAL_DIR}/stone-init.sh
RUN echo "${NETLDI_SERVICE_NAME} ${NETLDI_PORT}/tcp # GemStone - Netldi" >> /etc/services
RUN echo "${STONE_SERVICE_NAME} ${STONE_PORT}/tcp # GemStone - Stone" >> /etc/services
RUN ln -s ${GEMSTONE}/bin/gemsetup.sh /etc/profile.d/gemstone.sh
RUN setcap cap_sys_resource=pe $GEMSTONE/sys/stoned
RUN setcap cap_sys_resource=pe $GEMSTONE/sys/pgsvrmain

USER ${GS_USER}

RUN mkdir -p \
  ${GEMSTONE_GLOBAL_DIR}/conf/ \
  ${GEMSTONE_GLOBAL_DIR}/data/ \
  ${GEMSTONE_GLOBAL_DIR}/locks/ \
  ${GEMSTONE_GLOBAL_DIR}/logs/ \
  ;
WORKDIR ${GEMSTONE_GLOBAL_DIR}
VOLUME ${GEMSTONE_GLOBAL_DIR}/data/
CMD ["./stone-init.sh"]

############################
### GS Server Base Image ###
############################

FROM docker-gs64-server as docker-gs64-base

COPY --from=download \
  --chown=${GS_USER}:users \
  /tmp/extent0.dbf ${GEMSTONE_GLOBAL_DIR}/data/extent0.dbf
RUN chmod ug+w ${GEMSTONE_GLOBAL_DIR}/data/extent0.dbf  
CMD ["./stone-init.sh"]

#############################
### GS Server Rowan Image ###
#############################

FROM docker-gs64-server as docker-gs64-rowan

USER root
# Install git
RUN  apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
    git \
    ssh-client \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  ;

ENV ROWAN_PROJECTS_HOME=${GEMSTONE_GLOBAL_DIR}/projects

RUN install -d --owner=${GS_USER} --group=users ${ROWAN_PROJECTS_HOME}
COPY --chown=${GS_USER}:users configure.sh ${GEMSTONE_GLOBAL_DIR}/configure.sh
COPY --chown=${GS_USER}:users load-rowan-project.sh ${GEMSTONE_GLOBAL_DIR}/load-rowan-project.sh
COPY --chown=${GS_USER}:users run-tests.sh ${GEMSTONE_GLOBAL_DIR}/run-tests.sh
COPY --chown=${GS_USER}:users Rowan.gs ${GEMSTONE_GLOBAL_DIR}/Rowan.gs
COPY --chown=${GS_USER}:users StdOutPrinter.gs ${GEMSTONE_GLOBAL_DIR}/StdOutPrinter.gs
COPY --chown=${GS_USER}:users StdOutTestReporter.gs ${GEMSTONE_GLOBAL_DIR}/StdOutTestReporter.gs

COPY --from=download \
  --chown=${GS_USER}:users \
  /tmp/extent0.rowan.dbf ${GEMSTONE_GLOBAL_DIR}/data/extent0.dbf

RUN chmod ug+w ${GEMSTONE_GLOBAL_DIR}/data/extent0.dbf

USER ${GS_USER}
CMD ["./stone-init.sh"]

##############################
### Reduced download image ###
##############################

FROM download as minimal-download

# Remove non-essential files to keep the final image size small
RUN rm -rf \
  ${GEMSTONE}/bin/copydbf \
  ${GEMSTONE}/bin/gemsetup.csh \
  ${GEMSTONE}/bin/gemstone_data.conf \
  ${GEMSTONE}/bin/pageaudit \
  ${GEMSTONE}/bin/printlogs \
  ${GEMSTONE}/bin/removedbf \
  ${GEMSTONE}/bin/searchlogs \
  ${GEMSTONE}/bin/secure_backup_extract \
  ${GEMSTONE}/bin/slow \
  ${GEMSTONE}/bin/starthostagent \
  ${GEMSTONE}/bin/startlogreceiver \
  ${GEMSTONE}/bin/startlogsender \
  ${GEMSTONE}/bin/startstone \
  ${GEMSTONE}/bin/stophostagent \
  ${GEMSTONE}/bin/stoplogreceiver \
  ${GEMSTONE}/bin/stoplogsender \
  ${GEMSTONE}/bin/stopstone \
  ${GEMSTONE}/bin/superdoit_baseimage_solo \
  ${GEMSTONE}/bin/superdoit_solo \
  ${GEMSTONE}/bin/superdoit_stone \
  ${GEMSTONE}/bin/updatesecuredbf \
  ${GEMSTONE}/bin/upgradeimage \
  ${GEMSTONE}/bin/verify_backup_with_openssl \
  ${GEMSTONE}/bin/waitstone \
  ${GEMSTONE}/bin/x509 \
  ${GEMSTONE}/data \
  ${GEMSTONE}/doc/man1/copydbf* \
  ${GEMSTONE}/doc/man1/pageaudit* \
  ${GEMSTONE}/doc/man1/printlogs* \
  ${GEMSTONE}/doc/man1/removedbf* \
  ${GEMSTONE}/doc/man1/searchlogs* \
  ${GEMSTONE}/doc/man1/secure_backup_extract* \
  ${GEMSTONE}/doc/man1/starthostagent* \
  ${GEMSTONE}/doc/man1/startlogreceiver* \
  ${GEMSTONE}/doc/man1/startlogsender* \
  ${GEMSTONE}/doc/man1/startstone* \
  ${GEMSTONE}/doc/man1/stophostagent* \
  ${GEMSTONE}/doc/man1/stoplogreceiver* \
  ${GEMSTONE}/doc/man1/stoplogsender* \
  ${GEMSTONE}/doc/man1/stopstone* \
  ${GEMSTONE}/doc/man1/updatesecuredbf* \
  ${GEMSTONE}/doc/man1/waitstone* \
  ${GEMSTONE}/doc/man8/stoned* \
  ${GEMSTONE}/sys/hostagenttopaz.ini \
  ${GEMSTONE}/sys/midhostagenttopaz.ini \
  ${GEMSTONE}/sys/runpageauditgem \
  ${GEMSTONE}/sys/stoned \
  ${GEMSTONE}/sys/topazSolo.ini \
  ;

######################
### GS64 gem image ###
######################

FROM base as docker-gs64-gem
ARG GS_NETLDI_SERVICE_NAME=gs64ldi
ARG GS_NETLDI_PORT=50384
LABEL maintainer="Buenos Aires Smalltalk <github@fast.org.ar>"

ENV GEMSTONE_GLOBAL_DIR=/opt/gemstone
ENV GEMSTONE=${GEMSTONE_GLOBAL_DIR}/product
ENV GEMSTONE_EXE_CONF=${GEMSTONE_GLOBAL_DIR}/conf
ENV GEMSTONE_LOG_DIR=${GEMSTONE_GLOBAL_DIR}/logs

ENV PATH=$GEMSTONE/bin:$PATH
# Used to determine what shell to use for an exec, such as by System class>>performOnServer:.
ENV SHELL=/usr/bin/bash

ENV NETLDI_SERVICE_NAME=${GS_NETLDI_SERVICE_NAME}
ENV NETLDI_PORT=${GS_NETLDI_PORT}

COPY --from=minimal-download --chown=${GS_USER}:users ${GEMSTONE_GLOBAL_DIR} ${GEMSTONE_GLOBAL_DIR}
COPY --chown=${GS_USER}:users gem-init.sh ${GEMSTONE_GLOBAL_DIR}/gem-init.sh

USER root
RUN echo "${NETLDI_SERVICE_NAME} ${NETLDI_PORT}/tcp # GemStone - Netldi" >> /etc/services
RUN ln -s ${GEMSTONE}/bin/gemsetup.sh /etc/profile.d/gemstone.sh
RUN setcap cap_sys_resource=pe $GEMSTONE/sys/pgsvrmain

USER ${GS_USER}

RUN mkdir -p \
  ${GEMSTONE_GLOBAL_DIR}/conf/ \
  ${GEMSTONE_GLOBAL_DIR}/locks/ \
  ${GEMSTONE_GLOBAL_DIR}/logs/ \
  ;

WORKDIR ${GEMSTONE_GLOBAL_DIR}
CMD ["./gem-init.sh"]

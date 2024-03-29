#!/usr/bin/env bash
# based on https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86
# see also https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
set -eu

# Copy default system config if missing
if [ ! -f "${GEMSTONE_SYS_CONF}/system.conf" ]; then
  cp -p "${GEMSTONE}/data/system.conf" "${GEMSTONE_SYS_CONF}/system.conf"
fi

# Create (empty) stone config if missing
if [ ! -f "${GEMSTONE_EXE_CONF}/${STONE_SERVICE_NAME}.conf" ]; then
  touch "${GEMSTONE_EXE_CONF}/${STONE_SERVICE_NAME}.conf"
fi

# SIGTERM-handler
sigterm_handler() {
  echo 'Got SIGTERM, stopping GemStone/S 64 server'
  stopnetldi
  stopstone \
    -i \
    -t "${GS64_STOPSTONE_TIMEOUT_SECONDS}" \
    "$STONE_SERVICE_NAME" \
    DataCurator \
    "${GS64_DATA_CURATOR_PASSWORD}"
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process,
# which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; sigterm_handler' SIGTERM

# start GemStone services
# shellcheck disable=SC2086
startnetldi \
  -g \
  -a "${GS_USER}" \
  -n \
  -P "${NETLDI_PORT}" \
  -l "${GEMSTONE_LOG_DIR}/${NETLDI_SERVICE_NAME}.log" \
  ${NETLDI_ARGS:-} \
  "${NETLDI_SERVICE_NAME}"

# shellcheck disable=SC2086
startstone \
  -e "${GEMSTONE_EXE_CONF}" \
  -z "${GEMSTONE_SYS_CONF}" \
  -l "${GEMSTONE_LOG_DIR}/${STONE_SERVICE_NAME}.log" \
  ${STONE_ARGS:-} \
  ${STONE_SERVICE_NAME}

# list GemStone servers
gslist -cvl

# Configure GS repository

"${GEMSTONE_GLOBAL_DIR}"/configure.sh

# wait forever, (loop to handle multiple signals if needed)
while true
do
  tail -f /dev/null & wait ${!}
done

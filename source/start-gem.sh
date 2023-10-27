#!/usr/bin/env bash
# based on https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86
# see also https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
set -eu

# SIGTERM-handler
sigterm_handler() {
  echo 'Got SIGTERM, stopping GemStone/S 64 gem'
  stopnetldi
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
  -D "${GEMSTONE_LOG_DIR}" \
  ${NETLDI_ARGS:-} \
  "${NETLDI_SERVICE_NAME}"

# list GemStone services
gslist -cvl

# wait forever, (loop to handle multiple signals if needed)
while true
do
  tail -f /dev/null & wait ${!}
done

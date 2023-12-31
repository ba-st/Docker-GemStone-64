#!/usr/bin/env bash

set -eu

echo "${NETLDI_SERVICE_NAME} ${NETLDI_PORT}/tcp # GemStone - Netldi" >> /etc/services

# Ensure write permissions
NEED_WRITE_PERMISSION=(
  "${GEMSTONE_GLOBAL_DIR}/locks/"
  "${GEMSTONE_LOG_DIR}/"
)

for path in "${NEED_WRITE_PERMISSION[@]}"; do
  if ! gosu "${GS_USER}" test -w "$path"; then
    chown "${GS_UID}:${GS_GID}" "$path"
    chmod ug+w "$path"
  fi
done

# Run gemstone as GS_USER
exec gosu "${GS_USER}" "${GEMSTONE_GLOBAL_DIR}/start-gem.sh"

#!/usr/bin/env bash

set -eu

echo "${NETLDI_SERVICE_NAME} ${NETLDI_PORT}/tcp # GemStone - Netldi" >> /etc/services
echo "${STONE_SERVICE_NAME} ${STONE_PORT}/tcp # GemStone - Stone" >> /etc/services

# Copy default system config if missing
if [ ! -f "${GEMSTONE_SYS_CONF}/system.conf" ]; then
  cp -p "${GEMSTONE}/data/system.conf" "${GEMSTONE_SYS_CONF}/system.conf"
fi

# Create (empty) stone config if missing
if [ ! -f "${GEMSTONE_EXE_CONF}/${STONE_SERVICE_NAME}.conf" ]; then
  touch "${GEMSTONE_EXE_CONF}/${STONE_SERVICE_NAME}.conf"
fi

# Ensure write permissions
NEED_WRITE_PERMISSION=(
  "${GEMSTONE_SYS_CONF}/system.conf"
  "${GEMSTONE_EXE_CONF}/${STONE_SERVICE_NAME}.conf"
  "${GEMSTONE_GLOBAL_DIR}/data/"
  "${GEMSTONE_GLOBAL_DIR}/data/extent0.dbf"
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
exec gosu "${GS_USER}" "${GEMSTONE_GLOBAL_DIR}/start-gemstone.sh"

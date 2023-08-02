#!/usr/bin/env bash

set -e

if [ -z "${GS64_CI_PROJECT_NAME}" ]; then
  echo "[ERROR] Missing GS64_CI_PROJECT_NAME variable"
  exit 1
fi

readonly LOAD_SPEC="${GS64_CI_SPEC:-${GS64_CI_PROJECT_NAME}-CI}"
readonly SYSTEM_USER_PASSWORD="${GS64_CI_SYSTEM_USER_PASSWORD:-swordfish}"

echo "Loading code in GS..."
echo "  Project Name: ${GS64_CI_PROJECT_NAME}"
echo "  Load Spec: ${LOAD_SPEC}"

topaz -i -q <<EOF > "${GEMSTONE_LOG_DIR}/loading-rowan-projects.log"
set gemstone gs64stone user SystemUser pass ${SYSTEM_USER_PASSWORD}
iferror exit 1
login
doit
  |spec url |
  url := 'file://${ROWAN_PROJECTS_HOME}/${GS64_CI_PROJECT_NAME}/rowan/specs/${LOAD_SPEC}.ston'.
  spec := RwSpecification fromUrl: url.
  spec resolve load.
%
commit
logout
exit 0
EOF

echo "Loading code in GS... [OK]"

#!/usr/bin/env bash

set -e

if [ -n "$1" ]; then
  readonly LRP_PROJECT_NAME=$1
elif [ -z "${GS64_CI_PROJECT_NAME}" ]; then
  echo "[ERROR] Missing GS64_CI_PROJECT_NAME variable"
  exit 1
else
  readonly LRP_PROJECT_NAME="${GS64_CI_PROJECT_NAME}"
fi

if [ -n "$2" ]; then
  readonly LRP_LOAD_SPEC=$2
else
  readonly LRP_LOAD_SPEC="${GS64_CI_SPEC:-${LRP_PROJECT_NAME}-CI}"
fi

readonly SYSTEM_USER_PASSWORD="${GS64_CI_SYSTEM_USER_PASSWORD:-swordfish}"

echo "Loading code in GS..."
echo "  Project Name: ${LRP_PROJECT_NAME}"
echo "  Load Spec: ${LRP_LOAD_SPEC}"

topaz -i -q <<EOF > "${GEMSTONE_LOG_DIR}/loading-rowan-projects.log"
set gemstone gs64stone user SystemUser pass ${SYSTEM_USER_PASSWORD}
iferror exit 1
login
doit
  |spec url |
  url := 'file://${ROWAN_PROJECTS_HOME}/${LRP_PROJECT_NAME}/rowan/specs/${LRP_LOAD_SPEC}.ston'.
  spec := RwSpecification fromUrl: url.
  spec resolve load.
%
commit
logout
exit 0
EOF

echo "Loading code in GS... [OK]"

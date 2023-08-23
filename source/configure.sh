#!/usr/bin/env bash

set -e

readonly SYSTEM_USER_PASSWORD="${GS64_SYSTEM_USER_PASSWORD:-swordfish}"

echo "Configuring GS Repository..."

topaz -i -q <<EOF > "${GEMSTONE_LOG_DIR}/configuring-repository.log"
set gemstone gs64stone user SystemUser pass ${SYSTEM_USER_PASSWORD}
iferror exit 1
login
doit
StringConfiguration enableUnicodeComparisonMode
%
commit
logout
exit 0
EOF

echo "Configuring GS Repository... [FINISHED]"

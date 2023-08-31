#!/usr/bin/env bash

set -e

readonly PROJECT_NAME=$1
readonly SYSTEM_USER_PASSWORD="${GS64_SYSTEM_USER_PASSWORD:-swordfish}"

echo "Running ${PROJECT_NAME} tests..."

touch "${GEMSTONE_LOG_DIR}/running-tests.log"

echo "Installing stdout printer & test reporter"

topaz -i -q <<EOF > "${GEMSTONE_LOG_DIR}/installing-stdout-support.log"
set gemstone gs64stone user SystemUser pass ${SYSTEM_USER_PASSWORD}
iferror exit 1
login
input StdOutPrinter.gs
input StdOutTestReporter.gs
commit
logout
exit 0
EOF

echo "Running test suite"

topaz -i -q <<EOF > "${GEMSTONE_LOG_DIR}/running-tests.log"
set gemstone gs64stone user SystemUser pass ${SYSTEM_USER_PASSWORD}
iferror exit 1
login
expectvalue true
doit
StdOutTestReporter new runTestsForProjectNamed: '${PROJECT_NAME}'
%
logout
exit 0
EOF

echo "Running ${PROJECT_NAME} tests... [FINISHED]"

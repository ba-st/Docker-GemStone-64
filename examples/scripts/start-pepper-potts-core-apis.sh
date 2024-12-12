#!/usr/bin/env bash

set -eu

readonly PUBLIC_URL=http://pc52.mercap.net:50555

topaz -l -q -- launchpad start pepper-potts-core --stargate.public-url=${PUBLIC_URL} --stargate.port=50555 --stargate.operations-secret=XXX --stargate.consul-agent-location= --root-system=PepperPottsCore  --authentication-secret=secret <<EOF

set gemstone gs64stone username SystemUser password swordfish
login
doit   
  LaunchpadCommandLineHandler activateWith: (CommandLineArguments new copyAfter: '--').
  [ Delay waitForMilliseconds: 20 ] repeat.
%
exit 0
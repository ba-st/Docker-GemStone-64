# Docker images reference

## `gs64-server` server docker image

This container image contains the GemStone/S 64 bits runtime support but doesn't
provide an `extent0.dbf`. Users will need to map a volume against `/opt/gemstone/data/`
containing the relevant data files (extents and transaction logs).

## `gs64-rowan` docker image

This container image builds on top of the server image providing the `extent0.rowan.dbf`
and a git installation. It's a useful target for a CI system.
In order to use Rowan for cloning and manipulating remote repositories, users
will need to map a volume against `/home/gemstone/.ssh/` containing the
relevant keys.

## `gs64-base` docker image

This container image builds on top of the server image providing the `extent0.dbf`

## `gs64-gem` docker image

This container image contains the GemStone/S 64 bits runtime support needed to run
a remote Gem.

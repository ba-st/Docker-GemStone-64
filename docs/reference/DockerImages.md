# Docker images reference

## `gs64` base docker image

This container image contains the GemStone/S 64 bits runtime support but doesn't
provide an `extent0.dbf`. Users will need to map a volume against `/opt/gemstone/data/`
containing the relevant data files (extents and transaction logs).

## `gs64-rowan` docker image

This container image builds on top of the base image providing the `extent0.rowan.dbf`.
It's a useful target for a CI system.

## `gs64-rowan-loader` docker image

This container image builds on top of the rowan image installing also git.
In order to use Rowan for cloning and manipulating remote repositories, users
will need to map a volume against `/home/gemstone/.ssh/` containing the
relevant keys.

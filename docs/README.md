# Docker images for GemStone/S 64 bits

**Unofficial** docker images for GemStone/S 64 bits server and gem sessions.
This is a community project not endorsed by [GemTalk](https://gemtalksystems.com).

## Configuration

You can configure some things with environment variables:

- `NETLDI_SERVICE_NAME` Netldi service name. Defaults to `gs64ldi`
- `NETLDI_PORT` NetLDI service port. Defaults to `50384`
- `STONE_SERVICE_NAME` Stone service name. Defaults to `gs64stone`
- `STONE_PORT` Stone service port. Defaults to `50385`
- `GEMSTONE_NRS_ALL` Defaults to `#netldi:gs64ldi#dir:/opt/gemstone/logs/#log:/opt/gemstone/logs/%N_%P.log`
- `GS_FORCE_CLEAN_LOG_FILE_DELETE` Defaults to `true`
- `DATA_CURATOR_PASSWORD` Password of the `DataCurator` user, used for stopping
  the services. Defaults to `swordfish`.
- `STOPSTONE_TIMEOUT_SECONDS` time-out in seconds to wait for `stopstone`
  command to finish.

## Important directories and files

- `/opt/gemstone/conf/${STONE_SERVICE_NAME}.conf` Stone configuration, created if missing.
- `/opt/gemstone/conf/system.conf` GemStone system configuration, created if missing.
- `/opt/gemstone/data` Extent and transaction log location
- `/opt/gemstone/locks` Lock files
- `/opt/gemstone/logs` Log files
- `/opt/gemstone/product/sys/gemstone.key` License key, by default `community.starter.key`
  is used.

# How to load a Rowan project

`gs64-rowan` images contains some simple scripts to load a Rowan-aware project
from disk located in `ROWAN_PROJECTS_HOME`. Once you have started the image you
can do something like:

```bash
docker exec -it -e GS64_CI_PROJECT_NAME=Buoy examples-stone-1 ./load-rowan-project.sh
```

This will try to use `${ROWAN_PROJECTS_HOME}/Buoy/rowan/specs/Buoy-CI.ston` as the
loading specification.

The script supports the following configuration:

- `GS64_CI_PROJECT_NAME` is mandatory and will be used as the folder containing
  the project to load
- `GS64_CI_SPEC` is optional. It's the name of the spec file to load.
  Defaults to `${GS64_CI_PROJECT_NAME}-CI`
- `GS64_CI_SYSTEM_USER_PASSWORD` is optional. The password for the `SystemUser`
  account in the mounted extent. Defaults to `swordfish`.

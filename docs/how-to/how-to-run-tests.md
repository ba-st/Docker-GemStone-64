# How to run tests for a Rowan project

`gs64-rowan` images contains some simple scripts to run the test of a loaded
Rowan-aware project. Once you have started the image you
can do something like:

```bash
docker exec -it examples-stone-1 ./run-tests.sh Buoy
```

The script supports the following configuration:

- The only accepted script argument is the rowan-aware project name
- `GS64_SYSTEM_USER_PASSWORD` is optional. The password for the `SystemUser`
  account in the mounted extent. Defaults to `swordfish`.

#!/bin/sh
# Starts the app as the unprivileged "darman" user. When started as root (e.g. on Render, whose persistent disk is mounted
# root-owned) it first fixes ownership of the private storage directory, then drops privileges.
set -e
STORAGE="${DARMAN_STORAGE_PATH:-/data/private-storage}"
if [ "$(id -u)" = "0" ]; then
  mkdir -p "$STORAGE"
  chown -R darman:darman "$STORAGE"
  exec setpriv --reuid=darman --regid=darman --init-groups java -jar /app/app.jar "$@"
fi
exec java -jar /app/app.jar "$@"

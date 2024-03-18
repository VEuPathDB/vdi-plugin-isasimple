#!/bin/bash

set -e
trap 'gracefulShutdown' SIGINT SIGTERM

# Attempts to cleanly shut down the postgres instance.
shutdownPostgres() {
  echo "Stopping Postgres server..."
  su postgres -c '/usr/lib/postgresql/15/bin/pg_ctl stop -m fast'
}

# Attempts to cleanly shut down the HTTP server.
shutdownService() {
  echo "Stopping plugin server..."
  kill -TERM $javaServerPID
}

# Clean shutdown
gracefulShutdown() {
  shutdownPostgres
  shutdownService
}

# Shutdown on error
uglyShutdown() {
  shutdownPostgres
  exit 1
}

# Start the HTTP server first to take advantage of the `-e` flag as this process
# is the most likely to fail.
java -jar -XX:+CrashOnOutOfMemoryError $JVM_MEM_ARGS $JVM_ARGS /service.jar &
javaServerPID=$!

# Start the postgres server
su postgres <<EOSU
/usr/lib/postgresql/15/bin/pg_ctl start
EOSU

# Wait for postgres to be ready for connections
timeout 90s bash -c "until pg_isready -U postgres; do sleep 5 ; done;"

# Pause while the HTTP server is online.
wait $javaServerPID

# If we made it here, then the HTTP server died on its own.
uglyShutdown
#!/usr/bin/env bash

set -e

PATH=$PROJECT_HOME/install/bin:$GUS_HOME/bin:$PATH

stopInstance() {
  echo "Stopping Postgres server..."
  su postgres -c '/usr/lib/postgresql/15/bin/pg_ctl stop -m fast'
  echo "Goodbye"
}

stopInstanceAndExit() {
  stopInstance
  exit 1;
}

# Trap any ERR signal and run the stopInstance function
trap 'stopInstanceAndExit' SIGINT SIGTERM

su postgres <<EOSU
/usr/lib/postgresql/15/bin/pg_ctl start
EOSU

# make sure the server is ready for connections
timeout 90s bash -c "until pg_isready -U postgres; do sleep 5 ; done;"


# Wait indefinitely;
while true
do
#    su postgres -c '/usr/lib/postgresql/15/bin/pg_ctl status'
    sleep 5
done

# Cleanup and stop the PostgreSQL server
stopInstanceAndExit

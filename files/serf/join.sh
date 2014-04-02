#!/bin/bash

for i in inotifywait serf; do
  command -v $i >/dev/null 2>&1 || { echo >&2 "[FAIL] $i required, but not installed. Aborting."; exit 1; }
done

SERF_IP=${AMBASSADOR_PORT_7946_TCP_ADDR:-"127.0.0.1"}
SERF_PORT=${AMBASSADOR_PORT_7946_TCP_PORT:-"7946"}
SERF_DIR="/files/serf"

echo Looping serf join when files change
if [[ $1 = "-d" ]]; then
  sleep 1
  echo "[INFO] daemonizing for supervisor"
  while [ 1 ] ; do
    serf join $SERF_IP:$SERF_PORT
    # serf join returned error? exit and let supervisor handle it.
    if [[ "$?" -ne "0" ]] ; then
      echo "[FAIL] Serf Command: serf join $SERF_IP:$SERF_PORT"
      exit 1
    else
      echo "[OK] Serf Command: serf join $SERF_IP:$SERF_PORT"
    fi
    inotifywait -rq $SERF_DIR 2>&1 > /dev/null
  done
else
  # run without any flags.
  until ps aux | grep -q "[s]erf agent"; do
    echo "[FAIL] serf agent not running"
    sleep 1
  done
  echo "[OK] serf agent running.";
  serf join $SERF_IP:$SERF_PORT
fi

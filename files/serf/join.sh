#!/bin/bash

INSTALL_CHECK=0
for i in supervisor supervisorctl inotifywait serf; do
  command -v $i >/dev/null 2>&1 || { echo >&2 "[FAIL] Program '$i' required, but not installed."; INSTALL_CHECK=1; }
done

if [ $INSTALL_CHECK -eq 1 ]; then
  echo [FAIL] Serf Join: Missing Dependencies. Exiting.
  exit 1
fi

SERF_IP=${AMBASSADOR_PORT_7946_TCP_ADDR:-"127.0.0.1"}
SERF_PORT=${AMBASSADOR_PORT_7946_TCP_PORT:-"7946"}
SERF_DIR=${SERFJOIN_DIR:-"/files/serf"}

if [[ $1 = "-d" ]]; then
  sleep 1
  echo "[INFO] daemonizing for supervisor"
    serf join $SERF_IP:$SERF_PORT
    # serf join returned error? exit and let supervisor handle it.
    if [[ "$?" -ne "0" ]] ; then
      echo "[FAIL] Serf Command: serf join $SERF_IP:$SERF_PORT"
      exit 1
    else
      echo "[OK] Serf Command: serf join $SERF_IP:$SERF_PORT"
    fi
    inotifywait -rq $SERF_DIR 2>&1 > /dev/null
    serf leave && echo "[INFO] serf agent gracefully left the cluster"
else
  # as a non-daemon, join only after serf agent is running
  until ps aux | grep -q "[s]erf agent"; do
    echo "[FAIL] serf agent not running"
    sleep 1
  done
  serf join $SERF_IP:$SERF_PORT && echo "[OK] serf agent running.";
fi

#!/bin/bash

set -e

for i in supervisord supervisorctl inotifywait serf; do
  command -v $i >/dev/null 2>&1 || { echo >&2 "[FAIL] Program '$i' required, but not installed."; }
done

if [[ $? != 0 ]]; then
  return 1
else
  echo >&1 "[OK] Installation check succeeded."
fi

#!/bin/bash

for i in supervisord supervisorctl inotifywait serf; do
  command -v $i >/dev/null 2>&1 || { echo >&2 "[FAIL] Program '$i' required, but not installed."; exit 1; }
done

exit 0

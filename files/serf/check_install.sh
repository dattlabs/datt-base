#!/bin/bash

unset fail
for i in supervisord supervisorctl inotifywait serf; do
  command -v $i &>/dev/null || { echo >&2 "[FAIL] Program '$i' required but not installed."; fail=1; }
done

if [[ $fail == 1 ]]; then exit 1; fi
echo >&1 "[OK] Installation check succeeded."; exit 0

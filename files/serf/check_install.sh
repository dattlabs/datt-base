#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $SCRIPT_DIR/../scripts/helpers.bash

unset fail
for i in supervisord supervisorctl inotifywait serf; do
  [[ `is_installed $i` = "1" ]] || fail=1
done

[[ $fail == 1 ]] && exit 1
echo >&1 "[OK] Installation check succeeded."; exit 0

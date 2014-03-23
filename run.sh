#!/bin/bash

# not building first. assuming that it's built or available remotely.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR="${DIR##*/}"

docker run -i -t --rm -w "/files" --name "$CURRENT_DIR" --hostname $CURRENT_DIR loyal3/$CURRENT_DIR bash -c "supervisord && /bin/bash"

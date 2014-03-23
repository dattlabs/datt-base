#!/bin/bash

source build

docker run -i -t --rm -w "/files" --name "$CURRENT_DIR" --hostname $CURRENT_DIR loyal3/$CURRENT_DIR bash -c "supervisord; /bin/bash"

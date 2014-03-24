#!/bin/bash

source build

# The docker index server can be set to a local index, or by default it will use the current directory name before the `-` separator. for example: datt-nginx will use the `datt` index account.

INDEX_NAME=$(echo $CURRENT_DIR | cut -d- -f 1)

DOCKERINDEX=${DOCKERINDEX_LOCAL:-"$INDEX_NAME/"}

# DEBUG
# echo "DOCKERINDEX=$DOCKERINDEX"
# echo "DIR=$DIR"
# echo "CURRENT_DIR=$CURRENT_DIR"

docker run -i -t --rm -w "/files" --name "$CURRENT_DIR" --hostname $CURRENT_DIR $DOCKERINDEX$CURRENT_DIR bash -c "supervisord; /bin/bash"

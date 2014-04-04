#!/bin/bash

export CONTAINER_HOST_IP=`netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`
node /files/test_server.js

#!/bin/bash
serf agent -tag role=${SERF_ROLE:-base} -event-handler="member-join=/files/serf/member-join.sh" \
  -event-handler="member-leave,member-failed=/files/serf/member-leave.sh"

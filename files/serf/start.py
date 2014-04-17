#!/usr/bin/env python

import itertools
import subprocess
import os
import sys

container_props = sys.argv[1]
tags=''
if os.path.exists(container_props):
  with open(container_props) as f:
    isCommentOrEmpty = lambda x: len(x) > 0 and not x.startswith('#')
    tags = filter(isCommentOrEmpty, ['='.join([s.strip() for s in line.split('=')]) for line in f.readlines()])
    tags = list(itertools.chain(*[['-tag', "%s" % s] for s in tags]))

options = tags + ['-rpc-addr=0.0.0.0:7373']

print 'Starting agent with options: %s' % options
subprocess.call(['serf', 'agent'] + options)

FROM datt/datt-ubuntu:latest
MAINTAINER John Albietz <inthecloud247@gmail.com>

RUN \
  `# Dev Packages (very large. keep at top.)`; \
  apt-get update;             \
  apt-get -y install          \
   python-software-properties \
   build-essential            \
   make                       \
   automake                   \
   uuid-dev                   \
   libtool                    \
   python-pip;                \
                              \
  `# remove cached packages`; \
  apt-get clean;

RUN \
  `# install base utils`;     \
  apt-get update;             \
  apt-get -y install          \
   apt-utils                  \
   pkg-config                 \
   vim                        \
   psmisc                     \
   less                       \
   curl                       \
   wget                       \
   rsync                      \
   unzip                      \
   sudo                       \
   `# git from ppa.`;         \
  add-apt-repository -y ppa:git-core/ppa; \
  apt-get update;             \
  apt-get -y install git;     \
                              \
  `# useful system tools (iputils* has ping & common tools)`; \
  apt-get -y install          \
    iotop                     \
    pv                        \
    htop                      \
    hdparm                    \
    sysstat                   \
    ethtool                   \
    bwm-ng                    \
    net-tools                 \
    iputils*;                 \
                              \
  `# install base services`;  \
                              \
  `# ssh w/docker fix`;       \
  apt-get -y install          \
    openssh-server            \
    ssh;                      \
  mkdir -v /var/run/sshd;     \
                              \   
  `# process supervisors`;    \
  apt-get -y install          \
    supervisor                \
    runit                     \
    inotify-tools;            \
  pip install --upgrade circus circus-web; \
                              \
  `# terminal multiplexers`;  \
  apt-get -y install          \
    screen                    \
    byobu                     \
    tmux;                     \
                              \
  `# cron w/o checks for lost+found and scans for mtab`; \
  apt-get -y install cron;    \
  rm -f /etc/cron.daily/standard; \
                              \
  `# remove cached packages`; \
  apt-get clean;

RUN \
  `# logging`; \
  \
  `# heka 0.5.1 install`; \
  DL_LOCATION="https://github.com/mozilla-services/heka/releases/download/v0.5.1/"; \
  DL_FILE="heka_0.5.1_amd64.deb"; \
  wget -c --no-check-certificate $DL_LOCATION$DL_FILE; \
  dpkg -i ./$DL_FILE; \
  rm -vf ./$DL_FILE; \
  \
  `# syslog-ng`; \
  apt-get -y install syslog-ng-core; \
  mkdir -p /var/lib/syslog-ng; \
  \
  `# logrotate`; \
  apt-get -y install logrotate;
  \
  `# remove cached packages`; \
  apt-get clean;

ADD files/ /files/

RUN \
  \
  `# setup directories in /etc`; \
  for p in hekad supervisor; do \
    [ -h /etc/$p ] && echo "removing existing symlink $p" && unlink /etc/$p/; \
    [ -d /etc/$p ] && echo "removing existing directory $p" && rm -rfv /etc/$p/; \
    ln -vs /files/$p/ /etc/; \
  done; \
  \
  `# setup directories in /var/log`; \
  for p in test_server hekad crond sshd syslog-ng; do \
    mkdir -v /var/log/supervisor/$p; \
  done;

RUN \
  `# Install serf client 0.5.0`                               ; \
  mkdir -vp /opt/serf/; cd /opt/serf/                         ; \
  DL_LOCATION="https://dl.bintray.com/mitchellh/serf/"        ; \
  DL_FILE="0.5.0_linux_amd64.zip"                             ; \
  wget --continue --no-check-certificate $DL_LOCATION$DL_FILE ; \
  unzip $DL_FILE                                              ; \
  rm -v *.zip                                                 ; \
                                                                \
  `# Install symlinks so it's in the path`                    ; \
  ln -vs /opt/serf/serf /usr/sbin/serf                        ; \
                                                                \
  `# Add app to supervisor`                                   ; \
  for i in serf-join serf-agent; do                             \
    mkdir -v /var/log/supervisor/$i                           ; \
  done;

# To run in DEBUG mode, run the docker container with RUN_DEBUG=1 set in the environment.
# Can set by running container with flag: `--env RUN_DEBUG=1`.

# modification to /etc/environment based on: https://github.com/dotcloud/docker/issues/2569

ENV RUN_DEBUG 0

# for /files/test_server.js
RUN \
  apt-get update; \
  apt-get install -y nodejs; \
  mkdir -p /files/tests; \
  apt-get clean

EXPOSE 13337

CMD \
  env | grep "._" >> /etc/environment                           ; \
  if [ $RUN_DEBUG -ne 0 ]                                       ; \
  then                                                            \
    echo [DEBUG]           ; \
    /usr/bin/supervisord && /bin/bash                           ; \
  else                                                            \
    /usr/bin/supervisord --nodaemon                             ; \
  fi                                                              ;

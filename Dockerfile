FROM datt/datt-ubuntu:latest
MAINTAINER John Albietz "inthecloud247@gmail.com"

RUN \
  `# Dev Packages (very large. keep at top.)`; \
  apt-get update; \
  apt-get -y install \
   python-software-properties \
   build-essential \
   make \
   automake \
   uuid-dev \
   libtool; \
  \
  `# remove cached packages`; \
  apt-get clean;

RUN \
  `# install base utils`; \
  apt-get update; \
  apt-get -y install \
   apt-utils \
   pkg-config \
   vim \
   psmisc \
   less \
   curl \
   wget \
   rsync \
   unzip \
   sudo \
   `# git from ppa.`; \
  add-apt-repository -y ppa:git-core/ppa; \
  apt-get -y install git; \
  \
  `# useful system tools (iputils* has ping & common tools)`; \
  apt-get -y install \
    iotop \
    pv \
    htop \
    hdparm \
    sysstat \
    ethtool \
    bwm-ng \
    net-tools \
    iputils*; \
  \
  `# install base services`; \
  \
  `# ssh w/docker fix`; \
  apt-get -y install \
    openssh-server \
    ssh; \
  mkdir -v /var/run/sshd; \
  \
  `# process supervisors`; \
  apt-get -y install \
    supervisor \
    runit; \
  pip install --upgrade circus circus-web; \
  \
  `# terminal multiplexers`; \
  apt-get -y install \
    screen \
    byobu \
    tmux; \
  \
  `# cron w/o checks for lost+found and scans for mtab`; \
  apt-get -y install cron; \
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

# heka and supervisor configs
ADD files/hekad/ /etc/hekad/
ADD files/supervisor/ /etc/supervisor/

RUN \
  `# setup supervisord config files and log directories`; \
  for p in hekad crond sshd syslog-ng; do mkdir -v /var/log/supervisor/$p; done; \
  \
  `# Add LOGSERVER ip address to hekad config`; \
  LOGSERVER_IP=$(/sbin/ip route | awk '/default/ { print $3; }'); \
  sed -i "s/{{LOGSERVER_IP}}/$LOGSERVER_IP/g" /etc/hekad/aggregator_output.toml;

## [serf]

ADD files/serf-scripts /files/

RUN \
  `# Install serf client 0.5.0`                                    ; \
  mkdir -vp /opt/serf/; cd /opt/serf/                              ; \
  DL_LOCATION="https://dl.bintray.com/mitchellh/serf/"             ; \
  DL_FILE="0.5.0_linux_amd64.zip"                                  ; \
  wget --continue --no-check-certificate $DL_LOCATION$DL_FILE      ; \
  unzip $DL_FILE                                                   ; \
  rm -v *.zip                                                      ;

RUN \
  `# Install symlinks so it's in the path`                         ; \
  ln -s /opt/serf/serf /usr/sbin/serf                              ;

# Add app to supervisor
RUN mkdir /var/log/supervisor/serf

## [/serf]

# To run in DEBUG mode, run the docker container with RUN_DEBUG=1 set in the environment.
# Can set by running container with flag: `--env RUN_DEBUG=1`.

# modification to /etc/environment based on: https://github.com/dotcloud/docker/issues/2569

ENV RUN_DEBUG 0

CMD if [ $RUN_DEBUG -gt 0 ]                                         ; \
      then                                                            \
        echo [DEBUG]; env | grep "._" >> /etc/environment           ; \
        env | grep "._" >> /etc/environment                            ; \
        /usr/bin/supervisord && /bin/bash                           ; \
      else                                                            \
        env | grep "._" >> /etc/environment                         ; \
        /usr/bin/supervisord --nodaemon                             ; \
    fi                                                              ;

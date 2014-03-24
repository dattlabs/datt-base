FROM datt/datt-ubuntu:latest
MAINTAINER John Albietz "inthecloud247@gmail.com"

RUN \
  `# Dev Packages (very large. keep at top.)`; \
  apt-get -y install \
   python-software-properties \
   build-essential \
   make \
   automake \
   uuid-dev \
   libtool

RUN \
  `# install base utils`; \
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
  apt-get update; \
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
  pip install circus circus-web; \
  \
  `# terminal multiplexers`; \
  apt-get -y install \
    screen \
    byobu \
    tmux; \
  \
  `# cron w/o checks for lost+found and scans for mtab`; \
  apt-get -y install cron; \
  rm -f /etc/cron.daily/standard;

RUN \
  `# logging`; \
  \
  `# heka 0.4.2 install`; \
  wget -c --no-check-certificate https://github.com/mozilla-services/heka/releases/download/v0.4.2/heka_0.4.2_amd64.deb; \
  dpkg -i ./heka_0.4.2_amd64.deb; \
  rm -vf heka_0.4.2_amd64.deb; \
  \
  `# syslog-ng`; \
  apt-get -y install syslog-ng-core; \
  mkdir -p /var/lib/syslog-ng; \
  \
  `# logrotate`; \
  apt-get -y install logrotate;


# copy required conf files and folders
ADD files /files

RUN \
  `# setup supervisord config files and log directories`; \
  for p in hekad crond sshd syslog-ng; do mkdir -v /var/log/supervisor/$p; done; \
  cp -vr /files/hekad /etc; \
  cp -vr /files/supervisor /etc; \
  \
  `# Add LOGSERVER ip address to hekad config`; \
  LOGSERVER_IP=$(/sbin/ip route | awk '/default/ { print $3; }'); \
  sed -i "s/{{LOGSERVER_IP}}/$LOGSERVER_IP/g" /etc/hekad/aggregator_output.toml;

CMD ["/usr/bin/supervisord", "--nodaemon"]

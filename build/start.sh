#!/bin/sh
set -e
set -x
echo Installing Ubuntu $UBUNTU_RELEASE
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -yq apt-utils

#yes | unminimize
# based of https://github.com/blitterated/docker_dev_env/wiki/Setup-man-pages-in-a-minimized-Ubuntu-container 
if [ -x "$(command -v unminimize)" ]; then \
 apt update \
 && apt --yes upgrade \
 # comment out dpkg exclusion for manpages
 && sed -e '\|/usr/share/man|s|^#*|#|g' -i /etc/dpkg/dpkg.cfg.d/excludes \
 # install manpage packages and dependencies
 && apt --yes install apt-utils dialog manpages manpages-posix man-db less \
 # remove dpkg-divert entries
 && rm -f /usr/bin/man \
 && dpkg-divert --quiet --remove --rename /usr/bin/man \
 && rm -f /usr/share/man/man1/sh.1.gz \
 && dpkg-divert --quiet --remove --rename /usr/share/man/man1/sh.1.gz \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/* ;\
fi

apt-get update
apt-get install -yq \
    vim \
    locales \
    binutils \
    dialog \
    openssh-server \
    sudo \
    iproute2 \
    curl \
    lsb-release \
    less \
    joe \
    man-db \
    net-tools \
    python-apt \
    python \
    ubuntu-desktop

apt-get -q -y remove snapd 
apt-get -qq clean
apt-get -qq autoremove 

# disable services we do not need
systemctl disable gdm upower fstrim.timer fstrim e2scrub_reap e2scrub_all e2scrub_all.timer

# Prevents apt-get upgrade issue when upgrading in a container environment.
# Similar to https://bugs.launchpad.net/ubuntu/+source/makedev/+bug/1675163
### cp makedev /etc/apt/preferences.d/makedev

cp locale.conf /etc/locale.conf
cp locale /etc/default/locale
cp locale.gen /etc/locale.gen
locale-gen

# make sure we get fresh ssh keys on first boot
/bin/rm -f -v /etc/ssh/ssh_host_*_key*
cp *.service /etc/systemd/system
systemctl enable regenerate_ssh_host_keys
# Remove the divert that disables services
rm -f /sbin/initctl
dpkg-divert --local --rename --remove /sbin/initctl

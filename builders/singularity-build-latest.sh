#!/bin/bash


################################################################################
# Instance Preparation
# For Google cloud, Stackdriver/logging should have Write, 
#                   Google Storage should have Full
#                   All other APIs None,
#
################################################################################

sudo apt-get update > /tmp/.install-log
sudo apt-get -y install git \
                   build-essential \
                   libtool \
                   autotools-dev \
                   automake \
                   autoconf \
                   debootstrap \
                   yum \
                   python3-pip >> /tmp/.install-log

# Install Singularity from Github
cd /tmp && git clone -b feature-squashbuild-secbuild https://github.com/cclerget/singularity.git
cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install && sudo make secbuildimg

# Pip3 installs
sudo pip3 install --upgrade pip &&
sudo pip3 install pandas &&
sudo pip3 install --upgrade google-api-python-client &&
sudo pip3 install --upgrade google &&
sudo pip3 install oauth2client==3.0.0

# Singularity python development
cd /tmp && git clone -b development https://www.github.com/vsoch/singularity-python.git
cd /tmp/singularity-python && sudo python3 setup.py install


################################################################################
# Building
################################################################################

python3 -c "from singularity.build.google import run_build; run_build()" > /tmp/.shub-log 2>&1

# Finish by sending log
export command=$(echo "from singularity.build.google import finish_build; finish_build()") &&
python3 -c "$command"

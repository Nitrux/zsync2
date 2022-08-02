#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt-get"
else
    APT_COMMAND="apt-get"
fi

$APT_COMMAND update -q
$APT_COMMAND install -qy --no-install-recommends \
    automake \
    checkinstall \
    cmake \
    g++ \
    git \
    libcurl4-nss-dev \
    libgcrypt20-dev \
    libssh2-1-dev \
    libssl-dev \
    libtool \
    pkg-config \
    python3-dev \
    zlib1g-dev
#!/bin/bash

set -x

### Install Build Tools #1

DEBIAN_FRONTEND=noninteractive apt -qq update
DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	 git \
	 cmake \
	 checkinstall \
	 g++

### Install Package Build Dependencies #2

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
	libssl-dev \
	libssh2-1-dev \
	libcurl4-gnutls-dev \
	zlib1g-dev

### Clone repo.

git clone --single-branch --branch master https://github.com/AppImage/zsync2.git
git submodule update --init

rm -rf zsync2/{COPYING,README.md,ci}

### Compile Source

mkdir -p zsync2/build && cd zsync2/build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DUSE_SYSTEM_CURL=1 \
	-DBUILD_CPR_TESTS=0 \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ..

make -j$(nproc)

### Run checkinstall and Build Debian Package
### DO NOT USE debuild, screw it

>> description-pak printf "%s\n" \
	'A rewrite of zsync.' \
	'' \
	'The rewrite changes fundamental principles of how zsync works.' \
	'' \
	'Functionality will be bundled in a single library called libzsync2.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=zsync2 \
	--pkgversion=2.0.0-alpha-1-20220123 \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=utils \
	--pkgsource=zsync2 \
	--pakdir=../.. \
	--maintainer=uri_herrera@nxos.org \
	--provides=zsync2 \
	--requires="libssl1.1,libssh2-1,libcurl3-gnutls,zlib1g" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes

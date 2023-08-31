#! /bin/bash

set -x

### Download Source

git clone --recursive --single-branch --branch $ZSYNC2_BRANCH https://github.com/AppImage/zsync2.git
# git submodule foreach git pull
# git clone --single-branch --branch master https://github.com/libcpr/cpr.git
# git clone --single-branch --branch main https://github.com/google/googletest.git
# git clone --single-branch --branch master https://github.com/Taywee/args.git

# cp -r cpr/* zsync2/lib/cpr/
# cp -r googletest/* zsync2/lib/gtest/
# cp -r args/* zsync2/lib/args/

rm -rf \
	zsync2/{COPYING,README.md,ci}

### Compile Source

mkdir -p build && cd build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu ../zsync2/

make -j$(nproc)

mkdir -p /usr/lib/x86_64-linux-gnu/cmake/zsync2

### Run checkinstall and Build Debian Package

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
	--pkgversion=$PACKAGE_VERSION \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=zsync2 \
	--pakdir=../ \
	--maintainer=uri_herrera@nxos.org \
	--provides=zsync2 \
	--requires="libssl1.1,libssl3,libssh2-1,libcurl3-nss,libgcrypt20,zlib1g" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes

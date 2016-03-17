#!/bin/bash
# Automated build script 
# tested on Debian 8.3 jessie (stable) x86_64 

set -e 

# basic requirements (toolchain)
echo "BB: installing basic requirements ..."  
sudo apt-get install \
git \
build-essential \
g++ \
libtool \
autotools-dev \
automake \
pkg-config \
bsdmainutils  


# bitcoin requirements
echo "BB: installing bitcoin requirements ..."
sudo apt-get install \
libssl-dev \
libevent-dev \
libboost-system-dev \
libboost-filesystem-dev \
libboost-chrono-dev \
libboost-program-options-dev \
libboost-test-dev \
libboost-thread-dev \


# Cloneg bitcoin repository
if [ -a "./bitcoin" ];
then
	echo "git repository already cloned ... "
else 
	git clone https://github.com/bitcoin/bitcoin.git	
fi
cd ./bitcoin 
git checkout remotes/origin/0.12


# Download and install BerkleyDB locally
echo "BB: installing BerkleyDB from source ..."
BITCOIN_ROOT=$(pwd)
BDB_PREFIX="${BITCOIN_ROOT}/db4"
cd ..
if [ -a "$BDB_PREFIX" ] && [ -a "./db-4.8.30.NC" ];
then
	echo "=== BB === BerkleyDB already there ..."
else 
	mkdir -p $BDB_PREFIX
	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c
	tar -xzvf db-4.8.30.NC.tar.gz
	cd db-4.8.30.NC/build_unix/
	../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
	make install
fi
cd $BITCOIN_ROOT

# Build bitcoin core
cd "${BITCOIN_ROOT}"

./autogen.sh

echo "=== BB === autgen DONE "
sleep 2


./configure \
LDFLAGS="-L${BDB_PREFIX}/lib/" \
CPPFLAGS="-I${BDB_PREFIX}/include/" \
--without-gui \
--without-miniupnpc \
--disable-zmq \
--enable-hardening 
#--with-pic

#./configure \
#LDFLAGS="-L${BDB_PREFIX}/lib/ -L/usr/lib/x86_64-linux-gnu -static" \
#CPPFLAGS="-I${BDB_PREFIX}/include/" \
#CXXFLAGS="-static" \
#CFLAGS="-static" \
#--disable-zmq \
#--without-gui \
#--without-miniupnpc \
#--disable-tests \
#--disable-shared \
#--enable-static \
#--enable-hardening \
#--with-pic

echo "=== BB === configure DONE "
sleep 2

make clean
echo "=== BB === make clean DONE "
sleep 2

make


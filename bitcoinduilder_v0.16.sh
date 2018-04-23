#!/usr/bin/env bash
set -e

# adapted from the travis-ci file

git clone https://github.com/bitcoin/bitcoin
cd bitcoin

# sudo: required
# dist: trusty
# os: linux

MAKEJOBS=-j17
RUN_TESTS=false
CHECK_DOC=0
SDK_URL=https://bitcoincore.org/depends-sources/sdks
WINEDEBUG=fixme-all

HOST=x86_64-unknown-linux-gnu
PACKAGES="python3-zmq qt4-dev-tools libqt4-dev libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libdb5.3++-dev libminiupnpc-dev libzmq3-dev libprotobuf-dev protobuf-compiler libqrencode-dev xvfb"
BITCOIN_CONFIG="--enable-zmq --with-incompatible-bdb --enable-glibc-back-compat --enable-reduce-exports --with-gui=qt4 CPPFLAGS=-DDEBUG_LOCKORDER"
DEP_OPTS="NO_WALLET=1" 
RUN_TESTS=true 
GOAL="install" 

# before install
export PATH=$(echo $PATH | tr ':' "\n" | sed '/\/opt\/python/d' | tr "\n" ":" | sed "s|::|:|g")

# install:

sudo apt-get update
sudo apt-get install --no-install-recommends --no-upgrade -qq $PACKAGES

# before_script:

unset CC
unset CXX
mkdir -p depends/SDKs depends/sdk-sources

# script:

BITCOIN_CONFIG_ALL="--disable-dependency-tracking --prefix=$PWD/build/$HOST --bindir=$PWD/build/bin --libdir=$PWD/build/lib"
./autogen.sh
mkdir build && cd build
../configure $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG
make distdir VERSION=$HOST
cd bitcoin-$HOST
./configure $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG
make $MAKEJOBS $GOAL 

export LD_LIBRARY_PATH=$PWD/build/lib
make $MAKEJOBS check VERBOSE=1
test/functional/test_runner.py --combinedlogslen=4000 --coverage --quiet ${extended}

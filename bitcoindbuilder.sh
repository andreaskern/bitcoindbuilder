#!/bin/bash
# Automated build script 
# Use at your own risk 
#
# tested on:
#   * Debian 8.3 jessie (stable) x86_64 
#   * Ubuntu 14.04 amd64
#   * Ubuntu 16.04 amd64  
#
# Optionally:
# Set custom git url and branch e.g.:
# $ bash bitcoindbuilder.sh --git-url="https://github.com/kernoelpanic/bitcoin.git" --git-branch="remotes/origin/powerclient_0.12" 

set -e 

GIT_URL="https://github.com/bitcoin/bitcoin.git"
GIT_BRANCH="remotes/origin/0.12"
DIR=$(pwd)

function usage()
{
    echo "Bitcoin build script, automates building the current version of bitcoin-core."
    echo ""
    echo "${0}"
    echo -e "\t-h --help"
    echo -e "\t--git-url=${GIT_URL}"
    echo -e "\t--git-branch=${GIT_BRANCH}"
    echo -e "\t--dir=${DIR}"
    echo ""
}

# main
if [ "$1" == "" ]; then
    usage
    exit
fi

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | sed 's/^[^=]*=//g'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --git-url)
            GIT_URL=${VALUE}
            ;;
        --git-branch)
            GIT_BRANCH=${VALUE}
            ;;
        --dir)
            DIR=${VALUE}
            ;;
        *)
            echo "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done


echo "BB: GIT_URL    = ${GIT_URL}";
echo "BB: GIT_BRANCH = ${GIT_BRANCH}";
echo "BB: DIR 	     = ${DIR}";



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
cd ${DIR}
if [ -a "./bitcoin" ];
then
	echo "git repository already cloned ... "
else 
	git clone ${GIT_URL} 	
fi
cd ./bitcoin 
git checkout ${GIT_BRANCH}


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


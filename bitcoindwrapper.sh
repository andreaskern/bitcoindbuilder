#!/bin/bash
# 
# Wrapper script for `bitcoind` and `bitcoincli`
#
# Use at own risk!
#
# Commands wrapped:
# ./bitcoind -daemon -txindex -datadir="/home/bitcoin/bitcoin_datadirs/powerclient_0.12/"
# export BTC_DATA="${BTC_DATA}";
# ./bitcoin-cli --datadir=$BTC_DATA getinfo
# 
# Future work: 
# Read password from command line and unlock wallet.
# In shell script pw can be handed over to bitcoin-cli that way:
# echo -e "mysecretcode\n120" | src/bitcoin-cli -stdin walletpassphrase

set -e

BITCOIND="/home/bitcoin/bitcoin_bin/0.12/bitcoind"
BTC_DATA="/home/bitcoin/bitcoin_data/0.12/"
WALLET="wallet.dat"
ACTION="start"
BITCOINCLI="/home/bitcoin/bitcoin_bin/0.12/bitcoin-cli"
PORT="8333"

function usage()
{
    echo "Local Bitcoin core wrapper script"
    echo ""
    echo "${0}"
    echo -e "\t-h --help"
    echo -e "\t--bitcoind=${BITCOIND}"
    echo -e "\t--btc-data=${BTC_DATA}"
    echo -e "\t--wallet=${WALLET}"
    echo -e "\t--action=${ACTION}"
    echo -e "\t--port=${PORT}"
    echo ""
}

# main
if [ "$1" == "" ]; then
    usage
    #exit
fi

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | sed 's/^[^=]*=//g'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
	--bitcoind)
	    BITCOIND="${VALUE}"
	    ;;
        --btc-data)
            BTC_DATA="${VALUE}"
            ;;
        --action)
            ACTION="${VALUE}"
            ;;
        --wallet)
            WALLET="${VALUE}"
            ;;
        --bitcoincli)
            BITCOINCLI="${VALUE}"
            ;;
        --port)
            PORT="${VALUE}"
            ;;
	*)
            echo "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done

echo "BITCOIND   is ${BITCOIND}";
echo "BTC_DATA   is ${BTC_DATA}";
echo "BITCOINCLI is ${BITCOINCLI}";
echo "ACTION     is ${ACTION}";
echo "PORT       is ${PORT}";

if [ "${ACTION}" == "start" ];
then
	${BITCOIND} -daemon -txindex -datadir="${BTC_DATA}" -port="${PORT}" --wallet="${WALLET}";
	exit 0 
fi

if [ "${ACTION}" != "" ];
then
	${BITCOINCLI} --datadir=${BTC_DATA} ${ACTION};
fi 

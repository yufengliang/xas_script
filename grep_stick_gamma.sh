#!/bin/bash

if [ $# -ne 2 ] && [ $# -ne 0 ]; then
	echo "extract all the gamma point state from all the stick files present in the current folder"
	echo "usage 1: $0"
	echo "Deal with stick file from 0 to 23 (the normal case)"
	echo "usage 2: $0 lo hi"
	echo "Deal with stick file from lo to hi."
fi

lo=0
hi=23
if [ $# -eq 2 ]; then
	lo=$1
	hi=$2
fi

for num in `seq $lo $hi`
do
	cat *.xas.5.stick.$num | awk '$2=1{print $1,$2,$3,$4}'
done 

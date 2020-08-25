#! /bin/sh

if [ ! -d $hw1 ]; then mkdir $hw1 fi

if [ ! -d $arch ]; then mkdir $arch fi

while [ 1 ]; do if [ -f $filename ]; then cat $filename > ${arch}/copy.c fi

if [ $filename -ot ${arch}/copy.c ]; then
	origindate=$(date -r ${filename})
	cat ${filename} > ${arch}/${origindate}
	cat $filename > ${arch}/copy.c	
fi
done

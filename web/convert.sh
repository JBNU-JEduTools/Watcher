#!/bin/bash

dir=$1

gifdir=$dir.gifs
mkdir $gifdir

for entry in `ls $dir`; do
	if [[ -z "$start" ]]; then
	       echo $entry
		   gifname="${gifdir}/${entry}.gif"
		   pygmentize -f gif -l c $dir/$entry > $gifname
	fi	
done

convert -delay 10 -loop 1 $gifdir/*.gif $dir.gif

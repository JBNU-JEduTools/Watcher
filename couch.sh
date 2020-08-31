#! /bin/bash
HOME="/home/ubuntu"
ARCH="/var/log/scriptTest"

if [ ! -d $ARCH ]; then 
    mkdir $ARCH 
fi

while [ 1 ]; do 
	HW=( `ls $HOME | grep hw` )
	for i in ${HW[*]}; do
		if [ ! -d $ARCH/${i} ]; then 
		    mkdir $ARCH/${i} 
		fi
	done

	ACTDIR=( `ls -t $HOME | grep hw`)
	FILENAME=( `ls $HOME/${ACTDIR}| grep \\.c` )
	for i in $FILENAME; do
		if [ ! -d $ARCH/${ACTDIR}/${i}/ ]; then 
			mkdir ${ARCH}/${ACTDIR}/${i}
			cat $i > ${ARCH}/${ACTDIR}/${i}/.copy.c 
		fi
	done
#	for FILENAME in `ls $HOME/${ACTDIR}| grep \\.c`; do
#		if [ ! -d $ARCH/${ACTDIR}/$FILENAME/ ]; then 
#			mkdir ${ARCH}/${ACTDIR}/${FILENAME}
#			cat $FILENAME > ${ARCH}/${ACTDIR}/${FILENAME}/.copy.c 
#		fi
#	done

	if [ ${FILENAME[0]} -ot ${ARCH}/${ACTDIR}/${FILENAME[0]}/.copy.c ]; then
        origindate=`date -r $HOME/${ACTDIR}/${FILENAME[0]} '+%s'`
		cat $HOME/${ACTDIR}/${FILENAME[0]} > ${ARCH}/${ACTDIR}/${FILENAME[0]}/${origindate}
		cat $HOME/${ACTDIR}/${FILENAME[0]} > ${ARCH}/${ACTDIR}/${FILENAME[0]}/.copy.c	
	fi
	sleep 0.5s
done
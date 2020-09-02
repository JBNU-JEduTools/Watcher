#! /bin/bash
#usage: nohup ./couch.sh &
HOME="/home/ubuntu"
ARCH="/var/log/scriptTest"

if [ ! -d $ARCH ]; then 
    mkdir $ARCH 
fi

while [ 1 ]; do 
	HW=( `ls $HOME | grep hw` ) #hw 폴더 탐지
	for i in ${HW[*]}; do
		if [ ! -d $ARCH/${i} ]; then 
		    mkdir $ARCH/${i} #탐지된 폴더의 키로깅 폴더 생성
			echo make new hw dir
		fi
	done

	ACTDIR=( `ls -t $HOME | grep hw`) # 최근 변경된 폴더만 확인
	if [ $ACTDIR ]; then
		FILENAME=( `ls $HOME/${ACTDIR}| grep \\.c` ) # 해당 폴더의 파일 확인
		for i in $FILENAME; do
			if [ ! -d $ARCH/${ACTDIR}/${i}/ ]; then 
				mkdir ${ARCH}/${ACTDIR}/${i} # 해당 폴더의 파일중 새로 생성된 파일이 있다면 해당 파일의 키로깅 폴더 생성
				echo make new logging dir
				cp $i ${ARCH}/${ACTDIR}/${i}/.copy.c # 날짜비교 및 최신내용 기록 파일 생성
				echo make new copyfile
			fi
		done
	fi
#	for FILENAME in `ls $HOME/${ACTDIR}| grep \\.c`; do
#		if [ ! -d $ARCH/${ACTDIR}/$FILENAME/ ]; then 
#			mkdir ${ARCH}/${ACTDIR}/${FILENAME}
#			cat $FILENAME > ${ARCH}/${ACTDIR}/${FILENAME}/.copy.c 
#		fi
#	done

	if [ $HOME/${ACTDIR}/${FILENAME[0]} -nt ${ARCH}/${ACTDIR}/${FILENAME[0]}/.copy.c ]; then # 파일 수정 여부 확인
        origindate=`date -r $HOME/${ACTDIR}/${FILENAME[0]} '+%s'` 
		cp $HOME/${ACTDIR}/${FILENAME[0]} ${ARCH}/${ACTDIR}/${FILENAME[0]}/${origindate} #타임스탬프
			echo make new timestamp
		cp $HOME/${ACTDIR}/${FILENAME[0]} ${ARCH}/${ACTDIR}/${FILENAME[0]}/.copy.c	# 기준파일 갱신
			echo edit copyfile
	fi
	sleep 0.1
done
#! /bin/bash
#usage: nohup ./couch.sh &
HOME="/home/ubuntu"
TARGET="/var/log/Couch/$(hostname)"
#TARGET="/home/ubuntu/$(hostname)"


echo "*** Couch service is started! $(date)"
echo "Home directory: $HOME"
echo "Couch storage: $TARGET"

if [ ! -d $TARGET ]; then 
    mkdir -p $TARGET 
fi



while [ 1 ]; do 
	HW=( `ls $HOME | grep hw` ) #hw 폴더 탐지
	for i in ${HW[*]}; do
		if [ ! -d $TARGET/${i} ]; then 
		    mkdir -p $TARGET/${i} #탐지된 폴더의 키로깅 폴더 생성
			echo make new hw dir
		fi
	done

    ACTDIR=( `ls -t $HOME | grep hw`) # 최근 변경된 폴더만 확인
	#echo "ACTDIR=$ACTDIR-end"
	if [ ! -z $ACTDIR ]; then
		FILENAME=( `ls -t $HOME/${ACTDIR}| grep \\.c` ) # 해당 폴더의 파일 확인        
		#echo "FILENAME=$FILENAME-end"
		
        if [ ! -z $FILENAME ]; then
            if [ ! -d $TARGET/${ACTDIR}/$FILENAME/ ]; then 
                mkdir -p ${TARGET}/${ACTDIR}/$FILENAME # 해당 폴더의 파일중 새로 생성된 파일이 있다면 해당 파일의 키로깅 폴더 생성
                echo make new logging dir
                cp ${HOME}/${ACTDIR}/$FILENAME ${TARGET}/${ACTDIR}/$FILENAME/.copy.c # 날짜비교 및 최신내용 기록 파일 생성
                echo make new copyfile
                continue;
            fi

            if [ $HOME/${ACTDIR}/${FILENAME} -nt ${TARGET}/${ACTDIR}/${FILENAME}/.copy.c ]; then # 파일 수정 여부 확인
                origindate=`date -r $HOME/${ACTDIR}/${FILENAME} '+%s'` 
                cp $HOME/${ACTDIR}/${FILENAME} ${TARGET}/${ACTDIR}/${FILENAME}/${origindate} #타임스탬프
		#echo "make new timestamp and update copy file for: $HOME/${ACTDIR}/${FILENAME} at $(date)"
		echo "*** Update file: $HOME/${ACTDIR}/${FILENAME} at $(date)"
                cp $HOME/${ACTDIR}/${FILENAME} ${TARGET}/${ACTDIR}/${FILENAME}/.copy.c	# 기준파일 갱신
                /usr/lib/Couch/client ${TARGET}/${ACTDIR}/${FILENAME}/${origindate} 10.0.0.150
                echo "*** Send the file: ${origindate}"
                #rm ${TARGET}/${ACTDIR}/${FILENAME}/${origindate}
            fi
		fi
    fi    
	sleep 0.5
done


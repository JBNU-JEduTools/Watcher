#!/bin/bash

#dir=sample
#dir=/var/log/scriptTest/hw1/hw1.c
dir=$1
duration=$2
start=""
end=""

for entry in `ls $dir`; do
	if [[ -z "$start" ]]; then
	       echo "start is empty"
	       start=$entry
	fi
	echo $entry
done

end=$entry

echo "Start: $start"
echo "End: $end"
diff=$(expr $end - $start)
echo $diff

tick=$(expr $duration \* 1000)
echo $tick
tick=$(expr $tick / $diff)

curr=$(($start))
end=$(($end))

for (( curr = $(($start)); curr <= $(($end)); curr++));
do	
	#clear
	if [ -f $dir/$curr ]; then
		#echo "$curr exits"
		clear
		#pygmentize -l c $dir/$curr
		cat $dir/$curr
		echo -e "\n"
		echo "time: $curr"
	#else
		#echo""
		#echo $curr
	fi
	sleep 0.0$tick

done

echo -e "\n"
echo "----------------------"
echo "------ Summary -------"
echo "----------------------"
echo "Start: $start"
echo "End: $end"
echo "Total: $diff seconds"
echo "Playtime: $duration seconds"
echo "Tick: $tick milliseconds"

#clear
#pygmentize -g b.c
#sleep 3s
#clear
#until [ $curr -lt $end ]

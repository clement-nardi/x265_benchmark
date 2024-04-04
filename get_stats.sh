#!/bin/bash

input_video=./20240222_C0087.MP4

osize=$(stat -c%s "$input_video")
for p in ultrafast superfast veryfast faster fast medium slow slower veryslow ; do
	echo -n ";$p;$p;$p"
done
echo
echo "CRF;VMAF;Size;Time;VMAF;Size;Time;VMAF;Size;Time;VMAF;Size;Time;VMAF;Size;Time;VMAF;Size;Time;VMAF;Size;Time;VMAF;Size;Time;VMAF;Size"
for i in $(seq 15 30) ; do 
	echo -n "$i;"
	for p in ultrafast superfast veryfast faster fast medium slow slower veryslow ; do
		video_file_name=${input_video}_${i}_${p}.mp4
		vmaf_json=${video_file_name}-vmaf.json
		duration=$video_file_name.duration
		
		if [ -f "$vmaf_json" ] ; then
			echo -n "$(jq .pooled_metrics.vmaf.mean "$vmaf_json");"
		else
			echo -n ";"
			
		fi
		if [ -f "$video_file_name" ] ; then
			size=$(stat -c%s "$video_file_name")
			ratio=$(bc -l <<< "$size / $osize")
			echo -n "$ratio;"
		else
			echo -n ";"
		fi
		if [ -f "$duration" ] ; then
			echo -n "$(cat "$duration");"
		else
			echo -n ";"
		fi
	done
	echo
done

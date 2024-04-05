#!/bin/bash

script_dir=$(dirname "$0")
video_path="/home/cnardi/Pictures/SONY ZV-E1_raw/20240223_C0092.MP4"
video_folder=$(dirname "$video_path")
video_name=$(basename "$video_path")

video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_path")

osize=$(stat -c%s "$video_path")

echo "CRF;Preset;VMAF;Size;Time"
for i in $(seq 15 30) ; do 
	for p in ultrafast superfast veryfast faster fast medium slow slower veryslow ; do
		echo -n "$i;$p;"

		video_file_path="${script_dir}/outputs/${video_name}_${i}_${p}.mp4"
		vmaf_json="${video_file_path}-vmaf.json"
		duration="${video_file_path}.duration"
		
		if [ -f "$vmaf_json" ] ; then
			echo -n "$(jq .pooled_metrics.vmaf.mean "$vmaf_json");"
		else
			echo -n ";"
			
		fi
		if [ -f "$video_file_path" ] ; then
			size=$(stat -c%s "$video_file_path")
			ratio=$(bc -l <<< "$size / $osize")
			echo -n "$ratio;"
		else
			echo -n ";"
		fi
		if [ -f "$duration" ] ; then
			length="$(cat "$duration")"
			operation="$length / $video_duration"
			factor=$(bc -l <<< "$operation")
			echo -n "$factor;"
		else
			echo -n ";"
		fi
		echo
	done
done

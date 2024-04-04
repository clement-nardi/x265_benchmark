#!/bin/bash

input_video=./20240222_C0087.MP4

videos_to_analyze=()

# exit on ctrl-c
trap "exit" INT

function parallel_vmaf {
	echo "running VMAF analysis in parallel"
	for video in "${videos_to_analyze[@]}" ; do
		echo "running VMAF analysis for $video"
		ffmpeg -i "$video" -i $input_video -lavfi libvmaf=log_path="${video}-vmaf.json":log_fmt=json -f null - </dev/null >/dev/null 2>/dev/null &
	done
	wait
	videos_to_analyze=()
}

for i in $(seq 15 30) ; do
	for p in ultrafast superfast veryfast faster fast medium slow slower veryslow ; do
		video_file_name=${input_video}_${i}_${p}.mp4
		
		if [ ! -f "$video_file_name" ] ; then
			echo "missing $video_file_name -> encode"
			begin=$(date +%s)
			ffmpeg -i $input_video -c:v libx265 -preset $p -crf "$i" -c:a aac -b:a 256k "$video_file_name" >/dev/null 2>/dev/null
			end=$(date +%s)
			duration=$((end-begin))
			echo $duration > "${video_file_name}.duration"

			if [ ! -f "${video_file_name}-vmaf.json" ] ; then
				videos_to_analyze+=("$video_file_name")
			fi
			# if more than 10 videos to analyze, run VMAF analysis in parallel
			if [ ${#videos_to_analyze[@]} -ge 10 ] ; then
				parallel_vmaf
			fi

		fi
	done
done


if [ ${#videos_to_analyze[@]} -ge 0 ] ; then
	parallel_vmaf
fi
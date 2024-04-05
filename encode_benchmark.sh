#!/bin/bash

video_path="/home/cnardi/Pictures/SONY ZV-E1_raw/20240223_C0092.MP4"
video_folder=$(dirname "$video_path")
video_name=$(basename "$video_path")

script_dir=$(dirname "$0")

videos_to_analyze=()

# exit on ctrl-c
trap "exit" INT

function parallel_vmaf {
	echo "running VMAF analysis in parallel"
	for video in "${videos_to_analyze[@]}" ; do
		echo "running VMAF analysis for $video"
		ffmpeg -i "$video" -i "$video_path" -lavfi libvmaf=log_path="${video}-vmaf.json":log_fmt=json -f null - </dev/null >/dev/null 2>/dev/null &
	done
	wait
	videos_to_analyze=()
}

for i in $(seq 19 26) ; do
	for p in ultrafast superfast veryfast faster fast medium slow slower ; do
		video_file_path="$(realpath ${script_dir}/outputs/${video_name}_${i}_${p}.mp4)"

		
		if [ ! -f "$video_file_path" ] ; then
			echo "missing $video_file_path -> encode"
			begin=$(date +%s)
			ffmpeg -i "$video_path" -c:v libx265 -preset $p -crf "$i" -c:a aac -b:a 256k "$video_file_path" >/dev/null 2>/dev/null
			end=$(date +%s)
			duration=$((end-begin))
			echo $duration > "${video_file_path}.duration"
		fi

		if [ ! -f "${video_file_path}-vmaf.json" ] ; then
			videos_to_analyze+=("$video_file_path")
		fi
		# if more than 10 videos to analyze, run VMAF analysis in parallel
		if [ ${#videos_to_analyze[@]} -ge 8 ] ; then
			parallel_vmaf
		fi
	done
done


if [ ${#videos_to_analyze[@]} -ge 0 ] ; then
	parallel_vmaf
fi
#!/bin/bash


flacfilecount=($(find "$1" -iname "*.flac" | wc -l))
mp3filecount=($(find "$1" -iname "*.mp3" | wc -l))
echo "Number of FLAC files to process $flacfilecount"
echo "Number of MP3 files to process $mp3filecount"

ProcessFlacFiles () {

    if [ ! -f "${file%.flac}.m4a" ]; then
        bash tag.bash "$file"
    fi
    if [ -f "${file%.flac}.m4a" ]; then
        echo "Encoded and Tagged: ${file%.flac}.m4a"
        # rm "$file"
        echo "Deleted: $file"
    else
        echo "Failed Encoding and Tagging: $file"
    fi
   
}

ProcessMP3Files () {

    if [ ! -f "${file%.mp3}.m4a" ]; then
        bash tag.bash "$file"
    fi
    if [ -f "${file%.mp3}.m4a" ]; then
        echo "Encoded and Tagged: ${file%.mp3}.m4a"
        # rm "$file"
        echo "Deleted: $file"
    else
        echo "Failed Encoding and Tagging: $file"
    fi
   
}

echo "Processing Files using $2 Threads"
N=$2
(
find "$1" -iname "*.flac" -print0 | while IFS= read -r -d '' file; do
   ((i=i%N)); ((i++==0)) && wait
   ProcessFlacFiles &
done
wait
)

(
find "$1" -iname "*.mp3" -print0 | while IFS= read -r -d '' file; do
   ((i=i%N)); ((i++==0)) && wait
   ProcessMP3Files &
done
wait
)

exit 0
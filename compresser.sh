#!/bin/bash

INPUT_DIR="$PWD"
OUTPUT_DIR="$PWD/compressed"
CRF=23

while getopts ":i:c:o:" opt; do
  case $opt in
    i) INPUT_DIR="$OPTARG"
    ;;
    c) CRF="$OPTARG"
    ;;
    o) OUTPUT_DIR="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ $# -eq 0 ]
  then
    echo "No arguments supplied! Running $0 using default params:"
else
    echo "Running $0 using arguments:"
fi

echo -e "INPUT_DIR=$INPUT_DIR\nOUTPUT_DIR=$OUTPUT_DIR\nCRF=$CRF"

#create output directory for compressed files
mkdir -p "$OUTPUT_DIR"
TEMP_DIR=$(mktemp -d)

#ffmpeg -i  -c:v libx264

find "$INPUT_DIR" -type f -exec file -N -i -- {} + | grep video | cut -d':' -f1\
| while read -r file; do
  filename=$(basename "$file")
  extension="${filename##*.}"
  video_file="${filename%.*}"

  mkdir -p "$( dirname "$OUTPUT_DIR/$filename" )"
  mkdir -p "$( dirname "$TEMP_DIR/$filename" )"
  
  COMPRESSED_FILE="$OUTPUT_DIR/$filename"
  if [ -f "$COMPRESSED_FILE" ]; then
    echo "$filename is already compressed"
  else
    echo "Compressing $filename"
    ffmpeg -i $file -c:v libx264 -preset ultrafast -crf $CRF -c:a copy "$TEMP_DIR/$filename" < /dev/null
    mv "$TEMP_DIR/$filename" "$COMPRESSED_FILE"

  fi
done


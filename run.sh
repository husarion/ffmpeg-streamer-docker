#!/bin/bash

# Check if the script has the necessary environment variables
if [[ -z "$RAW_TOPIC" || -z "$FFMPEG_TOPIC" || -z "$TYPE" ]]; then
  echo "Error: One or more environment variables (RAW_TOPIC, FFMPEG_TOPIC, TYPE) are unset."
  exit 1
fi

echo "[$TYPE] raw topic: $RAW_TOPIC, ffmpeg topic: $FFMPEG_TOPIC"
# Conditional execution based on the value of TYPE
if [ "$TYPE" == "ENCODER" ]; then
  ros2 run image_transport republish \
  raw ffmpeg \
  --ros-args --remap in:="$RAW_TOPIC" \
  --ros-args --remap out/ffmpeg:="$FFMPEG_TOPIC" \
  --params-file /params.yaml

elif [ "$TYPE" == "DECODER" ]; then
  ros2 run image_transport republish \
  ffmpeg raw \
  --ros-args --remap in/ffmpeg:="$FFMPEG_TOPIC" \
  --ros-args --remap out:="$RAW_TOPIC" \
  --params-file /params.yaml

else
  echo "Error: TYPE environment variable must be either ENCODER or DECODER."
  exit 2
fi

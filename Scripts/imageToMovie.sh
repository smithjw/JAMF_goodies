#!/bin/bash

echo "What folder are the images located in?"
read folder
echo "What extension do the images have?"
read extension
echo "Thanks, I'm now converting the images to movies"
echo ""
sleep 1

for file in "$folder"/*."$extension"; do
    #echo "$file"
    #echo "$(basename "$file" .jpg).mp4"
    ffmpeg -loop 1 -i "$file" -c:v libx264 -b:v 5M -r 1 -t 180 "$(basename "$file" ."$extension").mp4"
done

exit 0

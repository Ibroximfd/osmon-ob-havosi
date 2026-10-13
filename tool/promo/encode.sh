#!/bin/sh
# Encodes every rendered frame set in build/promo/frames/ into an MP4 with
# the soundtrack: H.264 High, yuv420p and faststart, so Telegram plays it
# inline and starts streaming at once.
set -e
cd "$(dirname "$0")/../.."
for dir in build/promo/frames/*/; do
  name=$(basename "$dir")
  ffmpeg -y -loglevel error \
    -framerate 30 -i "$dir/f%04d.png" \
    -i build/promo/music.wav \
    -c:v libx264 -preset slow -crf 17 -profile:v high -pix_fmt yuv420p \
    -af loudnorm=I=-16:TP=-1.5:LRA=11 \
    -c:a aac -b:a 160k -shortest -movflags +faststart \
    "build/promo/osmon_promo_${name}.mp4"
  echo "build/promo/osmon_promo_${name}.mp4"
done

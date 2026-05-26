---
tags:
  - ffmpeg
  - media
  - gif
  - images
  - mp4
  - webm
variables:
  timestamp:
    default: "00:00:03"
  gifs:
    command: rg --files -g "*.{gif,webp}"
  output:
    default: frame.png
---

# FFMPEG

## Extract a frame from a GIF

- `-ss` seeks to the timestamp,
- `-i` chooses the input file, and
- `-frames:v 1` writes exactly one video frame.

```bash
ffmpeg -y -ss <@timestamp:?00:00:03> -i <@gifs> -frames:v 1 -update 1 <@output>
```

## Extract a frame from near the end of a GIF

```bash
ffmpeg -hide_banner -loglevel warning -y -sseof -0.1 -i <@gifs> -frames:v 1 -update 1 <@output>
```

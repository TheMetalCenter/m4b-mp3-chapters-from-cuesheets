ffmpeg -i input.mp4 -i metadata.txt -map_metadata 1 -codec copy output.mp4
pause
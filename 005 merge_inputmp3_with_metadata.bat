ffmpeg -i input.mp3 -i metadata.txt -map_metadata 1 -codec copy output.mp3
pause
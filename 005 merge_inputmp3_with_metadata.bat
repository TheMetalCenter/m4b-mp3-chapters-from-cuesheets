ffmpeg -i input.mp3 -f ffmetadata -i metadata.txt -map_metadata 0 -id3v2_version 3 -map_chapters 1 -c copy output.mp3
ffprobe output.mp3 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > title.txt
@echo off
set /p name=< title.txt
rename output.mp3 "%name%.mp3"
md "%name%"
MOVE "%name%.mp3" "%name%"
del title.txt
pause
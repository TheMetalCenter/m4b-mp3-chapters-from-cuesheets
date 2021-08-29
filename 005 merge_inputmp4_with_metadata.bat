@echo off
if exist "input.mp4" (
if exist "metadata.txt" (
goto :merge
) else goto :stop
) else goto :stop

:merge
echo merging mp4 with metadata
ffmpeg -i input.mp4 -f ffmetadata -i metadata.txt -map_metadata 0 -map_chapters 1 -c copy output.mp4
pause
exit

:stop
echo MISSING input.mp4 and/or metadata.txt
pause
exit
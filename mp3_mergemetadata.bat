@echo off
if exist "input.mp3" (
if exist "metadata.txt" (
goto :merge
) else goto :stop
) else goto :stop

:merge
echo Merging mp3 with metadata...
::Merges input.mp3 with metadata.txt and map chapters in id3v2.v3
ffmpeg -i input.mp3 -f ffmetadata -i metadata.txt -map_metadata 0 -id3v2_version 3 -map_chapters 1 -c copy output.mp3

::Copies the album field to a temp text file and sets variable
ffprobe output.mp3 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > title.txt
@echo off
set /p name=< title.txt

rename output.mp3 "%name%.mp3" >nul 2>&1
md "%name%" >nul 2>&1
MOVE "%name%.mp3" "%name%" >nul 2>&1

rename ".mp3" "output.mp3" >nul 2>&1

:cleanup
del title.txt >nul 2>&1
del length.txt >nul 2>&1
del metadata.txt >nul 2>&1

echo Make sure output looks good, input will be deleted
pause

:cleanup2
del input.mp3 >nul 2>&1
del list.txt >nul 2>&1
exit

:stop
echo MISSING input.mp3 and/or metadata.txt
pause
exit
@echo off
if exist "input.mp3" (
if exist "metadata.txt" (
goto :merge
) else goto :stop
) else goto :stop

:merge
echo merging mp3 with metadata
::Merges input.mp3 with metadata.txt and map chapters in id3v2.v3
ffmpeg -i input.mp3 -f ffmetadata -i metadata.txt -map_metadata 0 -id3v2_version 3 -map_chapters 1 -c copy output.mp3

::Copies the album field to a temp text file and sets variable
ffprobe output.mp3 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > title.txt
@echo off
set /p name=< title.txt

::Renames output filename to album field
echo renaming output mp3 and cuesheet...
rename output.mp3 "%name%.mp3"
rename cuesheet.cue "%name%.cue

::Moves mp3 to folder of same name
echo moving output file...
md "%name%" >nul 2>&1
MOVE "%name%.mp3" "%name%" >nul 2>&1

::Delete temp file
del title.txt

::If there album field is blank, then the filename instead becomes ".mp3"
::This will rename it back to output.mp3
rename ".mp3" "output.mp3" >nul 2>&1

::Pause to make sure chapters look good, can delete if desired
pause
exit

:stop
echo MISSING input.mp3 and/or metadata.txt
pause
exit
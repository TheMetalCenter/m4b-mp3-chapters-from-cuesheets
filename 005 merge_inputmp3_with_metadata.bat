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

::Renames output and cuesheet using album field
echo renaming output mp3 and cuesheet...
rename output.mp3 "%name%.mp3" >nul 2>&1
rename cuesheet.cue "%name%.cue" >nul 2>&1

::Moves mp3 to folder of same name and cuesheet to backup folder
echo moving output file and backing up cuesheet...
md "%name%" >nul 2>&1
MOVE "%name%.mp3" "%name%" >nul 2>&1
MOVE "%name%.cue" "cuesheet_backup" >nul 2>&1

::If there album field is blank, then the filename instead becomes ".mp3" or ".cue"
::This will rename it to original name
rename ".mp3" "output.mp3" >nul 2>&1
rename ".cue" "cuesheetbackup.cue" >nul 2>&1


::Delete temp files
del title.txt >nul 2>&1

::Pause to make sure chapters look good, can delete if desired
pause
call "007 cleanup.bat"
exit

:stop
echo MISSING input.mp3 and/or metadata.txt
pause
exit
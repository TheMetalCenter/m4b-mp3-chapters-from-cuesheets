@echo off
if exist "input.mp3" (
if exist "cuesheet.cue" (
goto :convert
) else goto :stop
) else goto :stop

:convert
::Often the reason of failure is special characters

echo Getting input duration...
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp3 > length.txt
set /p length=< length.txt

echo Converting cue to metadata...
::Calls cue2ffmeta ruby script to convert cuesheet.cue to ffmetadata in text file
::The file will be created even if conversion fails, will be a blank file
cue2ffmeta.rb cuesheet.cue %length% > metadata.txt

:merge
echo Merging mp3 with metadata...
::Merges input.mp3 with metadata.txt and map chapters in id3v2.v3
ffmpeg -i input.mp3 -f ffmetadata -i metadata.txt -map_metadata 0 -id3v2_version 3 -map_chapters 1 -c copy output.mp3

::Copies the album field to a temp text file and sets variable
ffprobe output.mp3 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > title.txt
@echo off
set /p name=< title.txt

::Renames output and cuesheet using album field
echo Renaming output mp3 and cuesheet...
rename output.mp3 "%name%.mp3" >nul 2>&1
rename cuesheet.cue "%name%.cue" >nul 2>&1

::Moves mp3 to folder of same name and cuesheet to backup folder
echo Moving output file and backing up cuesheet...
md "%name%" >nul 2>&1
MOVE "%name%.mp3" "%name%" >nul 2>&1
MOVE "%name%.cue" "cuesheet_backup" >nul 2>&1

::If there album field is blank, then the filename instead becomes ".mp3" or ".cue"
::This will rename it to original name
rename ".mp3" "output.mp3" >nul 2>&1
rename ".cue" "cuesheetbackup.cue" >nul 2>&1

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
echo MISSING input.mp3 and/or cuesheet.cue
pause
exit
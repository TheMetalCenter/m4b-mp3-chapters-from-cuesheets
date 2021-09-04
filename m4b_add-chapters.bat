@echo off
if exist "input.mp4" (
if exist "cuesheet.cue" (
goto :convertcue2metadata
) else goto :stop
) else goto :stop

:convertcue2metadata
::Often the reason of failure is special characters

echo Getting input duration...
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4 > length.txt
set /p length=< length.txt

echo Converting cue to metadata...
::Calls cue2ffmeta ruby script to convert cuesheet.cue to ffmetadata in text file
::The file will be created even if conversion fails, will be a blank file
cue2ffmeta.rb cuesheet.cue %length% > metadata.txt

:merge
::Merges input.mp4 with metadata.txt and maps chapters
echo Merging mp4 with metadata...
ffmpeg -i input.mp4 -f ffmetadata -i metadata.txt -map_metadata 0 -map_chapters 1 -c copy output.mp4

:convertmp4tom4b
@echo off
::Copies the album field to a temp text file and sets variable
ffprobe output.mp4 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > title.txt
set /p name=< title.txt

::Converts all mp4 to m4b with nero/quicktime chapters (will fail on input.mp4 since no chapters)
echo Converting mp4 to m4b...
FOR %%i IN (output.mp4) DO (
 echo converting %%i
 mp4chaps.exe -QuickTime -convert "%%i"
 rename "%%i" "%%~ni.m4b"
)
echo Renaming output and cuesheet...
::Renames output and cuesheet using album field
echo renaming output m4b and cuesheet...
rename output.m4b "%name%.m4b" >nul 2>&1
rename cuesheet.cue "%name%.cue" >nul 2>&1

::Moves m4b to folder of same name and cuesheet to backup folder
echo Moving output and backing up cuesheet...
md "%name%" >nul 2>&1
MOVE "%name%.m4b" "%name%" >nul 2>&1
MOVE "%name%.cue" "cuesheet_backup" >nul 2>&1

::If there album field is blank, then the filename instead becomes ".m4b" or ".cue"
::This will rename it to original name
rename ".m4b" "output.m4b" >nul 2>&1
rename ".cue" "cuesheetbackup.cue" >nul 2>&1

:cleanup
del title.txt >nul 2>&1
del length.txt >nul 2>&1
del metadata.txt >nul 2>&1

echo Make sure output looks good, input will be deleted
pause

:cleanup2
del input.mp4 >nul 2>&1
del list.txt >nul 2>&1
exit

:stop
echo MISSING input.mp4 and/or cuesheet.txt
pause
exit
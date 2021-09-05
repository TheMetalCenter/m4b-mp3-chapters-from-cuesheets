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
if %errorlevel%==1 (echo WARNING: Unable to convert properly. Check cuesheet for unsupported special characters)
if %errorlevel%==1 (goto :stop2)
if %errorlevel%==0 (echo No warnings found, continuing...)

:merge
echo Merging mp3 with metadata...
::Merges input.mp3 with metadata.txt and map chapters in id3v2.v3
ffmpeg -i input.mp3 -f ffmetadata -i metadata.txt -map_metadata 0 -id3v2_version 3 -map_chapters 1 -c copy output.mp3

::Copies the album field to a temp text file and sets variable
ffprobe output.mp3 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > oldalbum.txt

::This removes illegal characters from album field
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION 
SET "filename1=oldalbum.txt"
SET "outfile="newalbum.txt"
(
FOR /f "usebackqdelims=" %%a IN ("%filename1%") DO (
 SET "line=%%a"
 SET "line=!line:?=!"
 SET "line=!line:/=-!"
 SET "line=!line::= -!"
 ECHO !line!
)
)>"%outfile%"

@echo off
set /p name=< newalbum.txt

::Renames output and cuesheet using album field
echo Renaming output mp3 and cuesheet...
rename output.mp3 "%name%.mp3" >nul 2>&1
rename cuesheet.cue "%name%.cue" >nul 2>&1

::Attempts to move mp3 to folder of same name and cuesheet to backup folder
echo Moving output file and backing up cuesheet...
md "%name%" >nul 2>&1
MOVE "%name%.mp3" "%name%" >nul 2>&1
rename ".cue" "cuesheet.cue" >nul 2>&1
MOVE "%name%.cue" "cuesheet_backup" >nul 2>&1
rename ".mp3" "output.mp3" >nul 2>&1

:cleanup
del length.txt >nul 2>&1
del oldalbum.txt >nul 2>&1
del newalbum.txt >nul 2>&1

echo Make sure output looks good, input will be deleted
pause
del metadata.txt >nul 2>&1

:cleanup2
del input.mp3 >nul 2>&1
del list.txt >nul 2>&1
exit

:stop
echo MISSING input.mp3 and/or cuesheet.cue
pause
exit

:stop2
echo ERROR in cuesheet conversion, check for special characters
pause
del metadata.txt
del length.txt
exit
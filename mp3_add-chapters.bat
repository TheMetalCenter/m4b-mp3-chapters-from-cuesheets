@echo off
:check1
if exist "input.mp3" (
goto :check2
) else goto :stop1

:check2
if exist "cuesheet.cue" (
goto :check3
) else goto :stop2

:check3
if exist "cue2ffmeta.rb" (
goto :check4
) else goto :stop3

:check4
if exist "ffmpeg.exe" (
goto :check5
) else goto :stop4

:check5
if exist "ffprobe.exe" (
goto :convertcue2metadata
) else goto :stop5

:convertcue2metadata
::Often the reason of failure is special characters

echo Getting input duration...
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp3 > length.txt
set /p length=< length.txt

echo Converting cue to metadata...
::Calls cue2ffmeta ruby script to convert cuesheet.cue to ffmetadata in text file
::The file will be created even if conversion fails, will be a blank file
cue2ffmeta.rb cuesheet.cue %length% > metadata.txt
if %errorlevel%==1 (echo WARNING: Unable to convert properly. Check cuesheet for unsupported special characters)
if %errorlevel%==1 (goto :stoperror)
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

:stop1
echo MISSING input.mp3
pause
exit

:stop2
echo MISSING cuesheet.cue
pause
exit

:stop3
echo MISSING cue2ffmeta.rb
pause
exit

:stop4
echo MISSING ffmpeg.exe
pause
exit

:stop5
echo MISSING ffprobe.exe
pause
exit

:stoperror
echo ERROR in cuesheet conversion, check for special characters
pause
del metadata.txt
del length.txt
exit
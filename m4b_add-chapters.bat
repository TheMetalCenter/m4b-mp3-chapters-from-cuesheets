@echo off
:check1
if exist "input.mp4" (
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
goto :check6
) else goto :stop5

:check6
if exist "mp4chaps.exe" (
goto :convertcue2metadata
) else goto :stop6

:convertcue2metadata
::Often the reason of failure is special characters

echo Getting input duration...
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4 > length.txt
set /p length=< length.txt

echo Converting cue to metadata...
::Calls cue2ffmeta ruby script to convert cuesheet.cue to ffmetadata in text file
::The file will be created even if conversion fails, will be a blank file
cue2ffmeta.rb cuesheet.cue %length% > metadata.txt
if %errorlevel%==1 (echo WARNING: Unable to convert properly. Check cuesheet for unsupported special characters)
if %errorlevel%==1 (goto :stoperror)
if %errorlevel%==0 (echo No warnings found, continuing...)

:merge
::Merges input.mp4 with metadata.txt and maps chapters
echo Merging mp4 with metadata...
ffmpeg -i input.mp4 -f ffmetadata -i metadata.txt -map_metadata 0 -map_chapters 1 -map 0:a:0? -c copy output.mp4

:convertmp4tom4b
@echo off
::Copies the album field to a temp text file and sets variable
ffprobe output.mp4 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > oldalbum.txt

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

set /p name=< newalbum.txt

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
rename ".cue" "cuesheetbackup.cue" >nul 2>&1
MOVE "%name%.cue" "cuesheet_backup" >nul 2>&1

::If there album field is blank, then the filename instead becomes ".m4b" or ".cue"
::This will rename it to original name
rename ".m4b" "output.m4b" >nul 2>&1

:cleanup
del oldalbum.txt >nul 2>&1
del newalbum.txt >nul 2>&1
del length.txt >nul 2>&1


echo Make sure output looks good, input will be deleted
pause

:cleanup2
del input.mp4 >nul 2>&1
del metadata.txt >nul 2>&1
del list.txt >nul 2>&1
exit

:stop1
echo MISSING input.mp4
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

:stop6
echo MISSING mp4chaps.exe
pause
exit

:stoperror
echo ERROR in cuesheet conversion, check for special characters
pause
del metadata.txt
del length.txt
exit
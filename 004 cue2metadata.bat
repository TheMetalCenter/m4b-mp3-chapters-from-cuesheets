@echo off
if exist "cuesheet.cue" (
goto :convert
) else goto :stop

:convert
::Calls cue2ffmeta ruby script to convert cuesheet.cue to ffmetadata in text file
::The file will be created even if conversion fails, will be a blank file
::Often the reason of failure is special characters

cue2ffmeta.rb cuesheet.cue > metadata.txt

::Add a pause command below in order to see rubycue's error messages
exit

:stop
echo MISSING cuesheet.cue
pause
exit
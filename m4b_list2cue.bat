@echo off
:check1
if exist "input.mp4" (
goto :check2
) else goto :stop1

:check2
if exist "list.txt" (
goto :check3
) else goto :stop2

:check3
if exist "list2cue.py" (
goto :list2cue
) else goto :stop3

:list2cue
python list2cue.py list.txt --audio-file="input.mp4" --output-file="cuesheet.cue"
echo cuesheet generated
pause
exit

:stop1
echo MISSING input.mp4
pause
exit

:stop2
echo MISSING list.txt
pause
exit

:stop3
echo MISSING list2cue.py
pause
exit
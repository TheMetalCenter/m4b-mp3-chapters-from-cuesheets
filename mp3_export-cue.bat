@echo off
:check1
if exist "export.mp3" (
goto :check2
) else goto :stop1

:check2
if exist "export-cue.py" (
goto :embedded2cue
) else goto :stop2

:embedded2cue
ffprobe -print_format compact=print_section=0:nokey=1:escape=csv -show_chapters "export.mp3" > metadata_chapters.txt
py export-cue.py metadata_chapters.txt --audio-file="export.mp3" --output-file="cuesheet.cue"
del metadata_chapters.txt
pause
exit

:stop1
echo MISSING export.mp3
pause
exit

:stop2
echo MISSING export-cue.py
pause
exit
@echo off
:check1
if exist "export.m4b" (
goto :check2
) else goto :stop1

:check2
if exist "export-cue.py" (
goto :embedded2cue
) else goto :stop2

:embedded2cue
ffprobe -print_format compact=print_section=0:nokey=1:escape=csv -show_chapters "export.m4b" > metadata_chapters.txt
py export-cue.py metadata_chapters.txt --audio-file="export.m4b" --output-file="cuesheet.cue"
del metadata_chapters.txt
exit

:stop1
echo MISSING export.m4b
pause
exit

:stop2
echo MISSING export-cue.py
pause
exit
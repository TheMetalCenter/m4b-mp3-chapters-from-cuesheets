FOR %%i IN (*.m4b) DO (
 rename "%%i" "export.m4b"
)

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
ffprobe -v 0 -select_streams a:0 -of compact=p=0:nk=1 -show_entries stream=time_base export.m4b > timebase.txt

:timebase
@echo off
SetLocal EnableDelayedExpansion

set input=timebase.txt
set output=timebase1.txt
set "substr=1/"

(
    FOR /F "usebackq delims=" %%G IN ("%input%") DO (
        set line=%%G
        echo. !line:%substr%=!
    )
) > "%output%"

EndLocal

py export-cue.py metadata_chapters.txt --audio-file="export.m4b" --output-file="cuesheet.cue"
del timebase.txt
del timebase1.txt
del metadata_chapters.txt
rename export.m4b input.mp4
exit

:stop1
echo MISSING export.m4b
pause
exit

:stop2
echo MISSING export-cue.py
pause
exit
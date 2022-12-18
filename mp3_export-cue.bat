FOR %%i IN (*.mp3) DO (
 rename "%%i" "export.mp3"
)

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

::This inverts the metadata_chapters file because the final chapter time base sometimes does not match the time base of the earlier chapters
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
SET "filename1=metadata_chapters.txt"
SET "outfile=metadata_chapters_inverted.txt"
SET /a count=0
FOR /f "delims=" %%a IN (%filename1%) DO (
 SET /a count+=1
 SET "line[!count!]=%%a"
)
(
FOR /L %%a IN (%count%,-1,1) DO ECHO(!line[%%a]!
)>"%outfile%"


::This fetches the timebase of the first chapter
Set "File=.\metadata_chapters_inverted.txt"
Set "Match=1"
Set "Tokens=2"
Set "Delimitter=|"

For /F "Tokens=%Tokens% Delims=%Delimitter%" %%# in (
    'Type "%File%"^|FIND /I "%Match%"'
) Do (
    Set "Value=%%#"
)

Echo %VALUE% > timebase.txt

:: This removes the numerator of the timebase
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

::This executes export-cue.py on the metadata_chapters.txt, which also uses the fetched timebase in calculation

py export-cue.py metadata_chapters.txt --audio-file="export.mp3" --output-file="cuesheet.cue"
del timebase.txt
del timebase1.txt
del metadata_chapters.txt
del metadata_chapters_inverted.txt
rename export.mp3 input.mp3
exit

:stop1
echo MISSING export.mp3
pause
exit

:stop2
echo MISSING export-cue.py
pause
exit
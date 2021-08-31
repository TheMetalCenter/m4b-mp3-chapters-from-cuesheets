@echo off
::Copies the album field to a temp text file and sets variable
ffprobe output.mp4 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > title.txt
set /p name=< title.txt

::Converts all mp4 to m4b with nero/quicktime chapters (will fail on input.mp4 since no chapters)
FOR %%i IN (*.mp4) DO (
 echo converting %%i
 mp4chaps.exe -QuickTime -convert "%%i"
 rename "%%i" "%%~ni.m4b"
 echo ---------------------
)
echo ---------------------
echo  CONVERTING COMPLETE, moving file to folder

::Renames output to album and moves to folder of same name
rename output.m4b "%name%.m4b" >nul 2>&1
rename final.m4b "%name%.m4b" >nul 2>&1
rename cuesheet.cue "%name%.cue >nul 2>&1
md "%name%" >nul 2>&1
MOVE "%name%.m4b" "%name%" >nul 2>&1
del title.txt >nul 2>&1
pause

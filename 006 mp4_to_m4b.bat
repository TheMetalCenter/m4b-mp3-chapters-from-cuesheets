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
rename output.m4b "%name%.m4b"
rename cuesheet.cue "%name%.cue
md "%name%"
MOVE "%name%.m4b" "%name%"
del title.txt
pause

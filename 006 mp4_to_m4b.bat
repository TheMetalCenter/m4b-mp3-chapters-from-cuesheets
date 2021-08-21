@echo off
ffprobe output.mp4 -show_entries format_tags=title -of compact=p=0:nk=1 -v 0 > title.txt
set /p name=< title.txt
FOR %%i IN (*.mp4) DO (
 echo converting %%i
 mp4chaps.exe -QuickTime -convert "%%i"
 rename "%%i" "%%~ni.m4b"
 echo ---------------------
)
echo ---------------------
echo  CONVERTING COMPLETE, moving file to folder
rename output.m4b "%name%.m4b"
md "%name%"
MOVE "%name%.m4b" "%name%"
del title.txt
pause

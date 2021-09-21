@echo off
:check1
if exist "input1.mp4" (
goto :check2
) else goto :stop1

:check2
if exist "input2.mp4" (
goto :check3
) else goto :stop2

:check3
if exist "mergechapters_ab.py" (
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
goto :mergechapterized
) else goto :stop6

:mergechapterized
py mergechapters_ab.py input1.mp4 input2.mp4 output.mp4
rename input1.mp4 input1.m4b >nul 2>&1
rename input2.mp4 input2.m4b >nul 2>&1

@echo off
::Copies the album field to a temp text file and sets variable
ffprobe output.mp4 -show_entries format_tags=album -of compact=p=0:nk=1 -v 0 > title.txt
set /p name=< title.txt

::Converts all mp4 to m4b with nero/quicktime chapters (will fail on input.mp4 since no chapters)
FOR %%i IN (output.mp4) DO (
 echo converting %%i
 mp4chaps.exe -QuickTime -convert "%%i"
 rename "%%i" "%%~ni.m4b"
)
echo  CONVERTING COMPLETE, moving file to folder
::Renames output using album field
echo renaming output m4b...
rename output.m4b "%name%.m4b" >nul 2>&1

::Moves m4b to folder of same name to backup folder
echo moving output file...
md "%name%" >nul 2>&1
MOVE "%name%.m4b" "%name%" >nul 2>&1

::If there album field is blank, then the filename instead becomes ".m4b"
::This will rename it to original name
rename ".m4b" "output.m4b" >nul 2>&1

::Delete temp files
del title.txt >nul 2>&1
pause
exit

:stop1
echo MISSING input1.mp4
pause
exit

:stop2
echo MISSING input2.mp4
pause
exit

:stop3
echo MISSING mergechapters_ab.py
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
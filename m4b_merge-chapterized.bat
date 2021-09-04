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
::Renames output and cuesheet using album field
echo renaming output m4b and cuesheet...
rename output.m4b "%name%.m4b" >nul 2>&1
rename cuesheet.cue "%name%.cue" >nul 2>&1

::Moves m4b to folder of same name and cuesheet to backup folder
echo moving output file and backing up cuesheet...
md "%name%" >nul 2>&1
MOVE "%name%.m4b" "%name%" >nul 2>&1
MOVE "%name%.cue" "cuesheet_backup" >nul 2>&1

::If there album field is blank, then the filename instead becomes ".m4b" or ".cue"
::This will rename it to original name
rename ".m4b" "output.m4b" >nul 2>&1
rename ".cue" "cuesheetbackup.cue" >nul 2>&1

::Delete temp files
del title.txt >nul 2>&1
pause

exit
@echo off
if exist "input.mp4" (
if exist "metadata.txt" (
goto :merge
) else goto :stop
) else goto :stop

:merge
echo merging mp4 with metadata
ffmpeg -i input.mp4 -f ffmetadata -i metadata.txt -map_metadata 0 -map_chapters 1 -map 0:a:0? -c copy output.mp4
echo Check output, will delete input
pause

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
rename output.m4b "%name%.m4b" >nul 2>&1

md "%name%" >nul 2>&1
MOVE "%name%.m4b" "%name%" >nul 2>&1

::This will rename it to original name
rename ".m4b" "output.m4b" >nul 2>&1

::Delete temp files
del title.txt >nul 2>&1
del input.mp4 >nul 2>&1
del metadata.txt >nul 2>&1
exit

:stop
echo MISSING input.mp4 and/or metadata.txt
pause
exit
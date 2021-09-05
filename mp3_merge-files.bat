:fix_input
@echo off

::Remove "!" characters:
    setlocal
    for %%a in (*!*.mp3) do call :remove "%%~a"
     
::Remove "'" characters:
setlocal EnableDelayedExpansion
for %%a in ("*'*.mp3") do (
   set "fileName=%%~NXa"
   ren "%%a" "!filename:'=!"
)

::Remove "&" characters:
setlocal enabledelayedexpansion
for /f "tokens=*" %%c in ('dir /b *.mp3') do (
  set file=%%c >nul 2>&1
  ren "!file!" "!file:&=and!" >nul 2>&1
)

::This calls the filelist generator function below
call :generate_filelist > filelist.txt

:: This copies metadata from the first input file, using temporary files to get formatting correct
SetLocal EnableDelayedExpansion
set inputfix=filelist.txt
set outputfix=inputmeta1.txt
set "substr='"
(
    FOR /F "usebackq delims=" %%G IN ("%inputfix%") DO (
        set line=%%G
        echo !line:%substr%="!
    )
) > "%outputfix%"
set inputfix=inputmeta1.txt
set outputfix=inputmeta2.txt
set "substr2=file"
(
    FOR /F "usebackq delims=" %%G IN ("%inputfix%") DO (
        set line=%%G
        echo !line:%substr2%=!
    )
) > "%outputfix%"
EndLocal

set /p inputmetadata=< inputmeta2.txt
ffmpeg -i %inputmetadata% -f ffmetadata metadatatemp.txt
del inputmeta1.txt >nul 2>&1
del inputmeta2.txt >nul 2>&1

::This merges the mp3 to a single file with metadata from first input file
:merge_mp3
ffmpeg -f concat -safe 0 -i filelist.txt -i metadatatemp.txt -map 0 -map_metadata 1 -c copy input.mp3
pause

::This deletes temporary files
:cleanup
del filelist.txt >nul 2>&1
del metadatatemp.txt >nul 2>&1
exit

::This generates the filelist
:generate_filelist
@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%f in ('dir /b *.mp3') do (
  echo file '%%f'
  )
endlocal
EXIT /B 0

:remove
    set "FROM=%~1"
    set "TO=%FROM:!=%"
    ren "%FROM%" "%TO%"
    
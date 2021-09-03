@echo off
    setlocal
    for %%a in (*!*.mp3) do call :remove "%%~a"
:remove
    set "FROM=%~1" >nul 2>&1
    set "TO=%FROM:!=%" >nul 2>&1
    ren "%FROM%" "%TO%" >nul 2>&1
@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%a in ('dir /b *.mp3') do (
  set file=%%a >nul 2>&1
  ren "!file!" "!file:&=and!" >nul 2>&1
)
@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%f in ('dir /b *.mp3') do (
  set _a=%%~nf
  set _b=%%f
  set _c=!_a:'='\''!
  echo file '!_c!.mp3'
  )
endlocal

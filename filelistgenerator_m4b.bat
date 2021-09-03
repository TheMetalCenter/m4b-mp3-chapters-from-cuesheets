@echo off
    setlocal
    for %%a in (*!*.m4b) do call :remove "%%~a"
:remove
    set "FROM=%~1" >nul 2>&1
    set "TO=%FROM:!=%" >nul 2>&1
    ren "%FROM%" "%TO%" >nul 2>&1
@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%a in ('dir /b *.m4b') do (
  set file=%%a >nul 2>&1
  ren "!file!" "!file:&=and!" >nul 2>&1
)
@echo off
setlocal disabledelayedexpansion
for /f "tokens=*" %%f in ('dir /b *.m4b') do (
  set _a=%%~nf
  set _b=%%f
setlocal enabledelayedexpansion
  set _c=!_a:'='\''!
  echo file '!_c!.m4b'
  )
endlocal
@echo off
setlocal disabledelayedexpansion
for /f "tokens=*" %%f in ('dir /b *.mp3') do (
  set _a=%%~nf
  set _b=%%f
setlocal enabledelayedexpansion
  set _c=!_a:'='\''!
  echo file '!_c!.mp3'
  )
endlocal
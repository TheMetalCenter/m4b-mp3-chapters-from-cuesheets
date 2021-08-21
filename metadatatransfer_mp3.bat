@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%f in ('dir /b *.mp3') do (
  echo file '%%f'
  )
endlocal
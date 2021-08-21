@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%f in ('dir /b *.m4b') do (
  echo file '%%f'
  )
endlocal
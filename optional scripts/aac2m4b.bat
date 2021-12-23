setlocal enabledelayedexpansion
for /f "tokens=*" %%f in ('dir /b *.aac') do (
 ffmpeg -i "%%f" -c copy "%%~nf.m4b" )

EXIT /B 0


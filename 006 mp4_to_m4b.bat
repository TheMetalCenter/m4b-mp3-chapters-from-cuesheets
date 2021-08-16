@echo off

echo ---------------------
echo ---------------------
echo CONVERTING MP4 to M4B
echo ---------------------
echo ---------------------
FOR %%i IN (*.mp4) DO (
 echo converting %%i
 mp4chaps.exe -QuickTime -convert "%%i"
 rename "%%i" "%%~ni.m4b"
 echo ---------------------
)
echo ---------------------
echo  CONVERTING COMPLETE
echo ---------------------
echo ---------------------
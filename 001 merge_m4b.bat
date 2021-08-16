call direnhanced_m4b.bat > fileList.txt
ffmpeg -f concat -safe 0 -i fileList.txt -map 0 -map -0:v -c copy input.mp4
del fileList.txt
pause
call direnhanced_mp3.bat > fileList.txt
ffmpeg -f concat -safe 0 -i fileList.txt -c copy input.mp3
del fileList.txt
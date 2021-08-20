call direnhanced_mp3.bat > fileList.txt
set /p meta=< fileList.txt
echo %meta% > meta1.txt
rxrepl.exe -f meta1.txt -o meta2.txt -s "file \'" -r """
rxrepl.exe -f meta2.txt -o meta3.txt -s ".mp3'" -r ".mp3""
set /p inputmeta=< meta3.txt
ffmpeg -i %inputmeta% -f ffmetadata metadatatemp.txt
ffmpeg -f concat -safe 0 -i fileList.txt -i metadatatemp.txt -map 0 -map_metadata 1 -c copy input.mp3
::ffmpeg -f concat -safe 0 -i fileList.txt -c copy input.mp3
del fileList.txt
del metadatatemp.txt
del meta1.txt
del meta2.txt
del meta3.txt
pause
call filelistgenerator_mp3.bat > fileList.txt
call metadatatransfer_mp3.bat > inputmeta.txt
set /p meta=< inputmeta.txt
echo %meta% > meta1.txt
rxrepl.exe -f meta1.txt -o meta2.txt -s "file \'" -r """
rxrepl.exe -f meta2.txt -o meta3.txt -s ".mp3'" -r ".mp3""
set /p inputmetadata=< meta3.txt
ffmpeg -i %inputmetadata% -f ffmetadata metadatatemp.txt
ffmpeg -f concat -safe 0 -i fileList.txt -i metadatatemp.txt -map 0 -map_metadata 1 -c copy input.mp3
::ffmpeg -f concat -safe 0 -i fileList.txt -c copy input.mp3
pause
del fileList.txt
del inputmeta.txt
del metadatatemp.txt
del meta1.txt
del meta2.txt
del meta3.txt
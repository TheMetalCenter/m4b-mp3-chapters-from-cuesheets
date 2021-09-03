call filelistgenerator_mp3.bat > fileList.txt
call metadatatransfer_mp3.bat > inputmeta.txt
rxrepl.exe -f inputmeta.txt -o meta1.txt -s "file \'" -r """
rxrepl.exe -f meta1.txt -o meta2.txt -s ".mp3'" -r ".mp3""
set /p inputmetadata=< meta2.txt
ffmpeg -i %inputmetadata% -f ffmetadata metadatatemp.txt
ffmpeg -f concat -safe 0 -i fileList.txt -i metadatatemp.txt -map 0 -map_metadata 1 -c copy input.mp3
::ffmpeg -f concat -safe 0 -i fileList.txt -c copy input.mp3
del fileList.txt
del inputmeta.txt
del metadatatemp.txt
del meta1.txt
del meta2.txt
pause
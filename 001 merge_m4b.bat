call filelistgenerator_m4b.bat > fileList.txt
call metadatatransfer_m4b.bat > inputmeta.txt
set /p meta=< inputmeta.txt
echo %meta% > meta1.txt
rxrepl.exe -f meta1.txt -o meta2.txt -s "file \'" -r """
rxrepl.exe -f meta2.txt -o meta3.txt -s ".m4b'" -r ".m4b""
set /p inputmetadata=< meta3.txt
ffmpeg -i %inputmetadata% -f ffmetadata metadatatemp.txt
ffmpeg -f concat -safe 0 -i fileList.txt -i metadatatemp.txt -map 0 -map_metadata 1 -c copy input.mp4
::ffmpeg -f concat -safe 0 -i fileList.txt -c copy input.mp4
del fileList.txt
del inputmeta.txt
del metadatatemp.txt
del meta1.txt
del meta2.txt
del meta3.txt
pause
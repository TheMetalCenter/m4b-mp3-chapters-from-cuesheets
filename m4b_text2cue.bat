@echo off
if exist "list.txt" (
goto :convert2cue
) else goto :stop

:convert2cue
TextToCue.exe "list.txt"
ren list_new.cue cuesheet.cue

::The following is to add a placeholder TITLE field to prevent ffmpeg from confusing first chapter's title with the whole file's title
@ECHO OFF
:: Store the string  you want to prepend in a variable and copy the contents into a temp file
SET "text=TITLE "Title""
type cuesheet.cue > temp.txt
:: Overwrites the file with the contents in "text" variable
echo %text% > cuesheet.cue 
:: Appends the old contents & deletes the temporary file
type temp.txt >> cuesheet.cue
del temp.txt >nul 2>&1
del formatcheck.txt >nul 2>&1
del list.txt
exit

:stop
echo MISSING list.txt
pause
exit
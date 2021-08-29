@echo off
if exist "list.txt" (
goto :convert
) else goto :stop

:convert
::The following will check for improper format of export tracklist
@echo off
rxrepl.exe -f list.txt -o formatcheck.txt -s "0.\:..\:.." -r "WARNING"
findstr /m "WARNING" formatcheck.txt
if %errorlevel%==0 (echo WARNING: Unable to convert properly. Please check your exported tracklist for improper HH:MM:SS format and convert them to MM:SS)
if %errorlevel%==0 (pause)
if %errorlevel%==0 (del formatcheck.txt)
if %errorlevel%==0 (EXIT \B)
if %errorlevel%==1 (echo No warnings found, continuing...)
@echo off
if %errorlevel%==1 (del formatcheck.txt 2>NUL)

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
del temp.txt
exit

:stop
echo MISSING list.txt
pause
exit
::The following will check for improper format of export tracklist
@ECHO OFF
rxrepl.exe -f export.txt -o formatcheck.txt -s "0.\:..\:.." -r "WARNING"
findstr /m "WARNING" formatcheck.txt
if %errorlevel%==0 (echo WARNING: Unable to convert properly. Please check your exported tracklist for improper HH:MM:SS format and convert them to MM:SS)
if %errorlevel%==0 (pause)
if %errorlevel%==0 (del formatcheck.txt)
if %errorlevel%==0 (EXIT \B)
if %errorlevel%==1 (echo No warnings found, continuing...)
if %errorlevel%==1 (del formatcheck.txt)

TextToCue.exe "export.txt"

::The following is to add a placeholder TITLE field to prevent ffmpeg from confusing first chapter's title with the whole file's title
@ECHO OFF
:: Store the string  you want to prepend in a variable and copy the contents into a temp file
SET "text=TITLE "Title""
type export_new.cue > temp.txt
:: Overwrites the file with the contents in "text" variable
echo %text% > export_new.cue 
:: Appends the old contents & deletes the temporary file
type temp.txt >> export_new.cue
del temp.txt
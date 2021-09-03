echo renaming input file...
@echo off
FOR %%i IN (*.mp3) DO (
 rename "%%i" "input.mp3"
)


@echo off
if exist "list.txt" (
goto :convertlist
) else goto :stopnolist

:convertlist
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
findstr /v "^$" "list.txt" > "list2.txt"
For /F "UseBackQ Delims==" %%A In ("list2.txt") Do Set "lastline=%%A"
Echo %lastline% >> "list2.txt"

echo converting list to cue...
TextToCue.exe "list2.txt"
ren list2_new.cue cuesheet.cue

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

::Cuesheet2metadata
@echo off
if exist "cuesheet.cue" (
goto :convertcue
) else goto :stopnocue

:convertcue
echo converting cue to metadata...
::Calls cue2ffmeta ruby script to convert cuesheet.cue to ffmetadata in text file
::The file will be created even if conversion fails, will be a blank file
::Often the reason of failure is special characters

cue2ffmeta.rb cuesheet.cue > metadata.txt

head -n -4 cuesheet.cue > tmp.cue && mv tmp.cue cuesheet.cue
head -n -5 metadata.txt > tmpmeta.txt && mv tmpmeta.txt metadata.txt
del tmpmeta.txt >nul 2>&1
del tmp.cue >nul 2>&1
del list2.txt >nul 2>&1

echo merging mp3 with metadata...
call "005 merge_inputmp3_with_metadata.bat"
exit

:stopnocue
echo MISSING cuesheet.cue
pause
exit

:stopnolist
echo MISSING list.txt
pause
exit
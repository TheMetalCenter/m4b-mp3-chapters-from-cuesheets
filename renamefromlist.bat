::This is a batch file for sequential renaming of files corresponding to the lines of a txt file
::note, can make list of already existing files using "dir /b > files.txt
::drop this and files.txt into directory of files to be renamed
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

rem Load the list of new filenames
set i=0
for /F "delims=" %%a in (files.txt) do (
   set /A i+=1
   set "newname[!i!]=%%a"
)
rem Do the rename:
set i=0
for /F "delims=" %%a in ('dir /b /o:n *.mp3') do (
   set /A i+=1
   for %%i in (!i!) do ren "%%a" "!newname[%%i]!"
)
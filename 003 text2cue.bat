TextToCue.exe "export.txt"
@ECHO OFF
:: Store the string  you want to prepend in a variable
SET "text=TITLE "Title""
:: copy the contents into a temp file
type export_new.cue > temp.txt
:: Now Overwrite the file with the contents in "text" variable
echo %text% > export_new.cue 
:: Now Append the Old Contents
type temp.txt >> export_new.cue
:: Delete the temporary file
del temp.txt
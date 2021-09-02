@echo off
FOR %%i IN (*.m4b) DO (
 rename "%%i" "input.mp4"
)

FOR %%i IN (*.mp3) DO (
 rename "%%i" "input.mp3"
)

FOR %%i IN (*.cue) DO (
 rename "%%i" "cuesheet.cue"
)
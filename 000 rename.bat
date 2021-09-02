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

FOR %%i IN (*.m4a) DO (
  rename "%%i" "%%~ni.m4b"
)
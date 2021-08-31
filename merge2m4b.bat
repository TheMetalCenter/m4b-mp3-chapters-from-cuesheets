py mergechapters_ab.py input1.mp4 input2.mp4 output.mp4
rename input1.mp4 input1.m4b >nul 2>&1
rename input2.mp4 input2.m4b >nul 2>&1
call "006 mp4_to_m4b.bat"

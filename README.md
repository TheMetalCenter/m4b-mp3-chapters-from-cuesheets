### clunky-audiobook-chapterizing

WIP readme

A clunky but mostly automated way to merge audiobooks without an encoding step (remuxing only) to get either single file m4b files with quicktime/nero chapters or single file mp3s with id3v2 chapters

Full credits to creators of borrowed scripts/software (TestToCue, mergechapters.py, direnhanced, ffmpeg, mp4chaps, rubycue, cue2ffmetadata, mp3directcut)

### Creating single M4B file with embedded chapters from individual chapterized m4b files
	Alternative method: AudioBookConverter (https://github.com/yermak/AudioBookConverter) can handle these pretty well, potentially much easier, but can be buggy at times
	0. requires:
		# ffmpeg (tested using 4.4)
		# direnhanced_m4b.bat (create .txt, copy/paste below, rename .txt to .bat)
			@echo off
			setlocal enabledelayedexpansion
			for /f "tokens=*" %%f in ('dir /b *.m4b') do (
			echo file '%%f'
			)
		# merge_m4b.bat (create .txt, copy/paste below, rename .txt to .bat)
			call direnhanced_m4b.bat > fileList.txt
			ffmpeg -f concat -safe 0 -i fileList.txt -map 0 -map -0:v -c copy input.mp4
      pause
			del fileList.txt
		# mp4_to_m4b.bat + mp4chaps.exe, http://pds16.egloos.com/pds/200910/19/90/mp4_to_m4b.zip (.bat is below, .exe originates from MP4v2)
				@echo off
				echo CONVERTING MP4 to M4B
				FOR %%i IN (*.mp4) DO (
				echo converting %%i
				mp4chaps.exe -QuickTime -convert "%%i"
				rename "%%i" "%%~ni.m4b"
				)
				echo  CONVERTING COMPLETE
		# text2cue.bat
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
		# cue2metadata.bat
			cue2ffmeta.rb export_new.cue > metadata.txt
	1. Add m4b files to bin folder of ffmpeg (4.4 plus)
	2. Import tracks into mp3tag
	3. Edit "title" fields as desired (full chapter names will take longer than simple Chapter 01) and ensure "track" fields are filled with integers (can use mp3tag > tools > auto number wizard)
	4. select all, right click > export > txt_taglist 
	5. Edit txt_taglist, ensure it is this format:
		$filename(txt,utf-8)$loop(%_path%)%track%.%artist% - %title% - %duration
		$loopend()
	6. Save changes, then hit Okay and save as export.txt file in same directory, say yes to look at it and make sure none of the chapters are over an hour and thus in HH:MM:SS format, if so convert to MM:SS!!
	7. Use text2cue.bat or drag generated .txt file onto TextToCue.exe file, which generates a .cue file
			# if you manually do it, ensure the the cue has a TITLE field before next step
	8. Run merge_m4b.bat to merge m4b files to a single mp4 (not m4b!) file, type desired filename without extension
	9. Run cue2metadata.bat or open cmd in current directory and type the following (be sure to replace FILE/input/output with actual desired filenames):
		> cue2ffmeta.rb export_new.cue > metadata.txt
		> ffmpeg -i input.mp4 -i metadata.txt -map_metadata 1 -codec copy output.mp4
	## made .bat files for these commands
		cue2metadata.bat
			cue2ffmeta.rb export_new.cue > metadata.txt
		merge_inputmp3_with_metadata.bat
			ffmpeg -i input.mp3 -i metadata.txt -map_metadata 1 -codec copy output.mp3
			pause
	10. Run mp4tom4b.bat (converts fmpeg embedded chapters to proper m4b quicktime format)




### Creating singe M4B file that retains chapers from two or more m4b files with embedded chapters
	0. requires:
		# ffmpeg (tested using 4.4)
		# python (tested using 3.9.8)
		# mergechapters.py, https://gist.github.com/cliss/53136b2c69526eeed561a5517b23cefa
	1. change .m4b to .mp4
	2. open cmd in current directory:
		> py ./mergechapters.py input1.mp4 input2.mp4 output.mp4
	3. Remove extraneous video stream if needed
		> ffmpeg -i output.mp4 -map 0 -map -0:v -c copy final.mp4
	3. change .mp4 to .m4b
	4. check with ffmpeg -i *.m4b or MediaInfo to ensure chapters are present
	
	
	
### Creating single MP3 file with embedded chapters from individual chapterized mp3 files
	0. requires:
		# ffmpeg (tested using 4.4)
		# mp3tag (tested using 3.00d)
		# TextToCue.exe, https://community.mp3tag.de/t/generate-cue-file-from-tracklist/11750/13
		# ruby
		# rubycue
			Some edits to the cuesheet.rb file in the package are required to work for audiobooks! 
			See pending pull request to fix performer validation issues
			Then change index hours to 4 
			update: made more edits to complete turn off performer parsing validation
		# cue2ffmeta.rb
		# direnhanced_mp3.bat (create a text file, copy and paste below, rename .txt to .bat)
			@echo off
			setlocal enabledelayedexpansion
			for /f "tokens=*" %%f in ('dir /b *.mp3') do (
			echo file '%%f'
			)
		# merge_mp3.bat (create a text file, copy and paste below, rename .txt to .bat)
			call direnhanced_mp3.bat > fileList.txt
			ffmpeg -f concat -safe 0 -i fileList.txt -c copy input.mp3
			endlocal
			pause
		# text2cue.bat
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
		# cue2metadata.bat
			cue2ffmeta.rb export_new.cue > metadata.txt
	1. Add mp3 files to bin folder of ffmpeg (4.4 plus)
	2. Import tracks into mp3tag
	3. Edit "title" fields as desired and ensure "track" fields are filled  in format with integers (i.e. 01 or 1, not "1 of 42" etc.) (can use mp3tag > tools > auto number wizard to autofill track numbers)
	4. select all, right click > export > txt_taglist 
	5. Edit txt_taglist, ensure it is this format:
		$filename(txt,utf-8)$loop(%_path%)%track%.%artist% - %title% - %duration
		$loopend()
	6. Save changes, then hit Okay to generate .txt file, say yes to look at it and make sure none of the chapters are over an hour and thus in HH:MM:SS format, if so convert to MM:SS
	7. Use text2cue.bat or drag generated .txt file onto TextToCue.exe file, which generates a .cue file
			# if you manually do it, ensure the the cue has a TITLE field before next step
	8. Run merge_mp3.bat to merge mp3 files to a single mp3 file
	9. Run cue2metadata.bat or open cmd in current directory and type the following (be sure to replace FILE/input/output with actual desired filenames):
		> cue2ffmeta.rb FILE.cue > metadata.txt
		> ffmpeg -i input.mp3 -i metadata.txt -map_metadata 1 -codec copy output.mp3
	10. Can Double check .mp3 with:
		> ffmpeg -i output.mp3
		
		
		
		
### Creating single MP3 file with embedded chapters from randomly split mp3 files
	0. requires:
		# ffmpeg (tested using 4.4)
		# mp3directcut
		# ruby
		# rubycue
			Some edits to the cuesheet.rb file in the package are required to work better for audiobooks! 
			See pending pull request to fix performer validation issues (currently script checks for PERFORMER field on every cue chapter entry, this removes that requirement)
			Then change index hours to 4 (required for audiobooks over 16 hours)
		# cue2ffmeta.rb
		# direnhanced_mp3.bat (create .txt file, copy/paste below, rename .txt to .bat)
			@echo off
			setlocal enabledelayedexpansion
			for /f "tokens=*" %%f in ('dir /b *.mp3') do (
			echo file '%%f'
			)
		# merge_mp3.bat (create .txt file, copy/paste below, rename .txt to .bat)
			call direnhanced_mp3.bat > fileList.txt
			ffmpeg -f concat -safe 0 -i fileList.txt -c copy input.mp3
			del fileList.txt
			pause
		# cue2metadata.bat
			cue2ffmeta.rb export_new.cue > metadata.txt
	1. Add mp3 files to bin folder of ffmpeg (4.4 plus)
	2. Run merge_mp3.bat to merge mp3 files to a single mp3 file
	3. Drag merged mp3 file into mp3directcut
	4. Go to special > pause detection
		# Try -44.5 dB, 2.9 s, 10 frames
	5. Wait for it to detect chapter breaks
	6. Click close once it no longer says "stop"
	7. Check detected chapters with the >| dotted line button
		# If undercounts chapters, repeat step 4 with lower seconds
		# If it overcounts by a lot, repeat step 4 with higher seconds
		# If only a few extra, can delete by highlighting with cursor (on the upper waveform not the rectangles) and go to special > remove edit break
		# Also can cross references number of chapters with numbers of pauses using epub
	8. File > Save as .cue
	9. Open up .cue file in text editor, add PERFORMER "Author Name" as second line and change TITLE as desired
	10. Open cmd in current directory:
		> cue2ffmeta.rb FILE.cue > metadata.txt
		> ffmpeg -i input.mp3 -i metadata.txt -map_metadata 1 -codec copy output.mp3  
	11. Can Double check .mp3 with:
		> ffmpeg -i output.mp3
		
		
		
		
		
		
		
#### other useful info
quick remux can fix file errors
	> ffmpeg -i %FILENAME%.ext -c copy %FILENAME%.mp4
> ffprobe -i input.ext -show_entries format=duration -v quiet -of csv=p=0


old version of merge_m4b.bat used a custom filename, edited to only export as input.mp4
		# merge_m4b.bat (create .txt, copy/paste below, rename .txt to .bat)
			call direnhanced_m4b.bat > fileList.txt
			set /p FILENAME=Type Desired Output file name then hit ENTER to continue...
			ffmpeg -f concat -safe 0 -i fileList.txt -c copy "%FILENAME%.mp4"
			endlocal
			To export metadata from a file
> ffmpeg -i FILE.ext -f ffmetadata in.txt
or
> ffmpeg -i FILE.ext -c copy -map_metadata 0 -map_metadata:s:v 0:s:v -map_metadata:s:a 0:s:a -f ffmetadata in.txt

Troubleshooting Notes
- Had a mp3 that would lose embedded chapter information everytime metadata was edited. Noticed that last chapter started and ended at same time in cue sheet. removed that chapter and re-embedded with ffmpeg, fixed it. 
- rubycue will have parsing issues if unedited. comment out fields related to validation and performer to fix in cuesheet.rb and maybe one other file? can't remember
- rubycue by default doesn't work with audiobooks over 16 hours, change index to 4 to fix in cuesheet.rb
- tracks in mp3tag must be integers, texttocue is sensitive to format
- make sure no "-" in chapter titles when using texttocue, can add back later
- Chapter 1 is labeled Chapter 2 - make sure you have a book title field in cuesheet
- ffmpeg can't handle m4b extension, but changing to mp4 allows it to work
- Had one mp3 where adding new metadata removed the embedded chapters
	happened again, in common: both over 50 chapters and both over 91234567 digits
	cut one (Dune) down to 49 chapters but still over 91234567 and it worked
	nevermind, while it solved metadata removal issue some media players still couldn't read it, removing to 48 below the 91234567 worked
	so, can have exactly 50 chapters - no more (but have seen a mp3 file with more than 50 - investigate)

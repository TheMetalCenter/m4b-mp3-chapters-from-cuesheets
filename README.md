## m4b-mp3-chapters-from-cuesheets
- Mostly automated way to merge audiobooks (or podcasts) without quality loss from reencoding (remuxing only) to either single file m4b files with quicktime/nero chapters or single file mp3s with id3v2 chapters using cuesheets
	- [Good breakdown of different chapter types](https://github.com/Zeugma440/atldotnet/wiki/Focus-on-Chapter-metadata)

- Windows is required to run bat scripts, but python and ruby scripts should work on linux/macOS

- These merged audiobooks were meant to be used with [Prologue iOS app](https://prologue.audio/), it's awesome so check it out!

### Table of contents
1. [Features](#features)
2. [Credit](#credit)
3. [Dependencies](#dependencies)
4. [General Work Flow](#workflow)
5. [Installation](#intallation)
6. [Working Files](#workingfiles)
7. [Usage Scenarios](#scenarios)
	- [Scenario 1: Creating single M4B file with embedded chapters from individual chapterized m4b files](#scenario1)
	- [Scenario 2: Creating single MP3 file with embedded chapters from individual chapterized mp3 files](#scenario2)
	- [Scenario 3: Creating single MP3 file with embedded chapters from randomly split mp3 files](#scenario3)
	- [Scenario 4: Creating single M4B file with embedded chapters from randomly split m4b files](#scenario4)
	- [Scenario 5: Creating single M4B file that retains chapers from two m4b files with embedded chapters (can repeat if >2)](#scenario5)
	- [Scenario 6: Changing Existing Chapter Information in M4B or MP3](#scenario6)
8. [Tips & Tricks](#tips)
9. [Troubleshooting Notes](#trouble)


### Features: <a name="features"></a>
- Merge mp3 or m4b files into a single file without re-encoding
- Create cuesheets from tracklists
- Embed chapters into mp3 file as id3v2 chapters
- Embed chapters into m4b files as nero/quicktime
- Export existing chapters to cuesheet


#### Full credit to creators of borrowed scripts/software (included in repository for convenience will remove if asked): <a name="credit"></a>
- [cue2ffmeta.rb](https://gist.github.com/remko/e15c4fe26d479e134f36#file-cue2ffmeta-rb)
- [track_list_to_cue_sheet.py](https://github.com/karepker/track-list-to-cue-sheet) (adapted for compatibility)
- [mp4chaps](https://code.google.com/archive/p/mp4v2/) (originates from MP4v2)
- [mergechapters.py](https://gist.github.com/cliss/53136b2c69526eeed561a5517b23cefa) (small edit made to remove extraneous video streams from embedded covers)

#### Dependencies (Not included!) You will also need: <a name="dependencies"></a>
- [ffmpeg.exe & ffprobe.exe](https://www.gyan.dev/ffmpeg/builds/) (tested with 4.4)
- [Ruby](https://www.ruby-lang.org/en/downloads/)
- [rubycue](https://rubygems.org/gems/rubycue/versions/0.1.0) 
	- An edited cuesheet.rb is provided, which allows for 16+ hour books and turns off validation parsing, it should be placed in your-ruby-install-location\Ruby30-x64\lib\ruby\gems\3.0.0\gems\rubycue-0.1.0\lib\rubycue"
- [mp3directcut](https://mpesch3.de/) (v1.99 tested)
- [mp3tag](https://www.mp3tag.de/en/download.html)
- [python3](https://www.python.org/downloads/)

#### General Work Flow: <a name="workflow"></a>
1. Merge multiple audio files to a single mp3/mp4 file
2. Obtain and edit cuesheet to add desired chapter info
	- generated by tracklist (from mp3tag) or pause detection (by mp3directcut)
3. Convert .cue to ffmetadata then combine ffmetadata with mp3/mp4 file

### Installation <a name="installation"></a>
- Install the above required programs separately
- Place all the .bat files, cue2ffmeta.rb, list2cue.py, and mergechapters_ab.py in the bin folder of ffmpeg (the working directory)
- Ensure cuesheet.rb in your rubycue installation was replaced with the copy provided
- Go to the desired scenario below and follow its steps

#### Working files should be called: <a name="workingfiles"></a>
- input.mp3/.mp4 (from merging individual chapters or existing single file)
- cuesheet.cue (generated by list2cue.bat or from mp3directcut)
- list.txt (generated by mp3tag)
- metadata.txt (generated by ffmpeg)
- output.mp3/mp4, will auto attempt to rename with album metadata field and move to folder of same name
	- note if album field is blank it will be renamed back to output
- Temporary files are created as well, but should be deleted at the end of their associated batch process

## Usage Scenarios: <a name="scenarios"></a>

### Scenario 1: Creating single M4B file with embedded chapters from individual chapterized m4b files <a name="scenario1"></a>
	1. Add m4b files to bin folder of ffmpeg (4.4 plus)
	2. Import tracks into mp3tag
	3. Edit "title" fields as desired (full chapter names will take longer than simple Chapter 01)
		- Ensure Tracknumber fields are filled with integers (can use mp3tag > tools > auto number wizard) 
		- Ensure the Artist field is not empty
		- Ensure the Album field contains no characters not allowed in a filename (?, :, etc)
	4. Select all, right click > export > txt_taglist > Okay to create list.txt file
		- If this is first time, you will need to first edit "txt_taglist" and replace current text with below and save changes
			$filename(txt,utf-8)$loop(%_path%)%track%. "%title%" $div(%_length_seconds%,60)':'$num($mod(%_length_seconds%,60),2)
    		$loopend()
	5. Run m4b_merge-files.bat
		- will merge m4b files to a single input.mp4 file (make sure tracks are in proper order by filename)
	6. Use "m4b_list2cue.bat"
		- will generate a .cue file
	7. Run m4b_add-chapters.bat 
		- will add chapters then convert fmpeg embedded chapters to proper m4b quicktime format
		- will also attempt to rename and move output into its own folder based on album field

### Scenario 2: Creating single MP3 file with embedded chapters from individual chapterized mp3 files <a name="scenario2"></a>
	1. Add mp3 files to bin folder of ffmpeg (4.4 plus)
	2. Import tracks into mp3tag
	3. Edit "title" fields as desired (full chapter names will take longer than simple Chapter 01)
		- Ensure Tracknumber fields are filled with integers (can use mp3tag > tools > auto number wizard) 
		- Ensure the Artist field is not empty
		- Ensure the Album field contains no characters not allowed in a filename (?, :, etc)
	4. Select all, right click > export > txt_taglist > Okay to create list.txt file
		- If this is first time, you will need to first edit "txt_taglist" and replace current text with below and save changes
			$filename(txt,utf-8)$loop(%_path%)%track%. "%title%" $div(%_length_seconds%,60)':'$num($mod(%_length_seconds%,60),2)
    		$loopend()
	5. Run mp3_merge-files.bat
		- will merge mp3 files to a single input.mp3 file (ensure tracks are in proper order by filename)
	6. Use "mp3_list2cue.bat"
		- will generate a .cue file
	7. Run mp3_add-chapters.bat 
		- will add chapters in id3v2.3 format
		- will also attempt to rename and move output into its own folder based on album field
		
### Scenario 3: Creating single MP3 file with embedded chapters from randomly split mp3 files <a name="scenario3"></a>
	1. Add mp3 files to bin folder of ffmpeg (4.4 plus)
	2. Run mp3_merge-files.bat
		- will merge mp3 files to a single input.mp3 file (ensure tracks are in proper order by filename)
	3. Drag merged input.mp3 into mp3directcut
	4. Go to special > pause detection, try -44.5 dB, 2.9 s, -6 frames as a starting point
	5. Wait for it to detect chapter breaks, click close once it no longer says "stop"
	6. Check detected chapters with the >| dotted line button
		- If undercounts chapters, repeat step 4 with lower seconds or manually find chapters to add 
			- Note c creates a chapter but only if start and end point of selection are the same
			- this can be done quickly at position by hitting b, n, c
		- If it overcounts by a lot, repeat step 4 with higher seconds
		- Incorrect chapters can be deleted by selecting section, special > remove edit break
		- It is helpful to cross references number of chapters with numbers of pauses using epub
	7. File > Save as cuesheet.cue
	8. Open up .cue file in text editor and change TITLES as desired for each chapter 
	9. Run mp3_add-chapters.bat 
		- will add chapters in id3v2.3 format
		- will also attempt to rename and move output into its own folder based on album field
	
### Scenario 4: Creating single M4B file with embedded chapters from randomly split m4b files <a name="scenario4"></a>
	0. Since mp3directcut doesn't support m4b we will make a *temporary* reencode to generate the .cue
	1. Add m4b files to bin folder of ffmpeg (4.4 plus)
	2. Run m4b_merge-files.bat
		- will merge m4b files to a single input.mp4 file (ensure tracks are in proper order by filename)
		- Remove old m4b files from the directory
	3. Run m4b_reencode.bat
		- will rename the m4b file (if needed) to input.mp4 and reencode it to output.mp3
	4. Drag reencoded mp3 file into mp3directcut
	5. Go to special > pause detection, Try -44.5 dB, 2.9 s, -6 frames as starting point
	6. Wait for it to detect chapter breaks, click close once it no longer says "stop"
	7. Check detected chapters with the >| dotted line button
		- If undercounts chapters, repeat step 4 with lower seconds or manually find chapters to add 
			- Note c creates a chapter but only if start and end point of selection are the same
			- this can be done quickly at position by hitting b, n, c
		- If it overcounts by a lot, repeat step 4 with higher seconds
		- Incorrect chapters can be deleted by selecting section, special > remove edit break
		- It is helpful to cross references number of chapters with numbers of pauses using epub
	8. File > Save as cuesheet.cue
	9. Open up .cue file in text editor and change TITLES as desired for each chapter 
	10. Once satisfied with your .cue, delete reencoded output.mp4
	11. Run mp4_add-chapters.bat 
		- will add chapters then convert fmpeg embedded chapters to proper m4b quicktime format
		- will also attempt to rename and move output into its own folder based on album field
	
### Scenario 5: Creating single M4B file that retains chapers from two m4b files with embedded chapters (can repeat if >2) <a name="scenario5"></a>
	1. change the names of the two m4b files to be merged to input1.mp4 and input2.mp4
	2. Run m4b_merge-chapterized.bat, which will merge the two files
		- will combine chapters then convert fmpeg embedded chapters to proper m4b quicktime format
		- will also remove extraneous video streams caused by embedded covers
	3. Can check with ffmpeg -i *.m4b or MediaInfo to ensure chapters are present
	4. If there is more than two m4b files, repeat steps for each additional part

### Scenario 6: Changing Existing Chapter Information in M4B or MP3 <a name="scenario6"></a>
	Export to Metadata:
	1. Add the file to bin folder of ffmpeg (4.4 plus)
	2. Rename the file to export.mp3 or export.m4b
	3. Run mp3_export-metadata.bat or m4b_export-metadata.bat, respectively
	4. Open metadata.txt and edit the chapter titles as desired
	5. Rename the file to input.mp3 or input.mp4, respectively
	6. Run mp3_mergemetadata.bat or mp4_merge-metadata.bat 
		- will overwrite existing chapters with edited chapters
		- will also attempt to rename and move output into its own folder based on album field
	
	Alternatively you can export to cuesheet:
	1. Add the file to bin folder of ffmpeg (4.4 plus)
	2. Rename the file to export.mp3 or export.m4b
	3. Run mp3_export-cue.bat (or m4b)
	4. Open cuesheet.cue and edit the chapter titles as desired
	5. Rename to input.mp3 (or m4b)
	6. Run mp3_add-chapter.bat (or m4b)
		- will add chapters in respective format
		- will also attempt to rename and move output into its own folder based on album field
		
### Tips & Tricks <a name="tips"></a>
- When editing cuesheets, I recommend recording macros on Notepad++ to quickly edit chapter titles (use regular expressions to replace Track XX with Chapter XX)
- Also, you can copy and paste chapter titles from Calibre's Table Of Contents viewer if you have ebook

- renamefiles.bat is just a lazy way to rename any .mp3/mp4 and .cue (should only have one each) to input.mp3/mp4 and cuesheet.cue

- You can double check chapters with:
> ffmpeg -i file.ext OR ffprobe file.ext

- To remove existing chapters from a file:
> ffmpeg -i input.mp3 -map_metadata -1 -map_chapters -1 -c copy output2.mp3

### Troubleshooting Notes <a name="trouble"></a>
- This method may have trouble with special characters outside of utf-8, could be in the filename of the chapter files or occasionally in the chapter title field of cuesheet
	- Solution: Remove any troublesome special characters
- Error: 'chcp' is not recognized as an internal or external command, operable program or batch file.
	- Solution: chcp is an internal windows command located in system32, and should be on your PATH by default
	- However if you get this error then you need to re-add system32 to your PATH
- Some sources say that a mp3 id3v2 chapter has a character limit of 62 characters
	- I haven't encountered a limit personally
- Traditionally cuesheets are supposed to be limited to 99 chapters
	- Some media players may enforce this limitation, but cue2ffmeta can handle over 100 chapters and so can m4b/mp3 embedded chapters
- If having performer valdiation issues
	- Solution: Make sure cuesheet.rb was replaced (see above)
- If cue is malformed and the audiobook is over 16 hours
	- Solution: Make sure cuesheet.rb was replaced; otherwise cue may be improperly formatted
- Tracks in mp3tag must be integers (not fractions or phrases)
- Chapter 1 is missing and instead starts with Chapter 2 
	- This is caused by a missing TITLE field for the overall file
	- Solution: Make sure cuesheet has a TITLE field (with "") before chapter list
	- This shouldn't be a problem if the cue was generated by list2cue.py or mp3directcut, added automatically
- ffmpeg can't handle m4b extension
	- Solution: Change extension to mp4 temporarily
- Previously encountered issue where some mp3 files lost all chapter information after further editing of metadata 
	- This occurred when over there were over 50 chapters and/or 9e7 milliseconds
	- This was fixed by enforcing id3v2.3 tags
	- If issue crops up again then it may be necessary to combine the excess chapters or split into two files.
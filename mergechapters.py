# My love for Plex is not a secret. I’ve written about Plex many times before on this site. The same goes for my love of ffmpeg. As wonderful a tool as ffmpeg is, occasionally it lets me down.
# I recently ripped a two-part concert BluRay for easier playback on Plex. I did so using MakeMKV, as always. This had the advantage of preserving the chapter markers in each disc; I could easily go in using Subler and rename all the canned names, say Chapter 20, to useful names, such as While My Guitar Gently Weeps.
# My problem came in when I wanted to merge the two files. Using my normal ffmpeg incantation did not automatically carry the chapters across to the merged file.

# filelist.txt:
# file clapton1.mp4
# file clapton2.mp4

# ffmpeg -f concat -i filelist.txt -c copy clapton-joined.mp4
# What I wanted was for both sets of chapters to be preserved, with the chapters in the second file automatically offsetting themselves by the duration of the first file. Thus, if the first file is two hours, chapter one of the second file would start at two hours, not at 0 minutes.
# Perhaps there’s a ffmpeg incantation I can use to accomplish what I wanted, but if so, I couldn’t find it.
# So, I turned to something I’ve been using more and more lately: Python.
# I should state up front I’m a terrible Python developer, and am probably breaking every known coding convention and/or best practice. However, on the off chance someone is looking for a script to do exactly the above, I’ve written one.
# This script is run like this, for example:
# python3 ./mergechapters.py clapton1.mp4 clapton2.mp4 Clapton-Full.mp4
# Assuming you have two files with the chapters marked and named as you wish, the script does the following:
# Uses ffprobe to get the duration of the first file (clapton1.mp4 in our example)
# Gets all the metadata — including chapter information — from the first file
# Reads the second file’s chapter list using ffprobe (clapton2.mp4 in our example)
# Offsets each of the second file’s chapter’s timestamps by the duration found in step #1
# Appends this new chapter information to the metadata found in step #2
# Writes this combined metadata, and a file list, to disk
# Uses ffmpeg to merge the two files, and install chapters using the combined metadata found in step #5
# Cleans up after itself
# Again, there are surely easier ways to do this, but this seems to have worked with my example files. I’ll be trying it again on other ripped concert films shortly.
# You can find the script as a gist on Github.
# Though I’m not actively requesting feedback/pointers/tips on how to write better Python, if you’re bored, please feel free to fork that gist and improve it as you see fit. (I’d prefer a fork rather than comments on that gist, if you don’t mind, please.)
# However, if you happen to know of an incantation I can use directly with ffmpeg to make this all happen in one step, I’m all ears.

import datetime
import json
import os
import subprocess
import sys

#############
### USAGE ###
#############

if len(sys.argv) < 4:
    print("Usage:")
    print("{} [input file] [input file] [output file]".format(sys.argv[0]))
    print("")
    print("Both files are assumed to have their chapters")
    print("entered correctly and completely.")
    sys.exit(0)

########################
### Get Chapter List ###
########################

def getChapterList(videoFile):
    # Get chapter list as JSON
    result = subprocess.run(
        ["ffprobe", "-print_format", "json", "-show_chapters", videoFile],
        capture_output=True,
        text=True
    )
    # Load the JSON
    fileJson = json.loads(result.stdout)['chapters']
    # Map to Python object:
    # {
    #     id: 1
    #     start: 123.456
    #     end: 789.012
    # }
    chapters = list(map(
        lambda c: {
            'index': c['id'], 
            'start': float(c['start_time']), 
            'end': float(c['end_time']), 
            'title': c['tags']['title']}, 
        fileJson))
    return list(chapters)

########################
### Video 1 Duration ###
########################
 
# Get the duration of the first video
result = subprocess.run(
    ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", sys.argv[1]], 
    capture_output=True,
    text=True
)
# Get the result and trim off the trailing newline.
file1duration = float(result.stdout.rstrip())
print("{} duration is {} seconds.".format(sys.argv[1], file1duration))

############################
### Video 2 Chapter List ###
############################

def chapterMigrator(chapter):
    startTime = chapter['start']
    endTime = chapter['end']
    
    offsetStartTime = file1duration + startTime
    offsetEndTime = file1duration + endTime
    
    return {'index': chapter['index'], 'start': offsetStartTime, 'end': offsetEndTime, 'title': chapter['title']}

video2rawchapters = getChapterList(sys.argv[2])
# Migrate these chapters to be offset from the end of the first file
video2chapters = list(map(chapterMigrator, video2rawchapters))
print("{} has {} chapters.".format(sys.argv[2], len(video2chapters)))

###########################
### Get file 1 metadata ###
###########################

result = subprocess.run(
    ["ffmpeg", "-i", sys.argv[1], "-f", "ffmetadata", "-"],
    capture_output=True,
    text=True
)

metadata = result.stdout

##################################
### Append file 2 chapter list ###
##################################

metadataFileName = "metadata.txt"

# Note the timestamps are in milliseconds, and should be integers.
for c in video2chapters:
    metadata += f"""
[CHAPTER]
TIMEBASE=1/1000
START={int(c['start'] * 1000)}
END={int(c['end'] * 1000)}
title={c['title']}"""

with open(metadataFileName, "w") as metadataFile:
    metadataFile.write(metadata)

############################
### Join two video files ###
############################

fileListFileName = "files.txt"

fileList = f"""
file {sys.argv[1]}
file {sys.argv[2]}"""

with open(fileListFileName, "w") as fileListFile:
    fileListFile.write(fileList)

if os.path.exists(sys.argv[3]):
    os.remove(sys.argv[3])

print("Joining {} and {} into {}...".format(sys.argv[1], sys.argv[2], sys.argv[3]))

result = subprocess.run(
    ["ffmpeg", "-f", "concat", "-i", fileListFileName, "-i", metadataFileName, "-map_metadata", "1", "-c", "copy", sys.argv[3]],
    capture_output=False
)

print("...file {} created.".format(sys.argv[3]))

# Clean up.
os.remove(metadataFileName)
os.remove(fileListFileName)
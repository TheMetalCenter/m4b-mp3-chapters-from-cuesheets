# originated from https://gist.github.com/cliss/53136b2c69526eeed561a5517b23cefa, slight modifications made to remove video stream (usually just static cover image in case of audiobooks) in final ffmpeg command
# merges m4b files that already have chapter marks into one file with chapters from both (currently only takes two inputs at a time, repeat if more than two need to be merged)
# automatically called using merge2m4b.bat
# for manual use: py mergechapters_ab input1.mp4 input2.mp4 output.mp4

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
    ["ffmpeg", "-f", "concat", "-i", fileListFileName, "-i", metadataFileName, "-map_metadata", "1", "-map", "0", "-map", "-0:v", "-c", "copy", sys.argv[3]],
    capture_output=False
)

print("...file {} created.".format(sys.argv[3]))

# Clean up.
os.remove(metadataFileName)
os.remove(fileListFileName)
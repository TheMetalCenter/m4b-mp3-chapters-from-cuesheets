#!/usr/bin/env ruby

# Simple script to convert .cue files to FFMPEG Metadata files
# This can then be fed to ffmpeg to add chapters etc. to 
# an MP4 or MKV file, e.g.
#
#    ./cue2ffmeta.rb <FILE>.cue <TOTAL_LENGTH_IN_SECONDS> > metadata.txt
#    ffmpeg -i <INPUT> -i metadata.txt -map_metadata 1 -codec copy <OUTPUT>
#
# (the TOTAL_LENGTH_IN_SECONDS is optional)
#
# Requires 'rubycue' gem to be installed:
#
#    gem install rubycue
#

require 'rubycue'

def index_to_ms(index)
  index.minutes * 60000 + index.seconds * 1000 + (index.frames * 1000 / 75)
end

ARGV[0] or raise "Missing .cue file"
total_length = ARGV[1]

if total_length
  cuesheet = RubyCue::Cuesheet.new(File.read(ARGV[0]), total_length.to_i)
else
  cuesheet = RubyCue::Cuesheet.new(File.read(ARGV[0]))
end
cuesheet.parse!

result = [';FFMETADATA1']
result << "title=#{cuesheet.title}"
result << "artist=#{cuesheet.performer}"
cuesheet.songs.each do |song|
  result << "[CHAPTER]"
  result << "TIMEBASE=1/1000"
  result << "START=#{index_to_ms(song[:index])}"
  if song[:duration]
    result << "END=#{index_to_ms(song[:index]) + index_to_ms(song[:duration])}"
  else
    result << "END=#{index_to_ms(song[:index])}"
  end
  result << "title=#{song[:title]}"
end

puts result

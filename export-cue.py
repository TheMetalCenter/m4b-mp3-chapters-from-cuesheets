# Converts ffprobe chapter list to a cue file
# ffprobe chapter list can be generated from a media file (mp3 or m4b in this case) with embedded chapters
# Adapted from script by Kar Epker from https://github.com/karepker/track-list-to-cue-sheet

# Changes from original:
    # changed input from tracklist to ffprobe chapter list
    # Removed requirement for title and performer, giving placeholders instead
    # Added quotes to title and performer fields for proper parsing by cue2ffmeta
    # changed how index is delimited
    # rounding decimals to integers

# Note: Cuesheets do not use decimals. ffprobe will export milliseconds as decimals, which are round to nearest second. May result in slight offset

# Usage: 
# ffprobe -print_format compact=print_section=0:nokey=1:escape=csv -show_chapters "export.m4b" > metadata_chapters.txt
# py export-cue.py metadata_chapters.txt --audio-file="export.m4b" --output-file="cuesheet.cue"

import argparse
import csv
import datetime
import logging
import os
import sys

performer = "placeholder"
title = "placeholder"

def parse_track_string(track, name_index, time_index_start, time_index_end):
    """Parses a track string and returns the name and time.

    Args:
        track: A csv row read in.
        name_index: The index in the csv row that contains the track name.
        time_index: The index in the csv row that contains the track's elapsed
                    time.
    Raises: A ValueError if there are not enough entries in the row.
    Returns: The name of the track and its duration as a timedelta.
    """

    name = track[name_index]
    time_string_start = track[time_index_start]
    time_string_end = track[time_index_end]

    logger = logging.getLogger(__name__)
    logger.debug('Got name %s and time %s.', name, time_string_start, time_string_end)

    # Read the time portion of the string
    total_seconds = 0
    time_new_float = float(time_string_end) - float(time_string_start)
    time_new_int = int(round(float(time_new_float)))
    try:
        total_seconds = time_new_int
    except ValueError:
        raise ValueError(
            'Skipping track {} with unparseable time {}.'.format(track,
                                                                 time_string))

    logger.debug('Parsed %d seconds for track "%s".', total_seconds, track)

    return name, datetime.timedelta(seconds=total_seconds)

def create_cue_sheet(names, performers, track_times,
                     start_time=datetime.timedelta(seconds=0)):
    """Yields the next cue sheet entry given the track names, times.

    Args:
        names: List of track names.
        track_times: List of timdeltas containing the track times.
        performers: List of performers to associate with each cue entry.
        start_time: The initial time to start the first track at.

    The lengths of names and track times should be the same.
    """
    accumulated_time = start_time

    for time_new_int, (name, performer, track_time) in enumerate(
            zip(names, performers, track_times)):
        minutes = int(accumulated_time.total_seconds() / 60)
        seconds = int(accumulated_time.total_seconds() % 60)

        cue_sheet_entry = '''  TRACK {:02} AUDIO
    TITLE "{}"
    PERFORMER "{}"
    INDEX 01 {:02d}:{:02d}:00'''.format(time_new_int, name, performer, minutes,
                                        seconds)
        accumulated_time += track_time
        yield cue_sheet_entry


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Creates a cue sheet given '
                                     'a track list.')
    parser.add_argument('track_list', nargs='?', type=argparse.FileType('r'),
            default=sys.stdin, help='File to segment (default standard input).')
    parser.add_argument('--name-index', dest='name_index', default=6, type=int,
                        help='The index of the column in the track list '
                        'containing the track name.')
    parser.add_argument('--time-index-start', dest='time_index_start', default=3, type=float,
                        help='The index of the column in the track list '
                        'containing the track\'s elapsed time.')
    parser.add_argument('--time-index-end', dest='time_index_end', default=5, type=float,
						help='The index of the column in the track list '
                        'containing the track\'s elapsed time.')

    parser.add_argument('--start-seconds', dest='start_seconds', type=int,
                        default=0, help='Start time of the first track in '
                        'seconds.')
    parser.add_argument('--audio-file', dest='audio_file', required=True,
                        type=argparse.FileType('r'),
                        help='The audio file corresponding to cue sheet this '
                        'script will generate. This file will be used to infer '
                        'its name for the cue sheet FILE attribute.')
    parser.add_argument('--output-file', dest='output_file', default=sys.stdout,
                        type=argparse.FileType('w'),
                        help='The location to print the output cue file. '
                        'By default, stdout.')
    parser.add_argument('--debug', dest='log_level', default=logging.WARNING,
                        action='store_const', const=logging.DEBUG,
                        help='Print debug log statements.')
    args = parser.parse_args()
    logging.basicConfig(stream=sys.stderr, level=args.log_level)
    logger = logging.getLogger(__name__)

    start = datetime.timedelta(seconds=args.start_seconds)

    track_times = []
    names = []
    performers = []
    for track in csv.reader(args.track_list, delimiter='|'):
        try:
            name, track_time = parse_track_string(track, args.name_index, args.time_index_start, args.time_index_end)
            names.append(name)
            performers.append(performer)
            track_times.append(track_time)
        except ValueError as v:
           logger.error(v)

    output_file = args.output_file

    output_file.writelines('PERFORMER "{}"\n'.format(performer))

    output_file.writelines('TITLE "{}"\n'.format(title))

    audio_file_name = os.path.basename(args.audio_file.name)
    audio_file_extension = os.path.splitext(args.audio_file.name)[1][1:].upper()
    output_file.writelines('FILE "{}" {}\n'.format(audio_file_name,
                                                 audio_file_extension))

    output_file.writelines(
        '{}\n'.format(cue_entry) for cue_entry in create_cue_sheet(
                names, performers, track_times, start))
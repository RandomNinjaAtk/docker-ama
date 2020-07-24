#!/usr/bin/env python3
import os
import argparse
from mutagen.mp4 import MP4, MP4Cover

parser = argparse.ArgumentParser(description='Optional app description')
# Argument
parser.add_argument('--file', help='A required integer positional argument')
parser.add_argument('--songtitle', help='A required integer positional argument')
parser.add_argument('--songalbum', help='A required integer positional argument')
parser.add_argument('--songartist', help='A required integer positional argument')
parser.add_argument('--songartistalbum', help='A required integer positional argument')
parser.add_argument('--songbpm', help='A required integer positional argument')
parser.add_argument('--songcopyright', help='A required integer positional argument')
parser.add_argument('--songtracknumber', help='A required integer positional argument')
parser.add_argument('--songtracktotal', help='A required integer positional argument')
parser.add_argument('--songdiscnumber', help='A required integer positional argument')
parser.add_argument('--songdisctotal', help='A required integer positional argument')
parser.add_argument('--songcompilation', help='A required integer positional argument')
parser.add_argument('--songlyricrating', help='A required integer positional argument')
parser.add_argument('--songdate', help='A required integer positional argument')
parser.add_argument('--songyear', help='A required integer positional argument')
parser.add_argument('--songgenre', help='A required integer positional argument')
parser.add_argument('--songcomposer', help='A required integer positional argument')
parser.add_argument('--songisrc', help='A required integer positional argument')
parser.add_argument('--songartwork', help='A required integer positional argument')
args = parser.parse_args()

filename = args.file
bpm = int(args.songbpm)
rtng = int(args.songlyricrating)
trackn = int(args.songtracknumber)
trackt = int(args.songtracktotal)
discn = int(args.songdiscnumber)
disct = int(args.songdisctotal)
compilation = int(args.songcompilation)
copyrightext = args.songcopyright
title = args.songtitle
album = args.songalbum
artist = args.songartist
artistalbum = args.songartistalbum
date = args.songdate
year = args.songyear
genre = args.songgenre
composer = args.songcomposer
iscr = args.songisrc
picture = args.songartwork
tracknumber = (trackn, trackt)
discnumber = (discn, disct)

audio = MP4(filename)
audio["\xa9nam"] = [title]
audio["\xa9alb"] = [album]
audio["\xa9ART"] = [artist]
audio["aART"] = [artistalbum]
audio["\xa9day"] = [date]
audio["\xa9gen"] = [genre]
audio["\xa9wrt"] = [composer]
audio["rtng"] = [rtng]
audio["tmpo"] = [bpm]
audio["trkn"] = [tracknumber]
audio["disk"] = [discnumber]
audio["cprt"] = [copyrightext]
if ( compilation == 1 ):
   audio["cpil"] = [compilation]
audio["stik"] = [1]
audio["\xa9cmt"] = [iscr]
with open(picture, "rb") as f:
    audio["covr"] = [
        MP4Cover(f.read(), imageformat=MP4Cover.FORMAT_JPEG)
    ]
#audio["\xa9lyr"] = [syncedlyrics]
audio.pprint()
audio.save()

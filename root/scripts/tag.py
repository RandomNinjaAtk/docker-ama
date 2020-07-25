#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import enum
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
parser.add_argument('--songauthor', type=str, help='A required integer positional argument')
parser.add_argument('--songartists', type=str, help='A required integer positional argument')
parser.add_argument('--songengineer', type=str, help='A required integer positional argument')
parser.add_argument('--songproducer', type=str, help='A required integer positional argument')
parser.add_argument('--songmixer', type=str, help='A required integer positional argument')
parser.add_argument('--songpublisher', type=str, help='A required integer positional argument')
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
lyricist = args.songauthor
artists = args.songartists
tracknumber = (trackn, trackt)
discnumber = (discn, disct)
engineer = args.songengineer
producer = args.songproducer
mixer = args.songmixer
label = args.songpublisher


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
if lyricist:
    audio["----:com.apple.iTunes:LYRICIST"] = lyricist.encode()
if artists:
    audio["----:com.apple.iTunes:ARTISTS"] = artists.encode()
if engineer:
    audio["----:com.apple.iTunes:ENGINEER"] = engineer.encode()
if producer:
    audio["----:com.apple.iTunes:PRODUCER"] = producer.encode()
if mixer:
    audio["----:com.apple.iTunes:MIXER"] = mixer.encode()
if label:
    audio["----:com.apple.iTunes:LABEL"] = label.encode()
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

#!/usr/bin/env python3
import os
from mutagen.mp4 import MP4, MP4Cover
filename = os.environ['filem4a']
bpm = int(os.environ['songbpm'])
rtng = int(os.environ['songlyricrating'])
trackn = int(os.environ['songtracknumber'])
trackt = int(os.environ['songtracktotal'])
discn = int(os.environ['songdiscnumber'])
disct = int(os.environ['songdisctotal'])
compilation = int(os.environ['songcompilation'])
copyrightext = os.environ['songcopyright']
syncedlyrics = os.environ['songsyncedlyrics']
title = os.environ['songtitle']
album = os.environ['songalbum']
artist = os.environ['songartist']
artistalbum = os.environ['songartistalbum']
year = os.environ['songyear']
genre = os.environ['songgenre']
composer = os.environ['songcomposer']
iscr = os.environ['songisrc']
picture = os.environ['cover']
tracknumber = (trackn, trackt)
discnumber = (discn, disct)
audio = MP4(filename)
audio["\xa9nam"] = [title]
audio["\xa9alb"] = [album]
audio["\xa9ART"] = [artist]
audio["aART"] = [artistalbum]
audio["\xa9day"] = [year]
audio["\xa9gen"] = [genre]
audio["\xa9wrt"] = [composer]
audio["rtng"] = [rtng]
audio["tmpo"] = [bpm]
audio["trkn"] = [tracknumber]
audio["disk"] = [discnumber]
audio["cprt"] = [copyrightext]
audio["cpil"] = [compilation]
audio["stik"] = [1]
audio["\xa9cmt"] = [iscr]
with open(os.environ['cover'], "rb") as f:
    audio["covr"] = [
        MP4Cover(f.read(), imageformat=MP4Cover.FORMAT_JPEG)
    ]
#audio["\xa9lyr"] = [syncedlyrics]
audio.pprint()
audio.save()
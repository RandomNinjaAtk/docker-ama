file="$1"
extension="${1##*.}"
filem4a="${file%.$extension}.m4a"
filelrc="${file%.$extension}.lrc"
cover="$(dirname "$1")/folder.jpg"
if [ ! -f "$file" ]; then
    echo "ERROR: EXITING :: $file"
    exit 0
fi
tags="$(ffprobe -v quiet -print_format json -show_format "$file" | jq -r '.[] | .tags')"
if [ "$extension" = "flac" ]; then
    songtitle="$(echo "$tags" | jq -r ".TITLE")"
    songalbum="$(echo "$tags" | jq -r ".ALBUM")"
    songartist="$(echo "$tags" | jq -r ".ARTIST")"
    songartistalbum="$(echo "$tags" | jq -r ".album_artist")"
    songoriginalbpm="$(echo "$tags" | jq -r ".BPM")"
    songbpm=${songoriginalbpm%.*}
    songcopyright="$(echo "$tags" | jq -r ".PUBLISHER")"
    songtracknumber="$(echo "$tags" | jq -r ".track")"
    songtracktotal="$(echo "$tags" | jq -r ".TRACKTOTAL")"
    songdiscnumber="$(echo "$tags" | jq -r ".disc")"
    songdisctotal="$(echo "$tags" | jq -r ".DISCTOTAL")"
    songlyricrating="$(echo "$tags" | jq -r ".ITUNESADVISORY")"
    songcompilation="$(echo "$tags" | jq -r ".COMPILATION")"
    songdate="$(echo "$tags" | jq -r ".DATE")"
    songyear="${songdate:0:4}"
    songgenre="$(echo "$tags" | jq -r ".GENRE" | cut -f1 -d";")"
    songcomposer="$(echo "$tags" | jq -r ".composer" | cut -f1 -d";")"
    songisrc="ISRC: $(echo "$tags" | jq -r ".ISRC"); Source File: FLAC"
fi
if [ "$extension" = "mp3" ]; then
    ORIGFORMAT="$FORMAT"
    FORMAT="AAC"
    songtitle="$(echo "$tags" | jq -r ".title")"
    songalbum="$(echo "$tags" | jq -r ".album")"
    songartist="$(echo "$tags" | jq -r ".artist")"
    songartistalbum="$(echo "$tags" | jq -r ".album_artist")"
    songoriginalbpm="$(echo "$tags" | jq -r ".TBPM")"
    songbpm=${songoriginalbpm%.*}
    songcopyright="$(echo "$tags" | jq -r ".publisher")"
    songtracknumber="$(echo "$tags" | jq -r ".track" | cut -f1 -d "/")"
    songtracktotal="$(echo "$tags" | jq -r ".track" | cut -f2 -d "/")"
    songdiscnumber="$(echo "$tags" | jq -r ".disc" | cut -f1 -d "/")"
    songdisctotal="$(echo "$tags" | jq -r ".disc" | cut -f2 -d "/")"
    songlyricrating="$(echo "$tags" | jq -r ".ITUNESADVISORY")"
    songcompilation="$(echo "$tags" | jq -r ".compilation")"
    songdate="$(echo "$tags" | jq -r ".date")"
    songyear="${songdate:0:4}"
    songgenre="$(echo "$tags" | jq -r ".genre" | cut -f1 -d";")"
    songcomposer="$(echo "$tags" | jq -r ".composer" | cut -f1 -d";")"
    songisrc="ISRC: $(echo "$tags" | jq -r ".TSRC"); Source File: MP3"
fi

if [ -f "$filelrc" ]; then
    songsyncedlyrics="$(cat "$filelrc")"
else
    songsyncedlyrics=""
fi

if [ "$songtitle" = "null" ]; then
    songtitle=""
fi

if [ "$songalbum" = "null" ]; then
    songalbum=""
fi

if [ "$songartist" = "null" ]; then
    songartist=""
fi

if [ "$songartistalbum" = "null" ]; then
    songartistalbum=""
fi

if [ "$songbpm" = "null" ]; then
    songbpm=""
fi

if [ "$songcopyright" = "null" ]; then
    songcopyright=""
fi

if [ "$songtracknumber" = "null" ]; then
    songtracknumber=""
fi

if [ "$songtracktotal" = "null" ]; then
    songtracktotal=""
fi

if [ "$songdiscnumber" = "null" ]; then
    songdiscnumber=""
fi

if [ "$songdisctotal" = "null" ]; then
    songdisctotal=""
fi

if [ "$songcompliation" = "null" ]; then
    songcompliation=""
fi

if [ "$songyear" = "null" ]; then
    songyear=""
fi

if [ "$songgenre" = "null" ]; then
    songgenre=""
fi

if [ "$songcomposer" = "null" ]; then
    songcomposer=""
fi

if [ -f "$file" ]; then
    if [ ! -f "$filem4a" ]; then
        if [ "$FORMAT" = "ALAC" ]; then
            options="-c:a alac -movflags faststart"
        fi
        if [ "$FORMAT" = "AAC" ]; then
            options="-c:a libfdk_aac -b:a 320k -movflags faststart"
        fi
        if ffmpeg -loglevel warning -hide_banner -nostats -i "$file" -n -vn $options -metadata compilation="0" "$filem4a" < /dev/null; then
            if [ -f "$filem4a" ]; then
                echo "Encoding Succcess :: $filem4a"
            fi
        else
            echo "Error"
        fi
    fi
    if [ ! -f "$filem4a" ]; then
        echo "ERROR: EXITING :: $filem4a"
        exit 0
    fi
fi
echo "Tagging: $filem4a"
export filem4a
export songtitle
export songalbum
export songartist
export songartistalbum
export songbpm
export songcopyright
export songtracknumber
export songtracktotal
export songdiscnumber
export songdisctotal
export songlyricrating
export songsyncedlyrics
export songcompilation
export songyear
export songgenre
export songcomposer
export songisrc
export cover
python3 /config/scripts/tag.py
echo "Tagged: $filem4a"
FORMAT="$ORIGFORMAT"
if [ -f "$filem4a" ]; then
    if [ -f "$file" ]; then
        rm "$file"
    fi
fi

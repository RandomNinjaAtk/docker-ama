#!/usr/bin/with-contenv bash
export XDG_CONFIG_HOME="/xdg"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

configuration () {
	echo "######################################### CONFIGURATION VERIFICATION #########################################"
	error=0

    if [ "$AUTOSTART" = "true" ]; then
        echo "Automatic Start: ENABLED"
    else
        echo "Automatic Start: DISABLED"
    fi
    
    if [ -d "$LIBRARY" ]; then
		echo "LIBRARY Location: $LIBRARY"
        sed -i "s%/downloadfolder%$LIBRARY%g" "/xdg/deemix/config.json"
	else
		echo "ERROR: LIBRARY setting invalid, currently set to: $LIBRARY"
		echo "ERROR: LIBRARY Expected Valid Setting: /your/path/to/final/music/destination"
		error=1
	fi

    if [ ! -z "$ARL_TOKEN" ]; then
		echo "ARL Token: Configured"
        if [ -f "$XDG_CONFIG_HOME/deemix/.arl" ]; then
            rm "$XDG_CONFIG_HOME/deemix/.arl"
        fi
         if [ ! -f "$XDG_CONFIG_HOME/deemix/.arl" ]; then 
            echo -n "$ARL_TOKEN" > "$XDG_CONFIG_HOME/deemix/.arl"
        fi
	else
		echo "ERROR: ARL_TOKEN setting invalid, currently set to: $ARL_TOKEN"
		error=1
	fi

    if [ ! -z "$NumberConcurrentProcess" ]; then
        echo "Number of Concurrent Processes: $NumberConcurrentProcess"
        sed -i "s%\"queueConcurrency\": 3%\"queueConcurrency\": $NumberConcurrentProcess%g" "/xdg/deemix/config.json"
    else
		echo "ERROR: NumberConcurrentProcess setting invalid, defaulting  to: 3"
        NumberConcurrentProcess="3"
	fi

    if [ "$RELATED_ARTIST" = "true" ]; then
        echo "Related Artist: ENABLED"
    else
        echo "Related Artist: DISABLED"
    fi

    if [ "$RELATED_ARTIST_RELATED" = "true" ]; then
        echo "Related Artist Related (loop): ENABLED"
    else
        echo "Related Artist Related (loop): DISABLED"
    fi

    if [ ! -z "$FORMAT" ]; then
        echo "Download Format: $FORMAT"
        if [ "$FORMAT" = "ALAC" ]; then
            dlquality="FLAC"
            options="-c:a alac -movflags faststart"
            setextension="m4a"
        elif [ "$FORMAT" = "FLAC" ]; then
            dlquality="FLAC"
            setextension="flac"
        elif [ "$FORMAT" = "OPUS" ]; then
            dlquality="FLAC"
            options="-acodec libopus -ab ${bitConversionBitratekrate}k -application audio -vbr off"
		    setextension="opus"
            echo "Download File Bitrate: $ConversionBitrate"
        elif [ "$FORMAT" = "AAC" ]; then
            dlquality="FLAC"
            options="-c:a libfdk_aac -b:a ${ConversionBitrate}k -movflags faststart"
            setextension="m4a"
            echo "Download File Bitrate: $ConversionBitrate"
        elif [ "$FORMAT" = "MP3" ]; then
            if [ "$ConversionBitrate" = "320" ]; then
                dlquality="320"
                setextension="mp3"
                echo "Download File Bitrate: $ConversionBitrate"
            elif [ "$ConversionBitrate" = "128" ]; then
                dlquality="128"
                setextension="mp3"
                echo "Download File Bitrate: $ConversionBitrate"
            else
                dlquality="FLAC"
                options="-acodec libmp3lame -ab ${ConversionBitrate}k"
                setextension="mp3"
                echo "Download File Bitrate: $ConversionBitrate"
            fi
        else
            echo "ERROR: \"$FORMAT\" Does not match a required setting, check for trailing space..."
            error=1
        fi
    else
        dlquality="FLAC"
        ConversionBitrate="320"
        FORMAT="AAC"
        echo "Download Format: $FORMAT"
        echo "Download File Bitrate: $ConversionBitrate"
    fi

    if [ ! -z "$FilePermissions" ]; then
        echo "File Permissions: $FilePermissions"
    else
        echo "ERROR: FilePermissions not set, using default..."
        FilePermissions="666"
        echo "File Permissions: $FilePermissions"
    fi

    if [ ! -z "$FolderPermissions" ]; then
        echo "Folder Permissions: $FolderPermissions"
    else
        echo "ERROR: FolderPermissions not set, using default..."
        FolderPermissions="777"
        echo "Folder Permissions: $FolderPermissions"
    fi    

    if [ "$LidarrListImport" = "true" ]; then
        echo "Lidarr List Import: ENABLED"
        wantit=$(curl -s --header "X-Api-Key:"${LidarrAPIkey} --request GET  "$LidarrUrl/api/v1/Artist/")
	    wantedtotal=$(echo "${wantit}"| jq -r '.[].sortName' | wc -l)
        MBArtistID=($(echo "${wantit}" | jq -r ".[].foreignArtistId"))
        if [ "$wantedtotal" -gt "0" ]; then
            echo "Lidarr Connection : Successful"
        else
           echo "Lidarr Connection : Error"
           echo "Verify Lidarr is online at this address: $LidarrUrl"
           echo "Verify Lidarr API Key is correct: $LidarrAPIkey"
           error=1
        fi
    else
        echo "Lidarr List Import: DISABLED"
    fi

    if [ $error = 1 ]; then
		echo "Please correct errors before attempting to run script again..."
		echo "Exiting..."
		exit 1
	fi

}

LidarrListImport () {

    for id in ${!MBArtistID[@]}; do
        artistnumber=$(( $id + 1 ))
		mbid="${MBArtistID[$id]}"
        deezerartisturlcount="$(echo "${wantit}" | jq -r ".[] | select(.foreignArtistId==\"${mbid}\") | .links | .[] | select(.name==\"deezer\") | .url" | wc -l)"
        deezerartisturl=($(echo "${wantit}" | jq -r ".[] | select(.foreignArtistId==\"${mbid}\") | .links | .[] | select(.name==\"deezer\") | .url"))
        for url in ${!deezerartisturl[@]}; do
			deezerid="${deezerartisturl[$url]}"
			lidarrdeezerid=$(echo "${deezerid}" | grep -o '[[:digit:]]*')
            if [ -f "/config/list/$lidarrdeezerid" ]; then
               rm "/config/list/$lidarrdeezerid"
            fi
            if [ ! -f "/config/list/$lidarrdeezerid-lidarr" ]; then
                echo -n "$mbid" > "/config/list/$lidarrdeezerid-lidarr"
            fi
        done
    done
}


AlbumDL () {
    chmod 0777 -R "${PathToDLClient}"
	currentpwd="$(pwd)"
    if cd "${PathToDLClient}" && python3 -m deemix -b ${dlquality} "$dlurl" && cd "${currentpwd}"; then
        echo "Downloads Complete"
    else
        echo "ERROR: DL CLient failed"
        exit 1
    fi
}

ArtistCache () {
    if [ ! -d "/config/temp" ]; then
        mkdir -p "/config/temp"
    fi

    if ! [ -f "/config/cache/${DeezerArtistID}-info.json" ]; then
		if curl -sL --fail "https://api.deezer.com/artist/${DeezerArtistID}" -o "/config/temp/${DeezerArtistID}-temp-info.json"; then
			jq "." "/config/temp/${DeezerArtistID}-temp-info.json" > "/config/cache/${DeezerArtistID}-info.json"
			echo "AUDIO CACHE :: Caching Artist Info..."
			rm "/config/temp/${DeezerArtistID}-temp-info.json"
		else
			echo "AUDIO CACHE :: ERROR: Cannot communicate with Deezer"
		fi
    fi

    if ! [ -f "/config/cache/${DeezerArtistID}-related.json" ]; then
		if curl -sL --fail "https://api.deezer.com/artist/${DeezerArtistID}/related" -o "/config/temp/${DeezerArtistID}-temp-related.json"; then
			jq "." "/config/temp/${DeezerArtistID}-temp-related.json" > "/config/cache/${DeezerArtistID}-related.json"
			echo "AUDIO CACHE :: Caching Artis tRelated Info..."
			rm "/config/temp/${DeezerArtistID}-temp-related.json"
		else
			echo "AUDIO CACHE :: ERROR: Cannot communicate with Deezer"
		fi
    fi	
    # ArtistAlbumCache
    if [ -d "/config/temp" ]; then
        rm -rf "/config/temp"
    fi

}

ConverterTagger () {

    flacfilecount=$(find "$LIBRARY" -iname "*.flac" | wc -l)
    mp3filecount=$(find "$LIBRARY" -iname "*.mp3" | wc -l)
    echo "Number of FLAC files to process $flacfilecount"
    echo "Number of MP3 files to process $mp3filecount"


    echo "Processing Files using $NumberConcurrentProcess Threads"
    N=$NumberConcurrentProcess
    (
	    find "$LIBRARY" -iname "*.flac" -print0 | while IFS= read -r -d '' file; do
	    ((i=i%N)); ((i++==0)) && wait
	    ProcessFlacFiles "$file" &
	    done
	    wait
    )
    wait

    if [ "$FORMAT" == "ALAC" ]; then
        ORIGFORMAT="$FORMAT"
        FORMAT="AAC"
        origoptions="$options"
        options="-c:a libfdk_aac -b:a ${ConversionBitrate}k -movflags faststart"
    else
        ORIGFORMAT="$FORMAT"
        origoptions="$options"
    fi
	if [ "$FORMAT" != "MP3" ]; then
		N=$NumberConcurrentProcess
		(
			find "$LIBRARY" -iname "*.mp3" -print0 | while IFS= read -r -d '' file; do
				((i=i%N)); ((i++==0)) && wait
				ProcessMP3Files "$file" &
			done
			wait
		)
		wait
	fi
	if [ ! -z "$ORIGFORMAT" ]; then
		FORMAT="$ORIGFORMAT"
		options="$origoptions"
	fi

}


FileVerification () {

    if [ "$mp3switch" = "false" ]; then
        if find "$LIBRARY" -type f -iname "*.flac" | read; then
            flaccount="$(find "$LIBRARY" -iname "*.flac" | wc -l)"
            echo "Verifying $flaccount FLAC Files"
            find "$LIBRARY" -iname "*.flac" -print0 | while IFS= read -r -d '' file; do
                filename="$(basename "$file")"
                directory="$(basename "$(dirname "$file")")"
                if flac -t --totally-silent "$file"; then
                    echo "Verified :: $directory :: $filename"
                else
                    echo "ERROR: File verificatio failed :: $directory :: $filename :: deleting..."
                    rm "$file"
                fi
            done
            newflaccount="$(find "$LIBRARY" -iname "*.flac" | wc -l)"
        fi
    else
        flaccount="1"
        newflaccount="1"
    fi

    if find "$LIBRARY" -type f -iname "*.mp3" | read; then
       mp3count="$(find "$LIBRARY" -iname "*.mp3" | wc -l)"
        echo "Verifying $mp3count MP3 Files"
        find "$LIBRARY" -iname "*.mp3" -print0 | while IFS= read -r -d '' file; do
            filename="$(basename "$file")"
            directory="$(basename "$(dirname "$file")")"
            if mp3val -f -nb "$file" > /dev/null; then
                echo "Verified :: $directory :: $filename"
            else
                echo "ERROR: File verificatio failed :: $directory :: $filename :: deleting..."
                rm "$file"
            fi
        done
        newmp3count="$(find "$LIBRARY" -iname "*.mp3" | wc -l)"
    fi

    if [ "$newflaccount" != "$flaccount" ]; then
        fileerror="1"
    elif [ "$newmp3count" != "$mp3count" ]; then
        fileerror="1"
    else
        fileerror="0"
    fi
    
    if [ "$fileerror" == "1" ]; then
        echo "File Verification Error :: Downloading missing tracks as MP3"
        CreateLinks
        dlquality="320"
        mp3switch="true"
        AlbumDL
        RemoveLinks
        dlquality="FLAC"
        FileVerification
        fileerror="0"
    fi
}


Tag () {
    file="$1"
    extension="${1##*.}"
    filedest="${file%.$extension}.$setextension"
    filename="$(basename "$filedest")"
    directory="$(basename "$(dirname "$file")")"
    filelrc="${file%.$extension}.lrc"
    cover="$(dirname "$1")/folder.jpg"
    if [ ! -f "$file" ]; then
        echo "ERROR: EXITING :: $file"
        exit 0
    fi
    #reset tags
    songtitle="null"
    songalbum="null"
    songartist="null"
    songartistalbum="null"
    songoriginalbpm="null"
    songbpm="null"
    songcopyright="null"
    songtracknumber="null"
    songtracktotal="null"
    songdiscnumber="null"
    songdisctotal="null"
    songlyricrating="null"
    songcompilation="null"
    songdate="null"
    songyear="null"
    songgenre="null"
    songcomposer="null"
    songisrc="null"

    tags="$(ffprobe -v quiet -print_format json -show_format "$file" | jq -r '.[] | .tags')"
    if [ "$extension" = "flac" ]; then
        songtitle="$(echo "$tags" | jq -r ".TITLE")"
        songalbum="$(echo "$tags" | jq -r ".ALBUM")"
        songartist="$(echo "$tags" | jq -r ".ARTIST")"
        songartistalbum="$(echo "$tags" | jq -r ".album_artist")"
        songoriginalbpm="$(echo "$tags" | jq -r ".BPM")"
        songbpm=${songoriginalbpm%.*}
        songcopyright="$(echo "$tags" | jq -r ".COPYRIGHT")"
        songpublisher="$(echo "$tags" | jq -r ".PUBLISHER")"
        songtracknumber="$(echo "$tags" | jq -r ".track")"
        songtracktotal="$(echo "$tags" | jq -r ".TRACKTOTAL")"
        songdiscnumber="$(echo "$tags" | jq -r ".disc")"
        songdisctotal="$(echo "$tags" | jq -r ".DISCTOTAL")"
        songlyricrating="$(echo "$tags" | jq -r ".ITUNESADVISORY")"
        songcompilation="$(echo "$tags" | jq -r ".COMPILATION")"
        songdate="$(echo "$tags" | jq -r ".DATE")"
        songyear="${songdate:0:4}"
        songgenre="$(echo "$tags" | jq -r ".GENRE" | cut -f1 -d";")"
        songcomposer="$(echo "$tags" | jq -r ".composer")"
        songcomment="Source File: FLAC"
        songisrc="$(echo "$tags" | jq -r ".ISRC")"
        songauthor="$(echo "$tags" | jq -r ".author")"
        songartists="$(echo "$tags" | jq -r ".ARTISTS")"
        songengineer="$(echo "$tags" | jq -r ".engineer")"
        songproducer="$(echo "$tags" | jq -r ".producer")"
        songmixer="$(echo "$tags" | jq -r ".mixer")"
        songwriter="$(echo "$tags" | jq -r ".writer")"
        songbarcode="$(echo "$tags" | jq -r ".BARCODE")"
    fi
    if [ "$extension" = "mp3" ]; then
        songtitle="$(echo "$tags" | jq -r ".title")"
        songalbum="$(echo "$tags" | jq -r ".album")"
        songartist="$(echo "$tags" | jq -r ".artist")"
        songartistalbum="$(echo "$tags" | jq -r ".album_artist")"
        songoriginalbpm="$(echo "$tags" | jq -r ".TBPM")"
        songbpm=${songoriginalbpm%.*}
        songcopyright="$(echo "$tags" | jq -r ".copyright")"
        songpublisher="$(echo "$tags" | jq -r ".publisher")"
        songtracknumber="$(echo "$tags" | jq -r ".track" | cut -f1 -d "/")"
        songtracktotal="$(echo "$tags" | jq -r ".track" | cut -f2 -d "/")"
        songdiscnumber="$(echo "$tags" | jq -r ".disc" | cut -f1 -d "/")"
        songdisctotal="$(echo "$tags" | jq -r ".disc" | cut -f2 -d "/")"
        songlyricrating="$(echo "$tags" | jq -r ".ITUNESADVISORY")"
        songcompilation="$(echo "$tags" | jq -r ".compilation")"
        songdate="$(echo "$tags" | jq -r ".date")"
        songyear="$(echo "$tags" | jq -r ".date")"
        songgenre="$(echo "$tags" | jq -r ".genre" | cut -f1 -d";")"
        songcomposer="$(echo "$tags" | jq -r ".composer")"
        songcomment="Source File: MP3"
        songisrc="$(echo "$tags" | jq -r ".TSRC")"
        songauthor=""
        songartists="$(echo "$tags" | jq -r ".ARTISTS")"
        songengineer=""
        songproducer=""
        songmixer=""
        songbarcode="$(echo "$tags" | jq -r ".BARCODE")"
    fi

    if [ -f "$filelrc" ]; then
        songsyncedlyrics="$(cat "$filelrc")"
    else
        songsyncedlyrics=""
    fi

    if [ "$songtitle" = "null" ]; then
        songtitle=""
    fi

    if [ "$songpublisher" = "null" ]; then
        songpublisher=""
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

    if [ "$songlyricrating" = "null" ]; then
        songlyricrating="0"
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

    if [ "$songcompilation" = "null" ]; then
        songcompilation="0"
    fi

    if [ "$songdate" = "null" ]; then
        songdate=""
    fi
    
    if [ "$songyear" = "null" ]; then
        songyear=""
    fi

    if [ "$songgenre" = "null" ]; then
        songgenre=""
    fi

    if [ "$songcomposer" = "null" ]; then
        songcomposer=""
    else
        if [ "$extension" = "mp3" ]; then
            songcomposer=${songcomposer//;/, } 
        else
            songcomposer=${songcomposert//\//, }
        fi
    fi

    if [ "$songwriter" = "null" ]; then
        songwriter=""
    fi

    if [ "$songauthor" = "null" ]; then
        songauthor="$songwriter"
    fi

    if [ "$songartists" = "null" ]; then
        songartists=""
    fi

    if [ "$songengineer" = "null" ]; then
        songengineer=""
    fi

    if [ "$songproducer" = "null" ]; then
        songproducer=""
    fi

    if [ "$songmixer" = "null" ]; then
        songmixer=""
    fi

    if [ "$songbarcode" = "null" ]; then
        songbarcode=""
    fi

    if [ "$songcomment" = "null" ]; then
        songcomment=""
    fi
    
    if [ -f "$file" ]; then
        if [ ! -f "$filedest" ]; then
            if ffmpeg -loglevel warning -hide_banner -nostats -i "$file" -n -vn $options "$filedest" < /dev/null; then
                if [ -f "$filedest" ]; then
                    echo "Encoding Succcess :: $FORMAT :: $directory :: $filename"
                fi
            else
                echo "Error"
            fi
        fi
        if [ ! -f "$filedest" ]; then
            echo "ERROR: EXITING :: $directory :: $filename"
            exit 0
        fi
    fi
    if [ "$setextension" == "m4a" ]; then
        if [ -f "$filedest" ]; then
            echo "Tagging :: $directory :: $filename"
            python3 /config/scripts/tag.py \
                --file "$filedest" \
                --songtitle "$songtitle" \
                --songalbum "$songalbum" \
                --songartist "$songartist" \
                --songartistalbum "$songartistalbum" \
                --songbpm "$songbpm" \
                --songcopyright "$songcopyright" \
                --songtracknumber "$songtracknumber" \
                --songtracktotal "$songtracktotal" \
                --songdiscnumber "$songdiscnumber" \
                --songdisctotal "$songdisctotal" \
                --songcompilation "$songcompilation" \
                --songlyricrating "$songlyricrating" \
                --songdate "$songdate" \
                --songyear "$songyear" \
                --songgenre "$songgenre" \
                --songcomposer "$songcomposer" \
                --songisrc "$songisrc" \
                --songauthor "$songauthor" \
                --songartists "$songartists" \
                --songengineer "$songengineer" \
                --songproducer "$songproducer" \
                --songmixer "$songmixer" \
                --songpublisher "$songpublisher" \
                --songcomment "$songcomment" \
                --songbarcode "$songbarcode" \
                --songartwork "$cover"
            echo "Tagged :: $directory :: $filename"
        fi
    fi
    if [ -f "$filedest" ]; then
        if [ -f "$file" ]; then
            rm "$file"
            echo "Deleted :: $directory :: $filename"
        fi
    fi

}

ProcessFlacFiles () {

    if [ ! -f "${file%.flac}.$setextension" ]; then
        Tag "$file"
    fi
    if [ ! -f "${file%.flac}.$setextension" ]; then
        echo "Failed Encoding and Tagging: $file"
    fi
   
}

ProcessMP3Files () {

    if [ ! -f "${file%.mp3}.$setextension" ]; then
        Tag "$file"
    fi
    if [ ! -f "${file%.mp3}.$setextension" ]; then
        echo "Failed Encoding and Tagging: $file"
    fi
   
}

ArtistAlbumCache () {
    if [ ! -f "/config/cache/$DeezerArtistID-checked" ]; then
		if [ ! -f "/config/cache/$DeezerArtistID-album.json" ]; then
			DeezerArtistAlbumList=$(curl -s "https://api.deezer.com/artist/${DeezerArtistID}/albums&limit=1000")
			if [ -z "$DeezerArtistAlbumList" ]; then
				echo "AUDIO CACHE :: ERROR: Unable to retrieve albums from Deezer"										
			fi
		fi				
	else
		DeezerArtistAlbumList=$(curl -s "https://api.deezer.com/artist/${DeezerArtistID}/albums&limit=1000")
		newalbumlist="$(echo "${DeezerArtistAlbumList}" | jq ".data | .[].id" | wc -l)"
		if [ -z "$DeezerArtistAlbumList" ] || [ -z "${newalbumlist}" ]; then
			echo "AUDIO CACHE :: $LidArtistNameCap :: ERROR: Unable to retrieve albums from Deezer"										
		fi
	fi

    if [ ! -f "/config/cache/$DeezerArtistID-checked" ]; then
        DeezerArtistAlbumListID=($(echo "${DeezerArtistAlbumList}" | jq ".data | .[].id"))
        DeezerArtistName=($(echo "${DeezerArtistAlbumList}" | jq ".data | .[].id"))
        for id in ${!DeezerArtistAlbumListID[@]}; do
            albumid="${DeezerArtistAlbumListID[$id]}"
            if curl -sL --fail "https://api.deezer.com/album/${albumid}" -o "/config/temp/${albumid}-temp-album.json"; then
                sleep 0.5
                albumtitle="$(cat "/config/temp/${albumid}-temp-album.json" | jq ".title")"
                actualtracktotal=$(cat "/config/temp/${albumid}-temp-album.json" | jq -r ".tracks.data | .[] | .id" | wc -l)
                sanatizedalbumtitle="$(echo "$albumtitle" | sed -e 's/[^[:alnum:]\ ]//g' -e 's/[[:space:]]\+/-/g' -e 's/[\\/:\*\?"<>\|\x01-\x1F\x7F]//g' -e 's/bash /config/scripts\L&/g')"
                jq ". + {\"sanatized_album_name\": \"$sanatizedalbumtitle\"} + {\"actualtracktotal\": $actualtracktotal}" "/config/temp/${albumid}-temp-album.json" > "/config/temp/${albumid}-album.json"
                rm "/config/temp/${albumid}-temp-album.json"
                sleep 0.1
            else
                echo "AUDIO CACHE :: $LidArtistNameCap :: Error getting album information"
            fi				
        done
        jq -s '.' /config/temp/*-album.json > "/config/cache/$DeezerArtistID-albumlist.json"
    	touch "/config/cache/$DeezerArtistID-checked"
    fi
}

CreateLinks () {
    echo "Creating symlinks to prevent duplicates"
    # folder="$(find "$LIBRARY" -iname "*($DeezerArtistID)" -type d)"
    find "$LIBRARY" -iname "*.m4a" -type f -exec bash -c '
        for file do
            flaclink="${file%.m4a}.flac"
            mp3link="${file%.m4a}.mp3"
            ln -s "$file" "$flaclink"
            ln -s "$file" "$mp3link"
        done' bash {} + &> /dev/null
    find "$LIBRARY" -iname "*.opus" -type f -exec bash -c '
        for file do
            flaclink="${file%.opus}.flac"
            mp3link="${file%.opus}.mp3"
            ln -s "$file" "$flaclink"
            ln -s "$file" "$mp3link"
        done' bash {} + &> /dev/null
    find "$LIBRARY" -iname "*.flac" -type f -exec bash -c '
        for file do
            mp3link="${file%.flac}.mp3"
            ln -s "$file" "$mp3link"
        done' bash {} + &> /dev/null
    find "$LIBRARY" -iname "*.mp3" -type f -exec bash -c '
        for file do
            flaclink="${file%.mp3}.flac"
            ln -s "$file" "$flaclink"
        done' bash {} + &> /dev/null
}

RemoveLinks () {
    echo "Removing duplicate symlinks Links"
    # folder="$(find "$LIBRARY" -iname "*($DeezerArtistID)" -type d)"
    find "$LIBRARY" -iname "*.m4a" -type f -exec bash -c '
        for file do
            flaclink="${file%.m4a}.flac"
            mp3link="${file%.m4a}.mp3"
            unlink "$flaclink"
            unlink "$mp3link"
        done' bash {} + &> /dev/null
    find "$LIBRARY" -iname "*.opus" -type f -exec bash -c '
        for file do
            flaclink="${file%.opus}.flac"
            mp3link="${file%.opus}.mp3"
            unlink "$flaclink"
            unlink "$mp3link"
        done' bash {} + &> /dev/null
    find "$LIBRARY" -iname "*.flac" -type f -exec bash -c '
        for file do
            mp3link="${file%.flac}.mp3"
            unlink "$mp3link"
        done' bash {} + &> /dev/null
    find "$LIBRARY" -iname "*.mp3" -type f -exec bash -c '
        for file do
            flaclink="${file%.mp3}.flac"
            unlink "$flaclink"
        done' bash {} + &> /dev/null
}

ProcessArtistList () {
    for id in ${!list[@]}; do
        artistnumber=$(( $id + 1 ))
        artistid="${list[$id]}"
        DeezerArtistID="$artistid"
        echo "$artistnumber :: $artistid"
        ProcessArtist
    done
}

Permissions () {

    find "$LIBRARY" -type f -exec chmod $FilePermissions "{}" + &> /dev/null
    find "$LIBRARY" -type f -exec chmod chown abc:abc "{}" + &> /dev/null
    find "$LIBRARY" -type d -exec chmod $FolderPermissions "{}" + &> /dev/null
    find "$LIBRARY" -type d -exec chmod chown -R abc:abc "{}" + &> /dev/null

}

ProcessArtist () {
    DeezerArtistID="$artistid"
    dlurl="https://www.deezer.com/en/artist/${DeezerArtistID}"
    ArtistCache
    amacomplete="$(cat "/config/cache/${DeezerArtistID}-info.json" | jq -r ".ama")"
    if [ "$amacomplete" = "true" ]; then
        echo "ARCHIVING :: $DeezerArtistID :: Already archived..."
    else
        mp3switch="false"
        CreateLinks
        AlbumDL
        RemoveLinks
        FileVerification
            
        if [[ "$FORMAT" == "AAC" || "$FORMAT" = "OPUS" || "$FORMAT" = "ALAC" ]]; then
            ConverterTagger
        elif [ "$FORMAT" == "MP3" ]; then
            if [ "$ConversionBitrate" == "320" ]; then
                sleep 0.01
            elif [ "$ConversionBitrate" == "128" ]; then
                sleep 0.01
            else
                ConverterTagger
                sleep 60
            fi
        fi
        Permissions
        if [ -f "/config/cache/${DeezerArtistID}-info.json" ]; then
            echo "ARTIST CACHE :: Updating with successful archive information..."
            mv "/config/cache/${DeezerArtistID}-info.json" "/config/cache/${DeezerArtistID}-temp-info.json"
            jq ". + {\"ama\": \"true\"}" "/config/cache/${DeezerArtistID}-temp-info.json" > "/config/cache/${DeezerArtistID}-info.json"
            rm "/config/cache/${DeezerArtistID}-temp-info.json"
        fi

    fi
}

ProcessArtistRelated () {
    if  [ "$RELATED_ARTIST_RELATED" = "true" ]; then
        list=($(ls /config/list | cut -f2 -d "/" | cut -f1 -d "-" | sort -u))
    else
        list=($(ls /config/list -I "*-related" | cut -f2 -d "/" | cut -f1 -d "-" | sort -u))
    fi
    for id in ${!list[@]}; do
        artistnumber=$(( $id + 1 ))
        artistid="${list[$id]}"
        DeezerArtistID="$artistid"
        if [ -f "/config/cache/${DeezerArtistID}-related.json" ]; then
            artistrelatedfile="$(cat "/config/cache/${DeezerArtistID}-related.json")"
            artistrelatedcount="$(echo "$artistrelatedfile" | jq -r ".total")"
            if [ "$artistrelatedcount" -gt "0" ]; then
                echo  "Processing $artistrelatedcount Related artists..."
                artistrelatedidlist=($(echo "$artistrelatedfile" | jq -r ".data | .[].id"))
                for id in ${!artistrelatedidlist[@]}; do
                    relatedartistnumber=$(( $id + 1 ))
                    artistrelatedid="${artistrelatedidlist[$id]}"
                    if [ ! -f "/config/list/$artistrelatedid-related" ]; then
                        touch "/config/list/$artistrelatedid-related"
                    fi
                done
            fi
        fi
    done
}

CleanCacheCheck () {
	if [ -d "/config/cache" ]; then
		if [ -f "/config/cache/cleanup-cache-check" ]; then
			rm "/config/cache/cleanup-cache-check"
		fi
        if [ -f "/config/cache/cleanup-cache-related-check" ]; then
			rm "/config/cache/cleanup-cache-related-check"
		fi
		touch -d "168 hours ago" "/config/cache/cleanup-cache-check"
        touch -d "730 hours ago" "/config/cache/cleanup-cache-related-check"
        if find "/config/cache" -type f -iname "*-info.json" -not -newer "/config/cache/cleanup-cache-check" | read; then
			cachechecklist=($(find "/config/cache" -type f -iname "*.json" -not -newer "/config/cache/cleanup-cache-check" | cut -f2 -d "/" | cut -f1 -d "-" | sort -u))
            for id in ${!cachechecklist[@]}; do
                listprocess=$(( $id + 1 ))
                artistid="${cachechecklist[$id]}"
                onlinealbumlistcount="$(curl -s "https://api.deezer.com/artist/${artistid}" |  jq -r '.nb_album')"
                sleep 1
                cachealbumlistcount="$(cat "/config/cache/$artistid-info.json" | jq -r '.nb_album')"
                if [ "${onlinealbumlistcount}" -ne "${cachealbumlistcount}" ]; then
                    echo "Cache Artist ID: $artistid invalid... removing..."
                    rm "/config/cache/$artistid-info.json"
                else
                    echo "Cache Artist ID: $artistid still valid... updating timestamp..."
                    touch "/config/cache/$artistid-info.json"
                fi
            done
		fi
        if find "/config/cache" -type f -iname "*-related.json" -not -newer "/config/cache/cleanup-cache-related-check" | read; then
            echo "Removing Cached Artist Related Info files older than 730 Hours..."
			find "/config/cache" -type f -iname "*-related.json" -not -newer "/config/cache/cleanup-cache-related-check" -delete
        fi
	        if [ -f "/config/cache/cleanup-cache-check" ]; then
			rm "/config/cache/cleanup-cache-check"
		fi
        	if [ -f "/config/cache/cleanup-cache-related-check" ]; then
			rm "/config/cache/cleanup-cache-related-check"
		fi
	fi
}


echo "STARTING ENGINE"
processstartid="$(pgrep -f /config/scripts/start.bash)"
processdownloadid="$(pgrep -f /config/scripts/download.bash)"
echo "To kill script, use the following command:"
echo "kill -9 $processstartid"
echo "kill -9 $processdownloadid"
echo ""
echo ""
configuration
echo ""
echo ""
CleanCacheCheck
if [ "$LidarrListImport" = "true" ]; then
    LidarrListImport
fi
if ls /config/list | read; then
    if ls /config/list -I "*-related" -I "*-lidarr" | read; then
        listcount="$(ls /config/list -I "*-related" -I "*-lidarr" | wc -l)"
        listtext="$listcount Artists"
    else
        listtext="0 Artists"
    fi

    if ls /config/list/*-related 2> /dev/null | read; then
        listrelatedcount="$(ls /config/list | grep "related" | cut -f1 -d "-" | sort -u | wc -l)"
        relatedtext="$listrelatedcount Related Artists"
    else
        relatedtext="0 Related Artists"
    fi

    if ls /config/list/*-lidarr 2> /dev/null | read; then
        listlidarrcount="$(ls /config/list | grep "lidarr" | cut -f1 -d "-" | sort -u | wc -l)"
        lidarrtext="$listlidarrcount Lidarr Artists"
    else
        lidarrtext="0 Lidarr Artists"
    fi

    if [ "$RELATED_ARTIST" = "true" ]; then
        listcount="$(ls /config/list -I "*-related" -I "*-lidarr" | sort -u | wc -l)"
    else
        list=($(ls /config/list -I "*-related" | cut -f2 -d "/" | cut -f1 -d "-" | sort -u))
        listcount="$(ls /config/list -I "*-related" -I "*-lidarr" | cut -f2 -d "/" | cut -f1 -d "-" | sort -u | wc -l)"
    fi

    if [ "$LidarrListImport" = "true" ] && [ "$RELATED_ARTIST" = "true" ]; then
        list=($(ls /config/list | cut -f1 -d "-" | sort -u))
        echo "Processing :: $listtext & $lidarrtext & $relatedtext"
    elif [ "$LidarrListImport" = "true" ] && [ "$RELATED_ARTIST" = "false" ]; then
        list=($(ls /config/list -I "*-related" | cut -f1 -d "-" | sort -u))
        echo "Processing :: $listtext & $lidarrtext"
    elif [ "$LidarrListImport" = "false" ] && [ "$RELATED_ARTIST" = "true" ]; then
        echo "Processing :: $listtext & $relatedtext"
        list=($(ls /config/list -I "*-lidarr" | cut -f1 -d "-" | sort -u))
    else
        echo "Processing :: $listtext"
        list=($(ls /config/list -I "*-related" -I "*-lidarr" | cut -f1 -d "-" | sort -u))
    fi

    ProcessArtistList
    if  [ "$RELATED_ARTIST" = "true" ]; then
        ProcessArtistRelated
    fi
else
    echo "No artists to process, add artist files to list directory"
fi
echo ""
echo ""
Permissions

echo "STOPPING ENGINE"
exit 0

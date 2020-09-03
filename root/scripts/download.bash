#!/usr/bin/with-contenv bash
export XDG_CONFIG_HOME="/config/deemix/xdg"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

Configuration () {
	processstartid="$(ps -A -o pid,cmd|grep "start.bash" | grep -v grep | head -n 1 | awk '{print $1}')"
	processdownloadid="$(ps -A -o pid,cmd|grep "download.bash" | grep -v grep | head -n 1 | awk '{print $1}')"
	echo "To kill script, use the following command:"
	echo "kill -9 $processstartid"
	echo "kill -9 $processdownloadid"
	echo ""
	echo ""
	sleep 2.
	echo "############################################ $TITLE"
	echo "############################################ SCRIPT VERSION 1.1.1"
	echo "############################################ DOCKER VERSION $VERSION"
	echo "############################################ CONFIGURATION VERIFICATION"
	error=0

	if [ "$AUTOSTART" == "true" ]; then
		echo "$TITLESHORT: Script Autostart: ENABLED"
		if [ -z "$SCRIPTINTERVAL" ]; then
			echo "WARNING: $TITLESHORT Script Interval not set! Using default..."
			SCRIPTINTERVAL="15m"
		fi
		echo "$TITLESHORT: Script Interval: $SCRIPTINTERVAL"
	else
		echo "$TITLESHORT: Script Autostart: DISABLED"
	fi

	if [ -d "/downloads-ama" ]; then
			LIBRARY="/downloads-ama"
		echo "$TITLESHORT: LIBRARY Location: $LIBRARY"
	else
		echo "ERROR: Missing /downloads-ama docker volume"
		error=1
	fi

	if [ ! -z "$MODE" ]; then
		if [ "$MODE" == "artist" ]; then
			echo "$TITLESHORT: Download Mode: artist"
		fi

		if [ "$MODE" == "discography" ]; then
			echo "$TITLESHORT: Download Mode: discography"
		fi
	else
		echo "WARNING: MODE setting invalid, defaulting to: artist"
		MODE="artist"
	fi

	if [ ! -z "$ARL_TOKEN" ]; then
		echo "$TITLESHORT: ARL Token: Configured"
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

	if [ ! -z "$CONCURRENT_DOWNLOADS" ]; then
		echo "$TITLESHORT: Concurrent Downloads: $CONCURRENT_DOWNLOADS"
		sed -i "s%queueConcurrency\"] = 1%queueConcurrency\"] = $CONCURRENT_DOWNLOADS%g" "/config/scripts/dlclient.py"
	else
		echo "WARNING: CONCURRENT_DOWNLOADS setting invalid, defaulting to: 1"
		CONCURRENT_DOWNLOADS="1"
	fi

	if [ -z "$REQUIRE_QUALITY" ]; then
		echo "WARNING: REQUIRE_QUALITY setting invalid, defaulting to: false"
		REQUIRE_QUALITY="false"
	fi

	if [ "$REQUIRE_QUALITY" == "true" ]; then
		echo "$TITLESHORT: Require Quality: ENABLED"
	else
		echo "$TITLESHORT: Require Quality: DISABLED"
	fi

	if [ "$RELATED_ARTIST" = "true" ]; then
		echo "$TITLESHORT: Related Artist: ENABLED"
	else
		echo "$TITLESHORT: Related Artist: DISABLED"
	fi

	if [ "$RELATED_ARTIST_RELATED" = "true" ]; then
		echo "$TITLESHORT: Related Artist Related (loop): ENABLED"
	else
		echo "$TITLESHORT: Related Artist Related (loop): DISABLED"
	fi

	if [ -z "$IGNORE_ARTIST_WITHOUT_IMAGE" ]; then
		echo "WARNING: IGNORE_ARTIST_WITHOUT_IMAGE not set, using default..."
		IGNORE_ARTIST_WITHOUT_IMAGE="true"
	fi

	if [ "$IGNORE_ARTIST_WITHOUT_IMAGE" == "true" ]; then
		echo "$TITLESHORT: Ignore Artist Without Image: ENABLED"
	else
		echo "$TITLESHORT: Ignore Artist Without Image: DISABLED"
	fi

	if [ ! -z "$RELATED_COUNT" ]; then
		echo "$TITLESHORT: Artist Maximum Related Import Count: $RELATED_COUNT"
	else
		echo "WARNING: RELATED_COUNT not set, using default..."
		RELATED_COUNT="20"
		echo "$TITLESHORT: Artist Maximum Related Import Count: $RELATED_COUNT"
	fi

	if [ ! -z "$FAN_COUNT" ]; then
		echo "$TITLESHORT: Artist Minimum Fan Count: $FAN_COUNT"
	else
		echo "WARNING: FAN_COUNT not set, using default..."
		FAN_COUNT="1000000"
		echo "$TITLESHORT: Artist Minimum Fan Count: $FAN_COUNT"
	fi

	if [ ! -z "$FORMAT" ]; then
		echo "$TITLESHORT: Download Format: $FORMAT"
		if [ "$FORMAT" = "ALAC" ]; then
			quality="FLAC"
			options="-c:a alac -movflags faststart"
			extension="m4a"
			echo "$TITLESHORT: Download File Bitrate: lossless"
		elif [ "$FORMAT" = "FLAC" ]; then
			quality="FLAC"
			extension="flac"
			echo "$TITLESHORT: Download File Bitrate: lossless"
		elif [ "$FORMAT" = "OPUS" ]; then
			quality="FLAC"
			options="-acodec libopus -ab ${BITRATE}k -application audio -vbr off"
		    extension="opus"
			echo "$TITLESHORT: Download File Bitrate: $BITRATE"
		elif [ "$FORMAT" = "AAC" ]; then
			quality="FLAC"
			options="-c:a libfdk_aac -b:a ${BITRATE}k -movflags faststart"
			extension="m4a"
			echo "$TITLESHORT: Download File Bitrate: $BITRATE"
		elif [ "$FORMAT" = "MP3" ]; then
			if [ "$BITRATE" = "320" ]; then
				quality="320"
				extension="mp3"
				echo "$TITLESHORT: Download File Bitrate: $BITRATE"
			elif [ "$BITRATE" = "128" ]; then
				quality="128"
				extension="mp3"
				echo "$TITLESHORT: Download File Bitrate: $BITRATE"
			else
				quality="FLAC"
				options="-acodec libmp3lame -ab ${BITRATE}k"
				extension="mp3"
				echo "$TITLESHORT: Download File Bitrate: $BITRATE"
			fi
		else
			echo "ERROR: \"$FORMAT\" Does not match a required setting, check for trailing space..."
			error=1
		fi
	else
		echo "WARNING: FORMAT not set, using default..."
		echo "$TITLESHORT: Download Quality: FLAC"
		echo "$TITLESHORT: Download Bitrate: lossless"
		quality="FLAC"
	fi

	if [ ! -z "$REPLAYGAIN" ]; then
		if [ "$REPLAYGAIN" == "true" ]; then
			echo "$TITLESHORT: Replaygain Tagging: ENABLED"
		else
			echo "$TITLESHORT: Replaygain Tagging: DISABLED"
		fi
	else
		echo "WARNING: REPLAYGAIN setting invalid, defaulting to: false"
		REPLAYGAIN="false"
	fi

	if [ ! -z "$FILE_PERMISIONS" ]; then
		echo "$TITLESHORT: File Permissions: $FILE_PERMISIONS"
	else
		echo "WARNING: FILE_PERMISIONS not set, using default..."
		FILE_PERMISIONS="644"
		echo "$TITLESHORT: File Permissions: $FILE_PERMISIONS"
	fi

	if [ ! -z "$FOLDER_PERMISIONS" ]; then
		echo "$TITLESHORT: Folder Permissions: $FOLDER_PERMISIONS"
	else
		echo "WARNING: FOLDER_PERMISIONS not set, using default..."
		FOLDER_PERMISIONS="755"
		echo "$TITLESHORT: Folder Permissions: $FOLDER_PERMISIONS"
	fi

	if [ "$LIDARR_LIST_IMPORT" = "true" ]; then
		echo "$TITLESHORT: Lidarr List Import: ENABLED"
		wantit=$(curl -s --header "X-Api-Key:"${LIDARR_API_KEY} --request GET  "$LIDARR_URL/api/v1/Artist/")
		wantedtotal=$(echo "${wantit}"| jq -r '.[].sortName' | wc -l)
		MBArtistID=($(echo "${wantit}" | jq -r ".[].foreignArtistId"))
		if [ "$wantedtotal" -gt "0" ]; then
			echo "$TITLESHORT: Lidarr Connection : Successful"
		else
		   echo "ERROR: Lidarr Connection Error"
		   echo "ERROR: Verify Lidarr is online at this address: $LIDARR_URL"
		   echo "ERROR: Verify Lidarr API Key is correct: $LIDARR_LIST_IMPORT"
		   error=1
		fi
	else
		echo "$TITLESHORT: Lidarr List Import: DISABLED"
	fi

	if [ "$NOTIFYPLEX" == "true" ]; then
		echo "$TITLESHORT: Plex Library Notification: ENABLED"
		plexlibraries="$(curl -s "$PLEXURL/library/sections?X-Plex-Token=$PLEXTOKEN" | xq .)"
		if echo "$plexlibraries" | grep "/downloads-ama" | read; then
			plexlibrarykey="$(echo "$plexlibraries" | jq -r ".MediaContainer.Directory[] | select(.\"@title\"==\"$PLEXLIBRARYNAME\") | .\"@key\"" | head -n 1)"
			if [ -z "$plexlibrarykey" ]; then
				echo "ERROR: No Plex Library found named \"$PLEXLIBRARYNAME\""
				error=1
			fi
		else
			echo "ERROR: No Plex Library found containg path \"$folder\""
			echo "ERROR: Add \"$folder\" as a folder to a Plex Music Library or Disable NOTIFYPLEX"
			error=1
		fi
	else
		echo "$TITLESHORT: Plex Library Notification: DISABLED"
	fi

	if [ $error = 1 ]; then
		echo "Please correct errors before attempting to run script again..."
		echo "Exiting..."
		exit 1
	fi
	sleep 2.5
}

AddReplaygainTags () {
	if [ "$REPLAYGAIN" == "true" ]; then
		if find "$LIBRARY" -mindepth 2 -maxdepth 2 -type d -newer "/config/scripts/temp" | read; then
			OLDIFS="$IFS"
			IFS=$'\n'
			replaygainlist=($(find "$LIBRARY" -mindepth 2 -maxdepth 2 -type d -newer "/config/scripts/temp"))
			IFS="$OLDIFS"
			for id in ${!replaygainlist[@]}; do
				processid=$(( $id + 1 ))
				folder="${replaygainlist[$id]}"
				echo "$logheader :: Adding Replaygain Tags using r128gain to: $folder"
				r128gain -r -a -s -c $NumberConcurrentProcess "$folder"
			done
		fi
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
	    		if [ -f "/config/list/$lidarrdeezerid-related" ]; then
			   rm "/config/list/$lidarrdeezerid-related"
			fi
			if [ -f "/config/list/$lidarrdeezerid-complete" ]; then
			   rm "/config/list/$lidarrdeezerid-complete"
			fi
			if [ ! -f "/config/list/$lidarrdeezerid-lidarr" ]; then
				echo -n "$mbid" > "/config/list/$lidarrdeezerid-lidarr"
			fi
		done
	done
}

ArtistInfo () {
	if [ -f /config/cache/artists/$1/$1-info.json ]; then
		updatedartistdata=$(curl -sL --fail "https://api.deezer.com/artist/$1")
		newalbumcount=$(echo "$updatedartistdata" | jq -r ".nb_album")
		existingalbumcount=$(cat /config/cache/artists/$1/$1-info.json | jq -r ".nb_album")
		if [ $newalbumcount != $existingalbumcount ]; then
			rm /config/cache/artists/$1/$1-info.json
			echo "$updatedartistdata" > /config/cache/artists/$1/$1-info.json
		fi
	fi


	if [ ! -f /config/cache/artists/$1/$1-info.json ]; then
		if curl -sL --fail "https://api.deezer.com/artist/$1" -o /config/cache/$1-info.json; then
			echo "$logheader :: Downloading artist info..."
			if [ ! -d /config/cache/artists/$1 ]; then
				mkdir -p /config/cache/artists/$1
			fi
			mv /config/cache/$1-info.json /config/cache/artists/$1/$1-info.json
			touch "/config/cache/$1-cache-check"
		else
			echo "$logheader :: Error getting artist information"
		fi
	else
		echo "$logheader :: Artist info already cached!"
	fi
	artistfancount=$(cat "/config/cache/artists/$1/$1-info.json" | jq -r ".nb_fan")
	artistpictureurl=$(cat "/config/cache/artists/$1/$1-info.json" | jq -r ".picture_xl" | sed 's%1000x1000%1800x1800%g' | sed 's%80-0-0.jpg%100-0-0.jpg%g')
	blankartistmd5="ec1853a066b6f5f94b55a14fb9e34c97"
	if [ ! -f /config/cache/artists/$1/folder.jpg ]; then
		curl -s "$artistpictureurl" -o /config/cache/artists/$1/folder.jpg
	fi
	file=/config/cache/artists/$1/folder.jpg
	md5="$(md5sum "$file")"
	md5clean="$(echo "$md5" | cut -f1 -d " ")"
	if [ "$md5clean" == "$blankartistmd5" ]; then
		blankartistimage="true"
	else
		blankartistimage="false"
	fi
}

ProcessArtistList () {
	for id in ${!list[@]}; do
		artistnumber=$(( $id + 1 ))
		artistid="${list[$id]}"
		logheader="$artistnumber of $listcount :: $artistid"
		ArtistInfo "$artistid"
		artistname="$(cat "/config/cache/artists/$artistid/$artistid-info.json" | jq -r ".name")"
		artistsearch="$(jq -R -r @uri <<<"${artistname}")"
		logheader="$logheader :: $artistname"
		logheaderstart="$logheader"
		echo "$logheader :: Processing..."
		ArtistAlbumList
		if [ "$MODE" == "discography" ]; then
			ArtistDiscographyAlbumList
			albumlistdata=$(jq -s '.' /config/cache/artists/$artistid/albums/*-*.json)
			albumcount="$(echo "$albumlistdata" | jq -r "unique_by(.id) | sort_by(.release_date) | reverse | (sort_by(.explicit_lyrics) | reverse) | .[].id" | wc -l)"
			albumids=($(echo "$albumlistdata" | jq -r "unique_by(.id) | sort_by(.release_date) | reverse | (sort_by(.explicit_lyrics) | reverse) | .[].id"))
		else
			albumlistdata=$(jq -s '.' /config/cache/artists/$artistid/albums/*-official.json)
			albumcount="$(echo "$albumlistdata" | jq -r "unique_by(.id) | sort_by(.release_date) | reverse | (sort_by(.explicit_lyrics) | reverse) | .[].id" | wc -l)"
			albumids=($(echo "$albumlistdata" | jq -r "unique_by(.id) | sort_by(.release_date) | reverse | (sort_by(.explicit_lyrics) | reverse) | .[].id"))
		fi
		ProcessArtist
	done
}

ProcessArtist () {
	for id in ${!albumids[@]}; do
		albumprocess=$(( $id + 1 ))
		albumid="${albumids[$id]}"
		deezeralbumurl="https://deezer.com/album/$albumid"
		albumdata=$(echo "$albumlistdata" | jq -r ".[] | select(.id==$albumid)")
		albumartistid="$(echo "$albumdata" | jq -r ".artist.id")"
		albumartist="$(echo "$albumdata" | jq -r ".artist.name")"
		if [ "$albumartistid" != "$artistid" ]; then
			ArtistInfo "$albumartistid"
		fi
		if [ $artistid != $albumartistid ]; then
			if [ $albumartistid != 5080 ]; then
				if [ $artistfancount -lt $FAN_COUNT ]; then
					echo "$logheader :: $albumartist :: ERROR :: $artistfancount fan count lower then required minimum ($FAN_COUNT), skipping..."
					logheader="$logheaderstart"
					continue
				fi
				if [ "$IGNORE_ARTIST_WITHOUT_IMAGE" == "true" ]; then
					if find /config/list -type f -iname "$albumartistid-related" -o -iname "$albumartistid-complete" | read; then
						if [ "$blankartistimage" == true ]; then
							echo "$logheader :: $albumartist :: ERROR :: Artist image is blank, skipping..."
							logheader="$logheaderstart"
							continue
						fi
					fi
				fi
			fi
		fi
		albumtitle="$(echo "$albumdata" | jq -r ".title")"
		sanatizedalbumtitle="$(echo "$albumtitle" | sed -e "s%[^A-Za-z0-9._()'\ -]%%g" -e "s/  */ /g")"
		sanatizedalbumartist="$(echo "$albumartist" | sed -e "s%[^A-Za-z0-9._()'\ -]%%g" -e "s/  */ /g")"
		albumdate="$(echo "$albumdata" | jq -r ".release_date")"
		albumtype="$(echo "$albumdata" | jq -r ".record_type")"
		albumexplicit="$(echo "$albumdata" | jq -r ".explicit_lyrics")"

		if [ "$albumexplicit" == "true" ]; then
			lyrictype="EXPLICIT"
		else
			lyrictype="CLEAN"
		fi
		albumyear="${albumdate:0:4}"
		if [ $albumartistid == 5080 ]; then
			artistfolder="/downloads-ama/$sanatizedalbumartist"
		else
			artistfolder="/downloads-ama/$sanatizedalbumartist ($albumartistid)"
		fi
		albumfolder="$sanatizedalbumartist - ${albumtype^^} - $albumyear - $sanatizedalbumtitle ($lyrictype) ($albumid)"
		logheader="$logheader :: $albumprocess of $albumcount :: PROCESSING :: $albumartist :: ${albumtype^^} :: $albumyear :: $lyrictype :: $albumtitle"
		echo "$logheader"

		if find /config/ignore -type f -iname "$albumartistid" | read; then
			echo "$logheader :: Ignored Artist found, skipping..."
			logheader="$logheaderstart"
			continue
		fi
		if [ -d "$artistfolder" ]; then
			if find "$artistfolder" -iname "* ($albumid)" | read; then
				echo "$logheader :: Alaready Downloaded..."
				logheader="$logheaderstart"
				continue
			fi
			if [ "${albumtype^^}" != "SINGLE" ]; then
				if [ "$albumexplicit" == "false" ]; then
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (EXPLICIT) *" | read; then
						echo "$logheader :: Duplicate found..."
						logheader="$logheaderstart"
						continue
					fi
				elif find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - $albumyear - $sanatizedalbumtitle (EXPLICIT) *" | read; then
					echo "$logheader :: Duplicate found..."
					logheader="$logheaderstart"
					continue
				elif find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (CLEAN) *" | read; then
					echo "$logheader :: Duplicate clean found..."
					find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (CLEAN) *" -exec rm -rf "{}" \; &> /dev/null
					PlexNotification "$artistfolder"
				fi
			fi
			if [ "${albumtype^^}" == "SINGLE" ]; then
				if [ "$albumexplicit" == "false" ]; then
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (EXPLICIT) *" | read; then
						echo "$logheader :: Duplicate Explicit Album already downloaded, skipping..."
						logheader="$logheaderstart"
						continue
					fi
				fi
			fi
		fi
		logheader="$logheader :: DOWNLOAD"
		echo "$logheader :: Sending \"$deezeralbumurl\" to download client..."

		if [ ! -d "/downloads-ama/temp" ]; then
			mkdir -p "/downloads-ama/temp"
		else
			rm -rf /downloads-ama/temp/*
		fi

		if python3 /config/scripts/dlclient.py -b $quality "$deezeralbumurl"; then
			sleep 0.5
			if find /downloads-ama/temp -iregex ".*/.*\.\(flac\|mp3\)" | read; then
				DownloadQualityCheck
			fi
			if find /downloads-ama/temp -iregex ".*/.*\.\(flac\|mp3\)" | read; then
				find /downloads-ama/temp -type d -exec chmod $FOLDER_PERMISIONS {} \;
				find /downloads-ama/temp -type f -exec chmod $FILE_PERMISIONS {} \;
				chown -R abc:abc /downloads-ama/temp
			else
				echo "$logheader :: ERROR :: No files found"
				continue
			fi
		fi

		Conversion
		AddReplaygainTags

		file=$(find /downloads-ama/temp -iregex ".*/.*\.\(flac\|mp3\)" | head -n 1)
		if [ ! -z "$file" ]; then
			artwork="$(dirname "$file")/folder.jpg"
			if ffmpeg -y -i "$file" -c:v copy "$artwork" 2>/dev/null; then
				echo "$logheader :: Artwork Extracted"
			else
				echo "$logheader :: ERROR :: No artwork found"
			fi
		fi

		if [ ! -d "$artistfolder/$albumfolder" ]; then
			mkdir -p "$artistfolder/$albumfolder"
			chmod $FOLDER_PERMISIONS "$artistfolder/$albumfolder"
		fi
		mv /downloads-ama/temp/* "$artistfolder/$albumfolder"/
		chmod $FILE_PERMISIONS "$artistfolder/$albumfolder"/*
		chown -R abc:abc "$artistfolder/$albumfolder"
		if [ -f /config/cache/artists/$albumartistid/folder.jpg ]; then
			if [ "$blankartistimage" == "false" ]; then
				if [ ! -f "$artistfolder/folder.jpg" ]; then
					if [ $albumartistid != 5080 ]; then
						cp /config/cache/artists/$albumartistid/folder.jpg "$artistfolder/folder.jpg"
						chmod $FILE_PERMISIONS "$artistfolder/folder.jpg"
						chown -R abc:abc "$artistfolder/folder.jpg"
					fi
				fi
			fi
		fi
		PlexNotification "$artistfolder/$albumfolder"
		logheader="$logheaderstart"
	done
}

Conversion () {
	converttrackcount=$(find  /downloads-ama/temp/ -name "*.flac" | wc -l)
	if [ "${FORMAT}" != "FLAC" ]; then
		if find /downloads-ama/temp/ -name "*.flac" | read; then
			echo "$logheader :: CONVERSION :: Converting: $converttrackcount Tracks (Target Format: $FORMAT (${BITRATE}))"
			for fname in /downloads-ama/temp/*.flac; do
				filename="$(basename "${fname%.flac}")"
				if [ "${FORMAT}" == "OPUS" ]; then
					if opusenc --bitrate $BITRATE --vbr "$fname" "${fname%.flac}.temp.$extension"; then
						converterror=0
					else
						converterror=1
					fi
				else
					if ffmpeg -loglevel warning -hide_banner -nostats -i "$fname" -n -vn $options "${fname%.flac}.temp.$extension"; then
						converterror=0
					else
						converterror=1
					fi
				fi
				if [ "$converterror" == "1" ]; then
					echo "$logheader :: CONVERSION :: ERROR :: Coversion Failed: $filename, performing cleanup..."
					rm "${fname%.flac}.temp.$extension"
					continue
				elif [ -f "${fname%.flac}.temp.$extension" ]; then
					rm "$fname"
					sleep 0.1
					mv "${fname%.flac}.temp.$extension" "${fname%.flac}.$extension"
					echo "$logheader :: CONVERSION :: $filename :: Converted!"
				fi
			done
		fi
	fi
}

AddReplaygainTags () {
	if [ "$REPLAYGAIN" == "true" ]; then
		echo "$logheader :: DOWNLOAD :: Adding Replaygain Tags using r128gain"
		r128gain -r -a /downloads-ama/temp
	fi
}

ProcessArtistRelated () {
	if  [ "$RELATED_ARTIST_RELATED" = "true" ]; then
		relatedprocesslist=($(ls /config/list | cut -f2 -d "/" | cut -f1 -d "-" | sort -u))
	else
		relatedprocesslist=($(ls /config/list -I "*-related" | cut -f2 -d "/" | cut -f1 -d "-" | sort -u))
	fi
	for id in ${!relatedprocesslist[@]}; do
		artistnumber=$(( $id + 1 ))
		artistid="${relatedprocesslist[$id]}"
		DeezerArtistID="$artistid"
		if [ -f "/config/cache/${DeezerArtistID}-related.json" ]; then
			artistrelatedfile="$(cat "/config/cache/${DeezerArtistID}-related.json")"
			artistrelatedcount="$(echo "$artistrelatedfile" | jq -r ".total")"
			if [ "$artistrelatedcount" -gt "0" ]; then
				echo  "Processing Artist ID: ${DeezerArtistID} :: $artistrelatedcount Related artists..."
				artistrelatedidlist=($(echo "$artistrelatedfile" | jq ".data[] | select(.nb_fan >= $FAN_COUNT) | .id" | head -n $RELATED_COUNT))
				artistrelatedidlistcount=$(echo "$artistrelatedfile" | jq ".data[] | select(.nb_fan >= $FAN_COUNT) | .id" | head -n $RELATED_COUNT | wc -l)
				echo  "Processing Artist ID: ${DeezerArtistID} :: $artistrelatedidlistcount Related artists matching minimum fancount of $FAN_COUNT"
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

AddMissingArtists () {
	completeartistlist=($(find $LIBRARY -maxdepth 1 -mindepth 1 | grep -o '(*[[:digit:]]*)' | sed 's/(//g;s/)//g' | sort -u))
	for id in ${!completeartistlist[@]}; do
		completeprocessid=$(( $id + 1 ))
		completeartistid="${completeartistlist[$id]}"
		if ls /config/list | cut -f2 -d "/" | cut -f1 -d "-" | sort -u | grep -i "$completeartistid" | read; then
			continue
		fi
		if [ ! -f "/config/list/$completeartistid-complete" ]; then
			echo "Adding missing artistid $completeartistid"
			touch "/config/list/$completeartistid-complete"
		fi
	done
}

PlexNotification () {

	if [ "$NOTIFYPLEX" == "true" ]; then
		plexfolder="$1"
		plexfolderencoded="$(jq -R -r @uri <<<"${plexfolder}")"
		curl -s "$PLEXURL/library/sections/$plexlibrarykey/refresh?path=$plexfolderencoded&X-Plex-Token=$PLEXTOKEN"
		echo "$logheader :: Plex Scan notification sent! ($plexfolder)"
	fi
}

DownloadQualityCheck () {

	if [ "$REQUIRE_QUALITY" == "true" ]; then
		echo "$logheader :: DOWNLOAD :: Checking for unwanted files"
		if [ "$quality" == "FLAC" ]; then
			if find /downloads-ama/temp -iname "*.mp3" | read; then
				echo "$logheader :: DOWNLOAD :: Unwanted files found!"
				echo "$logheader :: DOWNLOAD :: Performing cleanup..."
				rm /downloads-ama/temp/*
			fi
		else
			if find /downloads-ama/temp -iname "*.flac" | read; then
				echo "$logheader :: DOWNLOAD :: Unwanted files found!"
				echo "$logheader :: DOWNLOAD :: Performing cleanup..."
				rm /downloads-ama/temp/*
			fi
		fi
	fi

}

ArtistAlbumList () {

	albumartistalbumcount=$(cat /config/cache/artists/$artistid/$artistid-info.json | jq -r ".nb_album")
	if [ -d /config/cache/artists/$artistid/albums ]; then
		existingalbumartistalbumcount=$(find /config/cache/artists/$artistid/albums -iname "*-official.json" | wc -l)
		if [ $albumartistalbumcount != $existingalbumartistalbumcount ]; then
			updateartistcache=true
		else
			updateartistcache=false
		fi
	fi
	if [ $updateartistcache == true ]; then
		if [ ! -d "/config/temp" ]; then
			mkdir "/config/temp"
		fi

		echo "$logheader :: Downloading Official Album List..."
		albumlist="$(curl -s "https://api.deezer.com/artist/$artistid/albums&limit=1000" | jq ".data")"
		albumcount="$(echo "$albumlist" | jq -r  ".[].id" | wc -l)"
		albumids=($(echo "$albumlist" | jq -r  ".[].id"))
		for id in ${!albumids[@]}; do
			albumprocess=$(( $id + 1 ))
			albumid="${albumids[$id]}"
			if [ ! -d /config/cache/artists/$artistid/albums ]; then
				mkdir -p /config/cache/artists/$artistid/albums
			fi
			if [ ! -f /config/cache/artists/$artistid/albums/${albumid}-official.json ]; then
				if curl -sL --fail "https://api.deezer.com/album/${albumid}" -o "/config/temp/${albumid}-official.json"; then
					echo "$logheader :: $albumprocess of $albumcount :: Downloading Album info..."
					mv /config/temp/${albumid}-official.json /config/cache/artists/$artistid/albums/${albumid}-official.json
				else
					echo "$logheader :: $albumprocess of $albumcount :: Error getting album information"
				fi
			fi
		done

		if [ -d "/config/temp" ]; then
			rm -rf "/config/temp"
		fi
	else
		albumcount=$(ls /config/cache/artists/$artistid/albums/*-official.json | wc -l)
	fi
	echo "$logheader :: $albumcount found!"
}

ArtistDiscographyAlbumList () {

	if [ $updateartistcache == true ]; then
		resultscount="$(curl -s "https://api.deezer.com/search?q=%22${artistsearch}%22&limit=1" | jq -r ".total")"
		echo "$logheader :: Searching for All Albums...."
		echo "$logheader :: $resultscount tracks found!"

		if [ ! -d "/config/temp" ]; then
			mkdir "/config/temp"
		fi

		offsetcount=$(( $resultscount / 100 ))
		for ((i=0;i<=$offsetcount;i++)); do
			if [ ! -f "recording-page-$i.json" ]; then
				if [ $i != 0 ]; then
					offset=$(( $i * 100 ))
					dlnumber=$(( $offset + 100))
				else
					offset=0
					dlnumber=$(( $offset + 100))
				fi
				page=$(( $i + 1 ))
				echo "$logheader :: Downloading page $page... ($offset - $dlnumber Results)"
				curl -s "https://api.deezer.com/search?q=%22${artistsearch}%22&limit=1000&index=$offset" -o "/config/temp/$artistid-recording-page-$i.json"
			fi
		done

		artistsearchdata=$(jq -s '.' /config/temp/*-recording-page-*.json)
		rm /config/temp/$artistid-recording-page-*.json

		albumcount=$(echo "$artistsearchdata" | jq -r  ".[].data[]| .album.id" | sort -u | wc -l)
		albumids=($(echo "$artistsearchdata" | jq -r  ".[].data[]| .album.id" | sort -u))

		echo "$logheader :: Finding unique albums"
		echo "$logheader :: $albumcount albums found!"

		for id in ${!albumids[@]}; do
			currentprocess=$(( $id + 1 ))
			albumid="${albumids[$id]}"
			if [ ! -f /config/cache/artists/$artistid/albums/${albumid}-official.json ]; then
				if [ ! -f /config/cache/artists/$artistid/albums/${albumid}-discography.json ]; then
					if curl -sL --fail "https://api.deezer.com/album/${albumid}" -o "/config/temp/${albumid}-discography.json"; then
						echo "$logheader :: $currentprocess of $albumcount :: Downloading Album info..."
						mv /config/temp/${albumid}-discography.json /config/cache/artists/$artistid/albums/${albumid}-discography.json
					else
						echo "$logheader :: $currentprocess of $albumcount :: Error getting album information"
					fi
				else
					echo "$logheader :: $currentprocess of $albumcount :: Album info already downloaded"
				fi
			else
				echo "$logheader :: $currentprocess of $albumcount :: Album info already downloaded"
			fi
		done

		if [ -d "/config/temp" ]; then
			rm -rf "/config/temp"
		fi

	else
		albumcount=$(ls /config/cache/artists/$artistid/albums/*-discography.json | wc -l)
		echo "$logheader :: Finding unique albums"
		echo "$logheader :: $albumcount found!"
	fi
}

Main () {
	Configuration
	echo "############################################ SCRIPT START"
	if [ "$LIDARR_LIST_IMPORT" = "true" ] || [ "$COMPLETE_MY_ARTISTS" = "true" ] || [ "$RELATED_ARTIST" = "true" ]; then
		echo "Adding Missing Artist ID's..."
		if [ "$LIDARR_LIST_IMPORT" = "true" ]; then
			LidarrListImport
		fi
		if [ "$COMPLETE_MY_ARTISTS" = "true" ]; then
			AddMissingArtists
		fi
		if  [ "$RELATED_ARTIST" = "true" ]; then
			ProcessArtistRelated
		fi
	fi
	if ls /config/list | read; then
		if ls /config/list -I "*-related" -I "*-lidarr" -I "*-complete" | read; then
			listcount="$(ls /config/list -I "*-related" -I "*-lidarr" -I "*-complete" | wc -l)"
			listregtext="$listcount Artists (Not realted/imported)"
		else
			listregtext="0 Artists (Not realted/imported)"
		fi

		if ls /config/list/*-related 2> /dev/null | read; then
			listrelatedcount="$(ls /config/list | grep "related" | cut -f1 -d "-" | sort -u | wc -l)"
			relatedtext="$listrelatedcount Related Artists"
			if [ "$RELATED_ARTIST" = "true" ]; then
				relatedoption=""
			else
				relatedoption=" -not -iname *-related"
			fi
		else
			relatedtext="0 Related Artists"
		fi

		if ls /config/list/*-lidarr 2> /dev/null | read; then
			listlidarrcount="$(ls /config/list | grep "lidarr" | cut -f1 -d "-" | sort -u | wc -l)"
			lidarrtext="$listlidarrcount Lidarr Artists"
			if [ "$LidarrListImport" = "true" ]; then
				lidarroption=""
			else
				lidarroption=" -not -iname *-lidarr"
			fi
		else
			lidarrtext="0 Lidarr Artists"
		fi

		if ls /config/list/*-complete 2> /dev/null | read; then
			listcompletecount="$(ls /config/list | grep "complete" | cut -f1 -d "-" | sort -u | wc -l)"
			completetext="$listcompletecount Complete Artists"
			if [ "$CompleteMyArtists" = "true" ]; then
				completeoption=""
			else
				completeoption=" -not -iname *-complete"
			fi
		else
			completetext="0 Complete Artists"
		fi

		listcount="$(find /config/list -mindepth 1${lidarroption}${relatedoption}${completeoption} | sed 's%/config/list/%%g' | cut -f1 -d "-" | sort -u | wc -l)"
		list=($(find /config/list -mindepth 1${lidarroption}${relatedoption}${completeoption} | sed 's%/config/list/%%g' | cut -f1 -d "-" | sort -u))
		echo "Finding Artist ID files"
		echo "$listcount Artists Found!"
		echo "Artist List comprised of:"
		echo "$listregtext"
		if [ "$RELATED_ARTIST" = "true" ]; then
			echo "$relatedtext"
		fi
		if [ "$LIDARR_LIST_IMPORT" = "true" ]; then
			echo "$lidarrtext"
		fi
		if [ "$COMPLETE_MY_ARTISTS" = "true" ]; then
			echo "$completetext"
		fi
		ProcessArtistList
	else
		echo "No artists to process, add artist files to list directory"
	fi
	echo "############################################ SCRIPT END"
}

Main

exit 0

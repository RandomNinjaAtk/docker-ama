#!/usr/bin/with-contenv bash
export XDG_CONFIG_HOME="/config/deemix/xdg"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

Configuration () {
	processstartid="$(ps -A -o pid,cmd|grep "start.bash" | grep -v grep | head -n 1 | awk '{print $1}')"
	processdownloadid="$(ps -A -o pid,cmd|grep "download.bash" | grep -v grep | head -n 1 | awk '{print $1}')"
	log "To kill script, use the following command:"
	log "kill -9 $processstartid"
	log "kill -9 $processdownloadid"
	log ""
	log ""
	sleep 2
	log "############################################ $TITLE"
	log "############################################ SCRIPT VERSION 1.1.35"
	log "############################################ DOCKER VERSION $VERSION"
	log "############################################ CONFIGURATION VERIFICATION"
	error=0

	if [ "$AUTOSTART" == "true" ]; then
		log "$TITLESHORT: Script Autostart: ENABLED"
		if [ -z "$SCRIPTINTERVAL" ]; then
			log "WARNING: $TITLESHORT Script Interval not set! Using default..."
			SCRIPTINTERVAL="15m"
		fi
		log "$TITLESHORT: Script Interval: $SCRIPTINTERVAL"
	else
		log "$TITLESHORT: Script Autostart: DISABLED"
	fi

	if [ -d "/downloads-ama" ]; then
			LIBRARY="/downloads-ama"
		log "$TITLESHORT: LIBRARY Location: $LIBRARY"
	else
		log "ERROR: Missing /downloads-ama docker volume"
		error=1
	fi

	if [ ! -z "$MODE" ]; then
		if [ "$MODE" == "artist" ]; then
			log "$TITLESHORT: Download Mode: artist"
		elif [ "$MODE" == "discography" ]; then
			log "$TITLESHORT: Download Mode: discography"
		else
			log "WARNING: MODE setting invalid, defaulting to: artist"
			MODE="artist"
			log "$TITLESHORT: Download Mode: artist"
		fi
	else
		log "WARNING: MODE setting invalid, defaulting to: artist"
		MODE="artist"
	fi

	if [ ! -z "$ARL_TOKEN" ]; then
		log "$TITLESHORT: ARL Token: Configured"
		if [ -f "$XDG_CONFIG_HOME/deemix/.arl" ]; then
			rm "$XDG_CONFIG_HOME/deemix/.arl"
		fi
		 if [ ! -f "$XDG_CONFIG_HOME/deemix/.arl" ]; then
			echo -n "$ARL_TOKEN" > "$XDG_CONFIG_HOME/deemix/.arl"
		fi
	else
		log "ERROR: ARL_TOKEN setting invalid, currently set to: $ARL_TOKEN"
		error=1
	fi
	
	if [ ! -z "$ALBUM_TYPE_FILTER" ]; then
		ALBUM_FILTER=true
		log "$TITLESHORT: Album Type Filter: ENABLED"
		log "$TITLESHORT: Filtering: $ALBUM_TYPE_FILTER"		
	else
		ALBUM_FILTER=false
		log "$TITLESHORT: Album Type Filter: DISABLED"
	fi
	

	if [ ! -z "$CONCURRENT_DOWNLOADS" ]; then
		log "$TITLESHORT: Concurrent Downloads: $CONCURRENT_DOWNLOADS"
		sed -i "s%queueConcurrency\"] = 1%queueConcurrency\"] = $CONCURRENT_DOWNLOADS%g" "/config/scripts/dlclient.py"
	else
		log "WARNING: CONCURRENT_DOWNLOADS setting invalid, defaulting to: 1"
		CONCURRENT_DOWNLOADS="1"
	fi

	if [ -z "$REQUIRE_QUALITY" ]; then
		log "WARNING: REQUIRE_QUALITY setting invalid, defaulting to: false"
		REQUIRE_QUALITY="false"
	fi

	if [ "$REQUIRE_QUALITY" == "true" ]; then
		log "$TITLESHORT: Require Quality: ENABLED"
	else
		log "$TITLESHORT: Require Quality: DISABLED"
	fi

	if [ "$RELATED_ARTIST" = "true" ]; then
		log "$TITLESHORT: Related Artist: ENABLED"
	else
		log "$TITLESHORT: Related Artist: DISABLED"
	fi

	if [ "$RELATED_ARTIST_RELATED" = "true" ]; then
		log "$TITLESHORT: Related Artist Related (loop): ENABLED"
	else
		log "$TITLESHORT: Related Artist Related (loop): DISABLED"
	fi
	
	if [ "$COMPLETE_MY_ARTISTS" = "true" ]; then
		log "$TITLESHORT: Complete My Artists: ENABLED"
	else
		log "$TITLESHORT: Complete My Artists: DISABLED"
	fi

	if [ -z "$IGNORE_ARTIST_WITHOUT_IMAGE" ]; then
		log "WARNING: IGNORE_ARTIST_WITHOUT_IMAGE not set, using default..."
		IGNORE_ARTIST_WITHOUT_IMAGE="true"
	fi

	if [ "$IGNORE_ARTIST_WITHOUT_IMAGE" == "true" ]; then
		log "$TITLESHORT: Ignore Artist Without Image: ENABLED"
	else
		log "$TITLESHORT: Ignore Artist Without Image: DISABLED"
	fi

	if [ ! -z "$RELATED_COUNT" ]; then
		log "$TITLESHORT: Artist Maximum Related Import Count: $RELATED_COUNT"
	else
		log "WARNING: RELATED_COUNT not set, using default..."
		RELATED_COUNT="20"
		log "$TITLESHORT: Artist Maximum Related Import Count: $RELATED_COUNT"
	fi

	if [ ! -z "$FAN_COUNT" ]; then
		log "$TITLESHORT: Artist Minimum Fan Count: $FAN_COUNT"
	else
		log "WARNING: FAN_COUNT not set, using default..."
		FAN_COUNT="1000000"
		log "$TITLESHORT: Artist Minimum Fan Count: $FAN_COUNT"
	fi

	if [ ! -z "$FORMAT" ]; then
		log "$TITLESHORT: Download Format: $FORMAT"
		if [ "$FORMAT" = "ALAC" ]; then
			quality="FLAC"
			options="-c:a alac -movflags faststart"
			extension="m4a"
			log "$TITLESHORT: Download File Bitrate: lossless"
		elif [ "$FORMAT" = "FLAC" ]; then
			quality="FLAC"
			extension="flac"
			log "$TITLESHORT: Download File Bitrate: lossless"
		elif [ "$FORMAT" = "OPUS" ]; then
			quality="FLAC"
			options="-acodec libopus -ab ${BITRATE}k -application audio -vbr off"
		    extension="opus"
			log "$TITLESHORT: Download File Bitrate: $BITRATE"
		elif [ "$FORMAT" = "AAC" ]; then
			quality="FLAC"
			options="-c:a libfdk_aac -b:a ${BITRATE}k -movflags faststart"
			extension="m4a"
			log "$TITLESHORT: Download File Bitrate: $BITRATE"
		elif [ "$FORMAT" = "MP3" ]; then
			if [ "$BITRATE" = "320" ]; then
				quality="320"
				extension="mp3"
				log "$TITLESHORT: Download File Bitrate: $BITRATE"
			elif [ "$BITRATE" = "128" ]; then
				quality="128"
				extension="mp3"
				log "$TITLESHORT: Download File Bitrate: $BITRATE"
			else
				quality="FLAC"
				options="-acodec libmp3lame -ab ${BITRATE}k"
				extension="mp3"
				log "$TITLESHORT: Download File Bitrate: $BITRATE"
			fi
		else
			log "ERROR: \"$FORMAT\" Does not match a required setting, check for trailing space..."
			error=1
		fi
	else
		log "WARNING: FORMAT not set, using default..."
		log "$TITLESHORT: Download Quality: FLAC"
		log "$TITLESHORT: Download Bitrate: lossless"
		quality="FLAC"
	fi

	if [ ! -z "$REPLAYGAIN" ]; then
		if [ "$REPLAYGAIN" == "true" ]; then
			log "$TITLESHORT: Replaygain Tagging: ENABLED"
		else
			log "$TITLESHORT: Replaygain Tagging: DISABLED"
		fi
	else
		log "WARNING: REPLAYGAIN setting invalid, defaulting to: false"
		REPLAYGAIN="false"
	fi

	if [ ! -z "$FILE_PERMISSIONS" ]; then
		log "$TITLESHORT: File Permissions: $FILE_PERMISSIONS"
		FILEPERM=$FILE_PERMISSIONS
	else
		log "WARNING: FILE_PERMISSIONS not set, using default..."
		FILE_PERMISSIONS=644
		FILEPERM=$FILE_PERMISSIONS
		log "$TITLESHORT: File Permissions: $FILE_PERMISSIONS"
	fi

	if [ ! -z "$FOLDER_PERMISSIONS" ]; then
		log "$TITLESHORT: Folder Permissions: $FOLDER_PERMISSIONS"
		FOLDERPERM=$FOLDER_PERMISSIONS
	else
		log "WARNING: FOLDER_PERMISSIONS not set, using default..."
		FOLDER_PERMISSIONS=755
		FOLDERPERM=$FOLDER_PERMISSIONS
		log "$TITLESHORT: Folder Permissions: $FOLDER_PERMISSIONS"
	fi

	if [ "$LIDARR_LIST_IMPORT" = "true" ]; then
		log "$TITLESHORT: Lidarr List Import: ENABLED"
		wantit=$(curl -s --header "X-Api-Key:"${LIDARR_API_KEY} --request GET  "$LIDARR_URL/api/v1/Artist/")
		wantedtotal=$(echo "${wantit}"| jq -r '.[].sortName' | wc -l)
		MBArtistID=($(echo "${wantit}" | jq -r ".[].foreignArtistId"))
		if [ "$wantedtotal" -gt "0" ]; then
			log "$TITLESHORT: Lidarr Connection : Successful"
		else
		   log "ERROR: Lidarr Connection Error"
		   log "ERROR: Verify Lidarr is online at this address: $LIDARR_URL"
		   log "ERROR: Verify Lidarr API Key is correct: $LIDARR_LIST_IMPORT"
		   error=1
		fi
	else
		log "$TITLESHORT: Lidarr List Import: DISABLED"
	fi

	if [ "$NOTIFYPLEX" == "true" ]; then
		log "$TITLESHORT: Plex Library Notification: ENABLED"
		plexlibraries="$(curl -s "$PLEXURL/library/sections?X-Plex-Token=$PLEXTOKEN" | xq .)"
		if echo "$plexlibraries" | grep "/downloads-ama" | read; then
			plexlibrarykey="$(echo "$plexlibraries" | jq -r ".MediaContainer.Directory[] | select(.\"@title\"==\"$PLEXLIBRARYNAME\") | .\"@key\"" | head -n 1)"
			if [ -z "$plexlibrarykey" ]; then
				log "ERROR: No Plex Library found named \"$PLEXLIBRARYNAME\""
				error=1
			fi
		else
			log "ERROR: No Plex Library found containg path \"$folder\""
			log "ERROR: Add \"$folder\" as a folder to a Plex Music Library or Disable NOTIFYPLEX"
			error=1
		fi
	else
		log "$TITLESHORT: Plex Library Notification: DISABLED"
	fi

	if [ $error = 1 ]; then
		log "Please correct errors before attempting to run script again..."
		log "Exiting..."
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
				log "$logheader :: Adding Replaygain Tags using r128gain to: $folder"
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
		touch -d "168 hours ago" /config/cache/cache-info-check
		if find /config/cache/artists/$1 -type f -iname "$1-info.json" -not -newer "/config/cache/cache-info-check" | read; then
			updatedartistdata=$(curl -sL --fail "https://api.deezer.com/artist/$1")
			newalbumcount=$(echo "$updatedartistdata" | jq -r ".nb_album")
			existingalbumcount=$(cat /config/cache/artists/$1/$1-info.json | jq -r ".nb_album")
			if [ $newalbumcount != $existingalbumcount ]; then
				rm /config/cache/artists/$1/$1-info.json
				echo "$updatedartistdata" > /config/cache/artists/$1/$1-info.json
			fi
		else
			touch /config/cache/artists/$1/$1-info.json
		fi
		rm /config/cache/cache-info-check
	fi

	if [ ! -f /config/cache/artists/$1/$1-info.json ]; then
		if curl -sL --fail "https://api.deezer.com/artist/$1" -o /config/cache/$1-info.json; then
			if [ ! -d /config/cache/artists/$1 ]; then
				mkdir -p /config/cache/artists/$1
			fi
			mv /config/cache/$1-info.json /config/cache/artists/$1/$1-info.json
		else
			log "$logheader :: ERROR :: getting artist information"
		fi
	fi
	
	if [ -f /config/cache/artists/$1/$1-related.json ]; then
		touch -d "730 hours ago" /config/cache/cache-related-check
		find /config/cache/artists/$1 -type f -iname "$1-related.json" -not -newer "/config/cache/cache-related-check" -delete
		rm /config/cache/cache-related-check
	fi
	
	if ! [ -f /config/cache/artists/$1/$1-related.json ]; then
		if curl -sL --fail "https://api.deezer.com/artist/$1/related" -o /config/cache/$1-temp-related.json ; then
			jq "." /config/cache/$1-temp-related.json > /config/cache/$1-related.json
			if [ ! -d /config/cache/artists/$1 ]; then
				mkdir -p /config/cache/artists/$1
			fi
			mv  /config/cache/$1-related.json /config/cache/artists/$1/$1-related.json
			rm /config/cache/$1-temp-related.json
		else
			log "$logheader :: ERROR :: getting artist related information"
		fi
	fi

	if [ ! -f /config/cache/artists/$1/folder.jpg ]; then
		artistpictureurl=$(cat "/config/cache/artists/$1/$1-info.json" | jq -r ".picture_xl" | sed 's%1000x1000%1800x1800%g' | sed 's%80-0-0.jpg%100-0-0.jpg%g')
		curl -s "$artistpictureurl" -o /config/cache/artists/$1/folder.jpg
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
		log "$logheader :: Processing..."
		ArtistAlbumList
		albumlistdata=$(jq -s '.' /config/cache/artists/$artistid/albums/*.json)
		artistalbumcount=$(echo "$albumlistdata" | jq -r ".[] | select(.artist.id==$artistid) | .id" | wc -l)
		artistcontributedalbumcount=$(echo "$albumlistdata" | jq -r ".[] | select(.contributors[].id==$artistid) | .id" | wc -l)
		artistdiscographyalbumcount=$(echo "$albumlistdata" | jq -r ".[] | select(.artist.id!=$artistid) | .id" | wc -l)
		if [ "$MODE" == "discography" ]; then
			albumcount="$(echo "$albumlistdata" | jq -r "sort_by(.nb_tracks) | sort_by(.explicit_lyrics and .nb_tracks) | reverse | .[].id" | wc -l)"
			albumids=($(echo "$albumlistdata" | jq -r "sort_by(.nb_tracks) | sort_by(.explicit_lyrics and .nb_tracks) | reverse | .[].id"))
		else
			albumcount="$(echo "$albumlistdata" | jq -r "sort_by(.nb_tracks) | sort_by(.explicit_lyrics and .nb_tracks) | reverse | .[] | select(.artist.id==$artistid) | .id" | wc -l)"
			albumids=($(echo "$albumlistdata" | jq -r "sort_by(.nb_tracks) | sort_by(.explicit_lyrics and .nb_tracks) | reverse | .[] | select(.artist.id==$artistid) | .id"))
		fi
		log "$logheader :: Downloading $albumcount Albums"
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
		sanatizedalbumartist="$(echo "$albumartist" | sed -e "s%[^[:alpha:][:digit:]._()' -]% %g" -e "s/  */ /g")"
		logheader="$logheader :: $albumprocess of $albumcount :: PROCESSING :: $albumartist"
		if [ -f /config/logs/downloads/$albumid ]; then
			log "$logheader :: Album ($albumid) Already Downloaded..."
			logheader="$logheaderstart"
			continue
		fi
		if [ -f /config/logs/filtered/$albumid ]; then
			log "$logheader :: Album ($albumid) Previously skipped because of unwanted Album Type ($ALBUM_TYPE_FILTER)..."
			logheader="$logheaderstart"
			continue
		fi
		if find /config/ignore -type f -iname "$albumartistid" | read; then
			log "$logheader :: Ignored Artist found, skipping..."
			logheader="$logheaderstart"
			continue
		fi
		
		if find /config/ignore -type f -name "$albumartistid" -o -name "$albumartistid-lidarr" -o -name "$albumartistid-related" -o -name "$albumartistid-complete"  | read; then
			log "$logheader :: Album Artist found in wanted list (/config/list/$albumartistid), $albumartistid will be processed later, skipping..."
			logheader="$logheaderstart"
			continue
		fi
		
		if [ $albumartistid == 5080 ]; then
			artistfolder="/downloads-ama/$sanatizedalbumartist"
		else
			artistfolder="/downloads-ama/$sanatizedalbumartist ($albumartistid)"
		fi
		if [ -d "$artistfolder" ]; then
			if find "$artistfolder" -iname "* ($albumid)" | read; then
				log "$logheader :: Album ($albumid) Already Downloaded..."
				if [ ! -d /config/logs/downloads ]; then
					mkdir -p /config/logs/downloads
				fi
				if [ ! -f /config/logs/downloads/$albumid ]; then
					touch /config/logs/downloads/$albumid
				fi
				logheader="$logheaderstart"
				continue
			fi
		fi
		if [ "$albumartistid" != "$artistid" ]; then
			ArtistInfo "$albumartistid"
		fi
		artistfancount=$(cat "/config/cache/artists/$albumartistid/$albumartistid-info.json" | jq -r ".nb_fan")
		if [ ! -f "$artistfolder/folder.jpg" ]; then
			artistimage="/config/cache/artists/$albumartistid/folder.jpg"
			if [ -f "$artistimage" ]; then
				blankartistmd5="ec1853a066b6f5f94b55a14fb9e34c97"
				md5="$(md5sum "$artistimage")"
				md5clean="$(echo "$md5" | cut -f1 -d " ")"
				if [ "$md5clean" == "$blankartistmd5" ]; then
					blankartistimage="true"
				else
					blankartistimage="false"
				fi
			else
				blankartistimage="true"
			fi
		fi
		
		if [ $artistid != $albumartistid ]; then
			if [ $albumartistid != 5080 ]; then
				if [ $artistfancount -lt $FAN_COUNT ]; then
					log "$logheader :: $albumartist :: ERROR :: $artistfancount fan count lower then required minimum ($FAN_COUNT), skipping..."
					logheader="$logheaderstart"
					continue
				fi
				if [ "$IGNORE_ARTIST_WITHOUT_IMAGE" == "true" ]; then
					if find /config/list -type f -iname "$albumartistid-related" -o -iname "$albumartistid-complete" | read; then
						if [ "$blankartistimage" == true ]; then
							log "$logheader :: $albumartist :: ERROR :: Artist image is blank, skipping..."
							logheader="$logheaderstart"
							continue
						fi
					fi
				fi
			fi
		fi
		albumtitle="$(echo "$albumdata" | jq -r ".title")"
		sanatizedalbumtitle="$(echo "$albumtitle" | sed -e "s%[^[:alpha:][:digit:]._()' -]% %g" -e "s/  */ /g")"
		albumdate="$(echo "$albumdata" | jq -r ".release_date")"
		albumtype="$(echo "$albumdata" | jq -r ".record_type")"
		albumexplicit="$(echo "$albumdata" | jq -r ".explicit_lyrics")"
		if [ "$albumexplicit" == "true" ]; then
			lyrictype="EXPLICIT"
		else
			lyrictype="CLEAN"
		fi
		albumyear="${albumdate:0:4}"
		albumfolder="$sanatizedalbumartist - ${albumtype^^} - $albumyear - $sanatizedalbumtitle ($lyrictype) ($albumid)"
		logheader="$logheader :: ${albumtype^^} :: $albumyear :: $lyrictype :: $albumtitle"
		if [ $ALBUM_FILTER == true ]; then
			AlbumFilter
		
			if [ $filtermatch == true ]; then
				log "$logheader :: Album Type matched unwanted filter "$filtertype", skipping..."
				if [ ! -d /config/logs/filtered ]; then
					mkdir -p /config/logs/filtered
				fi
				if [ ! -f /config/logs/filtered/$albumid ]; then
					touch /config/logs/filtered/$albumid
				fi
				logheader="$logheaderstart"
				continue
			fi
		fi
		if [ -d "$artistfolder" ]; then
			if [ "${albumtype^^}" != "SINGLE" ]; then
				if [ "$albumexplicit" == "false" ]; then
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (EXPLICIT) *" | read; then
						log "$logheader :: Duplicate EXPLICIT ${albumtype^^} found, skipping..."
						logheader="$logheaderstart"
						continue
					fi
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (Deluxe*(EXPLICIT) *" | read; then
						log "$logheader :: Duplicate EXPLICIT ${albumtype^^} Deluxe found, skipping..."
						logheader="$logheaderstart"
						continue
					fi
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (CLEAN) *" | read; then
						log "$logheader :: Duplicate CLEAN ${albumtype^^} found, skipping..."
						logheader="$logheaderstart"
						continue
					fi
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (Deluxe*(CLEAN) *" | read; then
						log "$logheader :: Duplicate CLEAN ${albumtype^^} Deluxe found, skipping..."
						logheader="$logheaderstart"
						continue
					fi
				fi
				if [ "$albumexplicit" == "true" ]; then
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - $albumyear - $sanatizedalbumtitle (EXPLICIT) *" | read; then
						log "$logheader :: Duplicate EXPLICIT ${albumtype^^} $albumyear found, skipping..."
						logheader="$logheaderstart"
						continue
					fi
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (Deluxe*(EXPLICIT) *" | read; then
						log "$logheader :: Duplicate EXPLICIT ${albumtype^^} Deluxe found, skipping..."
						logheader="$logheaderstart"
						continue
					fi
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (CLEAN) *" | read; then
						log "$logheader :: Duplicate CLEAN ${albumtype^^} found, skipping..."
						find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (CLEAN) *" -exec rm -rf "{}" \; &> /dev/null
						PlexNotification "$artistfolder"
					fi
				fi
			fi
			if [ "${albumtype^^}" == "SINGLE" ]; then
				if [ "$albumexplicit" == "false" ]; then
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - * - $sanatizedalbumtitle (EXPLICIT) *" | read; then
						log "$logheader :: Duplicate EXPLICIT SINGLE already downloaded, skipping..."
						logheader="$logheaderstart"
						continue
					fi
				fi
				if [ "$albumexplicit" == "true" ]; then
					if find "$artistfolder" -iname "$sanatizedalbumartist - ${albumtype^^} - $albumyear - $sanatizedalbumtitle (EXPLICIT) *" | read; then
						log "$logheader :: Duplicate EXPLICIT SINGLE already downloaded, skipping..."
						logheader="$logheaderstart"
						continue
					fi
				fi
			fi
		fi
		logheader="$logheader :: DOWNLOAD"
		log "$logheader :: Sending \"$deezeralbumurl\" to download client..."

		if [ ! -d /downloads-ama/temp ]; then
			mkdir -p /downloads-ama/temp
			chmod $FOLDERPERM /downloads-ama/temp
			chown -R abc:abc /downloads-ama/temp
		else
			rm -rf /downloads-ama/temp/*
			chmod $FOLDERPERM /downloads-ama/temp
			chown -R abc:abc /downloads-ama/temp
		fi

		if python3 /config/scripts/dlclient.py -b $quality "$deezeralbumurl"; then
			sleep 0.5
			if find /downloads-ama/temp -iregex ".*/.*\.\(flac\|mp3\)" | read; then
				DownloadQualityCheck
			fi
			if find /downloads-ama/temp -iregex ".*/.*\.\(flac\|mp3\)" | read; then
				find /downloads-ama/temp -type d -exec chmod $FOLDERPERM {} \;
				find /downloads-ama/temp -type f -exec chmod $FILEPERM {} \;
				chown -R abc:abc /downloads-ama/temp
			else
				log "$logheader :: ERROR :: No files found"
				continue
			fi
		fi
		
		file=$(find /downloads-ama/temp -iregex ".*/.*\.\(flac\|mp3\)" | head -n 1)
		if [ ! -z "$file" ]; then
			artwork="$(dirname "$file")/folder.jpg"
			if ffmpeg -y -i "$file" -c:v copy "$artwork" 2>/dev/null; then
				log "$logheader :: Artwork Extracted"
			else
				log "$logheader :: ERROR :: No artwork found"
			fi
		fi
		
		Conversion
		AddReplaygainTags

		if [ ! -d "$artistfolder" ]; then
			mkdir -p "$artistfolder"
			chmod $FOLDERPERM "$artistfolder"
			chown -R abc:abc "$artistfolder"
		fi
		if [ ! -d "$artistfolder/$albumfolder" ]; then
			mkdir -p "$artistfolder/$albumfolder"
			chmod $FOLDERPERM "$artistfolder/$albumfolder"
			chown -R abc:abc "$artistfolder/$albumfolder"
		fi
		mv /downloads-ama/temp/* "$artistfolder/$albumfolder"/
		chmod $FILEPERM "$artistfolder/$albumfolder"/*
		chown -R abc:abc "$artistfolder/$albumfolder"
		if [ -f /config/cache/artists/$albumartistid/folder.jpg ]; then
			if [ "$blankartistimage" == "false" ]; then
				if [ ! -f "$artistfolder/folder.jpg" ]; then
					if [ $albumartistid != 5080 ]; then
						cp /config/cache/artists/$albumartistid/folder.jpg "$artistfolder/folder.jpg"
						chmod $FILEPERM "$artistfolder/folder.jpg"
						chown -R abc:abc "$artistfolder/folder.jpg"
					fi
				fi
			fi
		fi
		PlexNotification "$artistfolder/$albumfolder"
		if [ -d /downloads-ama/temp ]; then
			rm -rf /downloads-ama/temp
		fi
		if [ ! -d /config/logs/downloads ]; then
			mkdir -p /config/logs/downloads
		fi
		if [ ! -f /config/logs/downloads/$albumid ]; then
			touch /config/logs/downloads/$albumid
		fi
		logheader="$logheaderstart"
	done
}

AlbumFilter () {

	IFS=', ' read -r -a filters <<< "$ALBUM_TYPE_FILTER"
	for filter in "${filters[@]}"
	do
		if [ "$filter" == "${albumtype^^}" ]; then
			filtermatch=true
			filtertype="$filter"
			break
		else
			filtermatch=false
			filtertype=""
			continue
		fi
	done

}

Conversion () {
	converttrackcount=$(find  /downloads-ama/temp/ -name "*.flac" | wc -l)
	if [ "${FORMAT}" != "FLAC" ]; then
		if find /downloads-ama/temp/ -name "*.flac" | read; then
			log "$logheader :: CONVERSION :: Converting: $converttrackcount Tracks (Target Format: $FORMAT (${BITRATE}))"
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
					log "$logheader :: CONVERSION :: ERROR :: Coversion Failed: $filename, performing cleanup..."
					rm "${fname%.flac}.temp.$extension"
					continue
				elif [ -f "${fname%.flac}.temp.$extension" ]; then
					rm "$fname"
					sleep 0.1
					mv "${fname%.flac}.temp.$extension" "${fname%.flac}.$extension"
					log "$logheader :: CONVERSION :: $filename :: Converted!"
				fi
			done
		fi
	fi
}

AddReplaygainTags () {
	if [ "$REPLAYGAIN" == "true" ]; then
		log "$logheader :: DOWNLOAD :: Adding Replaygain Tags using r128gain"
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
		if [ -f  /config/cache/artists/$artistid/$artistid-related.json ]; then
			artistrelatedfile=$(cat  /config/cache/artists/$artistid/$artistid-related.json)
			artistrelatedcount="$(echo "$artistrelatedfile" | jq -r ".total")"
			if [ "$artistrelatedcount" -gt "0" ]; then
				artistrelatedidlist=($(echo "$artistrelatedfile" | jq ".data[] | select(.nb_fan >= $FAN_COUNT) | .id" | head -n $RELATED_COUNT))
				artistrelatedidlistcount=$(echo "$artistrelatedfile" | jq ".data[] | select(.nb_fan >= $FAN_COUNT) | .id" | head -n $RELATED_COUNT | wc -l)
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
			touch "/config/list/$completeartistid-complete"
		fi
	done
}

PlexNotification () {

	if [ "$NOTIFYPLEX" == "true" ]; then
		plexfolder="$1"
		plexfolderencoded="$(jq -R -r @uri <<<"${plexfolder}")"
		curl -s "$PLEXURL/library/sections/$plexlibrarykey/refresh?path=$plexfolderencoded&X-Plex-Token=$PLEXTOKEN"
		log "$logheader :: Plex Scan notification sent! ($plexfolder)"
	fi
}

DownloadQualityCheck () {

	if [ "$REQUIRE_QUALITY" == "true" ]; then
		log "$logheader :: DOWNLOAD :: Checking for unwanted files"
		if [ "$quality" == "FLAC" ]; then
			if find /downloads-ama/temp -iname "*.mp3" | read; then
				log "$logheader :: DOWNLOAD :: Unwanted files found!"
				log "$logheader :: DOWNLOAD :: Performing cleanup..."
				rm /downloads-ama/temp/*
			fi
		else
			if find /downloads-ama/temp -iname "*.flac" | read; then
				log "$logheader :: DOWNLOAD :: Unwanted files found!"
				log "$logheader :: DOWNLOAD :: Performing cleanup..."
				rm /downloads-ama/temp/*
			fi
		fi
	fi

}

ArtistAlbumList () {

	albumcount="$(python3 /config/scripts/artist_discograpy.py "$artistid" | sort -u | wc -l)"
	if [ -d /config/cache/artists/$artistid/albums ]; then
		cachecount=$(ls /config/cache/artists/$artistid/albums/* | wc -l)
	else
		cachecount=0
	fi
	albumids=($(python3 /config/scripts/artist_discograpy.py "$artistid" | sort -u))
	log "$logheader :: Searching for All Albums...."
	log "$logheader :: $albumcount Albums found!"
	
	if [ $albumcount != $cachecount ]; then
		if [ ! -d "/config/temp" ]; then
			mkdir "/config/temp"
		fi
		for id in ${!albumids[@]}; do
			currentprocess=$(( $id + 1 ))
			albumid="${albumids[$id]}"
			if [ ! -d /config/cache/artists/$artistid/albums ]; then
				mkdir -p /config/cache/artists/$artistid/albums
				chmod $FOLDERPERM /config/cache/artists/$artistid
				chmod $FOLDERPERM /config/cache/artists/$artistid/albums
				chown -R abc:abc /config/cache/artists/$artistid
			fi
			if [ ! -f /config/cache/artists/$artistid/albums/${albumid}.json ]; then
				if curl -sL --fail "https://api.deezer.com/album/${albumid}" -o "/config/temp/${albumid}.json"; then
					log "$logheader :: $currentprocess of $albumcount :: Downloading Album info..."
					mv /config/temp/${albumid}.json /config/cache/artists/$artistid/albums/${albumid}.json
					chmod $FILEPERM /config/cache/artists/$artistid/albums/${albumid}.json
				else
					log "$logheader :: $currentprocess of $albumcount :: Error getting album information"
				fi
			else
				log "$logheader :: $currentprocess of $albumcount :: Album info already downloaded"
			fi
		done
		chown -R abc:abc /config/cache/artists/$artistid
		if [ -d "/config/temp" ]; then
			rm -rf "/config/temp"
		fi
	fi
}

log () {
    m_time=`date "+%F %T"`
    echo $m_time" "$1
}

Main () {
	Configuration
	log "############################################ SCRIPT START"
	if [ "$LIDARR_LIST_IMPORT" == "true" ] || [ "$COMPLETE_MY_ARTISTS" == "true" ] || [ "$RELATED_ARTIST" == "true" ]; then
		if [ "$LIDARR_LIST_IMPORT" == "true" ]; then
			LidarrListImport
		fi
		if [ "$COMPLETE_MY_ARTISTS" == "true" ]; then
			AddMissingArtists
		fi
		if  [ "$RELATED_ARTIST" == "true" ]; then
			ProcessArtistRelated
		fi
	fi
	
	if [ "$LIDARR_LIST_IMPORT" != "true" ]; then
		find /config/list -iname "*-lidarr" -delete
	fi
	
	if [ "$COMPLETE_MY_ARTISTS" != "true" ]; then
		find /config/list -iname "*-complete" -delete
	fi
	
	if  [ "$RELATED_ARTIST" != "true" ]; then
		find /config/list -iname "*-related" -delete
	fi
	
	if ls /config/list | read; then
		if ls /config/list -I "*-related" -I "*-lidarr" -I "*-complete" | read; then
			listcount="$(ls /config/list -I "*-related" -I "*-lidarr" -I "*-complete" | wc -l)"
			listregtext="$listcount Artists (Not related/imported)"
		else
			listregtext="0 Artists (Not related/imported)"
		fi

		if ls /config/list/*-related 2> /dev/null | read; then
			listrelatedcount="$(ls /config/list | grep "related" | cut -f1 -d "-" | sort -u | wc -l)"
			relatedtext="$listrelatedcount Related Artists (Minimum Fan Count: $FAN_COUNT)"
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
			if [ "$LIDARR_LIST_IMPORT" = "true" ]; then
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
			if [ "$COMPLETE_MY_ARTISTS" = "true" ]; then
				completeoption=""
			else
				completeoption=" -not -iname *-complete"
			fi
		else
			completetext="0 Complete Artists"
		fi

		listcount="$(find /config/list -mindepth 1${lidarroption}${relatedoption}${completeoption} | sed 's%/config/list/%%g' | cut -f1 -d "-" | sort -u | wc -l)"
		list=($(find /config/list -mindepth 1${lidarroption}${relatedoption}${completeoption} | sed 's%/config/list/%%g' | cut -f1 -d "-" | sort -u))
		log "$listcount Artists Found!"
		log "#########################"
		log "Artist List comprised of:"
		log "$listregtext"
		if [ "$RELATED_ARTIST" = "true" ]; then
			log "$relatedtext"
		fi
		if [ "$LIDARR_LIST_IMPORT" = "true" ]; then
			log "$lidarrtext"
		fi
		if [ "$COMPLETE_MY_ARTISTS" = "true" ]; then
			log "$completetext"
		fi
		log "#########################"
		log "#####PROCESSING LIST#####"
		log "#########################"
		ProcessArtistList
	else
		log "No artists to process, add artist files to list directory"
	fi
	log "############################################ SCRIPT END"
}

Main

exit 0

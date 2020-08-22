ARG ffmpeg_tag=snapshot-ubuntu
FROM jrottenberg/ffmpeg:${ffmpeg_tag} as ffmpeg
FROM lsiobase/ubuntu:bionic
LABEL maintainer="RandomNinjaAtk"

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

ENV VERSION="0.0.1"
ENV XDG_CONFIG_HOME="/xdg"
ENV PYTHON="python3"
ENV PathToDLClient="/root/scripts/deemix"
ENV library="/storage/media/music"
RUN \
	echo "************ install dependencies ************" && \
	echo "************ install packages ************" && \
	apt-get update -qq && \
	apt-get install -qq -y \
		wget \
		nano \
		unzip \
		git \
		jq \
		mp3val \
		flac \
		opus-tools \
		python3 \
		python3-pip \
		libchromaprint-tools \
		cron && \
	apt-get purge --auto-remove -y && \
	apt-get clean && \
	echo "************ install updated ffmpeg ************" && \
	chgrp users /usr/local/bin/ffmpeg && \
 	chgrp users /usr/local/bin/ffprobe && \
	chmod g+x /usr/local/bin/ffmpeg && \
	chmod g+x /usr/local/bin/ffprobe && \
	echo "************ install beets plugin dependencies ************" && \
	pip3 install --no-cache-dir -U \
		requests \
		Pillow \
		pylast \
		mutagen \
		r128gain \
		deemix \
		pyacoustid && \
	echo "************ setup dl client config directory ************" && \
	echo "************ make directory ************" && \
	mkdir -p "${XDG_CONFIG_HOME}/deemix"
	
RUN \
	apt-get update -y && \
	apt-get install -y --no-install-recommends libva-drm2 libva2 i965-va-driver && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*
    
WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config /storage

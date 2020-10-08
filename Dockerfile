ARG ffmpeg_tag=snapshot-ubuntu
FROM jrottenberg/ffmpeg:${ffmpeg_tag} as ffmpeg
FROM lsiobase/ubuntu:focal
LABEL maintainer="RandomNinjaAtk"

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

ENV TITLE="Automated Music Archiver (AMA)"
ENV TITLESHORT="AMA"
ENV VERSION="1.0.7"
ENV XDG_CONFIG_HOME="/config/deemix/xdg"
RUN \
	echo "************ install dependencies ************" && \
	echo "************ install and upgrade packages ************" && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		netbase \
		jq \
		flac \
		eyed3 \
		python3 \
		python3-pip && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/* && \
	echo "************ install updated ffmpeg ************" && \
	chgrp users /usr/local/bin/ffmpeg && \
 	chgrp users /usr/local/bin/ffprobe && \
	chmod g+x /usr/local/bin/ffmpeg && \
	chmod g+x /usr/local/bin/ffprobe && \
	echo "************ install python packages ************" && \
	python3 -m pip install --no-cache-dir -U \
		yq \
		mutagen \
		r128gain \
		deemix && \
	echo "************ setup dl client config directory ************" && \
	echo "************ make directory ************" && \
	mkdir -p "${XDG_CONFIG_HOME}/deemix"
 
RUN \
	apt-get update -y && \
	apt-get install -y --no-install-recommends \
		libva-drm2 \
		libva2 \
		libgomp1 \
		i965-va-driver && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# copy local files
COPY root/ /

RUN \
	echo "************ install updated opus-tools ************" && \
	bash /opus.bash

# set work directory
WORKDIR /config

# ports and volumes
VOLUME /config

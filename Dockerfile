ARG ffmpeg_tag=snapshot-ubuntu
FROM jrottenberg/ffmpeg:${ffmpeg_tag} as ffmpeg
FROM lsiobase/ubuntu:bionic
LABEL maintainer="RandomNinjaAtk"

# Add files from ffmpeg
COPY --from=ffmpeg /usr/local/ /usr/local/

ENV VERSION="0.0.4"
ENV XDG_CONFIG_HOME="/config/deemix/xdg"
ENV PYTHON="python3"
ENV PathToDLClient="/root/scripts/deemix"
ENV library="/storage/media/music"
RUN \
	echo "************ install dependencies ************" && \
	echo "************ install packages ************" && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
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
		libchromaprint-tools && \
	apt-get purge --auto-remove -y && \
	apt-get clean && \
	echo "************ install updated ffmpeg ************" && \
	chgrp users /usr/local/bin/ffmpeg && \
 	chgrp users /usr/local/bin/ffprobe && \
	chmod g+x /usr/local/bin/ffmpeg && \
	chmod g+x /usr/local/bin/ffprobe && \
	echo "************ install python packages ************" && \
	python3 -m pip install --no-cache-dir -U \
		mutagen \
		r128gain \
		deemix && \
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

FROM lsiobase/ubuntu:bionic
LABEL maintainer="RandomNinjaAtk"

ENV VERSION="0.0.5"
ENV XDG_CONFIG_HOME="/config/deemix/xdg"
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
		eyed3 \
		python3 \
		ffmpeg \
		python3-pip \
		libchromaprint-tools && 
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/* && \
	echo "************ install python packages ************" && \
	python3 -m pip install --no-cache-dir -U \
		mutagen \
		r128gain \
		deemix && \
	echo "************ setup dl client config directory ************" && \
	echo "************ make directory ************" && \
	mkdir -p "${XDG_CONFIG_HOME}/deemix"
    
WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config /downloads-ama

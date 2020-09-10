FROM lsiobase/ubuntu:focal
LABEL maintainer="RandomNinjaAtk"

ENV TITLE="Automated Music Archiver (AMA)"
ENV TITLESHORT="AMA"
ENV VERSION="1.0.2"
ENV XDG_CONFIG_HOME="/config/deemix/xdg"
RUN \
	echo "************ install dependencies ************" && \
	echo "************ install and upgrade packages ************" && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
		jq \
		mp3val \
		flac \
		eyed3 \
		opus-tools \
		ffmpeg \
		python3 \
		python3-pip && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/* && \
	echo "************ install python packages ************" && \
	python3 -m pip install --no-cache-dir -U \
		yq \
		mutagen \
		r128gain \
		deemix && \
	echo "************ setup dl client config directory ************" && \
	echo "************ make directory ************" && \
	mkdir -p "${XDG_CONFIG_HOME}/deemix"
    
# copy local files
COPY root/ /

# set work directory
WORKDIR /config

# ports and volumes
VOLUME /config

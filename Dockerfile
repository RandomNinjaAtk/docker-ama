FROM lsiobase/alpine:3.11
LABEL maintainer="RandomNinjaAtk"

ENV TITLE="Automated Music Archiver (AMA)"
ENV TITLESHORT="AMA"
ENV VERSION="1.0.7"
ENV XDG_CONFIG_HOME="/config/deemix/xdg"
RUN \
	echo "**** install build packages ****" && \
	apk add --no-cache --virtual=build-dependencies \
		gcc \
		g++ \
		libffi-dev \
		python3-dev \
		git \
		make && \
	echo "************ install dependencies ************" && \
	echo "************ install and upgrade packages ************" && \
	apk update && \
	apk upgrade && \
	apk add --no-cache \
		curl \
		jq \
		flac \
		opus-tools \
		ffmpeg \
		py3-pip \
		python3 && \
	echo "************ install python packages ************" && \
	pip3 install --no-cache-dir -U \
		yq \
		mutagen \
		r128gain \
		deemix && \
	echo "************ setup dl client config directory ************" && \
	echo "************ make directory ************" && \
	mkdir -p "${XDG_CONFIG_HOME}/deemix" && \
	echo "************ clean up ************" && \
	rm -rf \
		/root/.cache \
		/tmp/*

    
# copy local files
COPY root/ /

# set work directory
WORKDIR /config

# ports and volumes
VOLUME /config

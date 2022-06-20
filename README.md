# Deprecated

This repository is now deprecated, will no longer be updated and is being archived. Please visit the new project/replacement:
* [https://github.com/linuxserver/docker-lidarr-extended](https://github.com/RandomNinjaAtk/docker-lidarr-extended)

<br />
<br />

# AMA - Automated Music Archiver
[![Docker Build](https://img.shields.io/docker/cloud/automated/randomninjaatk/ama?style=flat-square)](https://hub.docker.com/r/randomninjaatk/ama)
[![Docker Pulls](https://img.shields.io/docker/pulls/randomninjaatk/ama?style=flat-square)](https://hub.docker.com/r/randomninjaatk/ama)
[![Docker Stars](https://img.shields.io/docker/stars/randomninjaatk/ama?style=flat-square)](https://hub.docker.com/r/randomninjaatk/ama)
[![Docker Hub](https://img.shields.io/badge/Open%20On-DockerHub-blue?style=flat-square)](https://hub.docker.com/r/randomninjaatk/ama)
[![Discord](https://img.shields.io/discord/747100476775858276.svg?style=flat-square&label=Discord&logo=discord)](https://discord.gg/JumQXDc "realtime support / chat with the community." )

[RandomNinjaAtk/ama](https://github.com/RandomNinjaAtk/docker-ama) is a script to automatically archive music for use in other audio applications (plex/kodi/jellyfin/emby) 

[![RandomNinjaAtk/ama](https://raw.githubusercontent.com/RandomNinjaAtk/unraid-templates/master/randomninjaatk/img/ama.png)](https://github.com/RandomNinjaAtk/docker-ama)

## Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | latest |

## Version Tags

| Tag | Description |
| :----: | --- |
| latest | Newest release code |


## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| --- | --- |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-v /config` | Configuration files for AMA |
| `-v /downloads-ama` | Downloaded library location |
| `-e AUTOSTART=true` | true = Enabled :: Runs script automatically on startup |
| `-e SCRIPTINTERVAL=15m` | #s or #m or #h or #d :: s = seconds, m = minutes, h = hours, d = days :: Amount of time between each script run, when AUTOSTART is enabled|
| `-e MODE=artist` | artist or discography :: artist mode downloads all albums listed as that artist, discography downloads all albums listed as that artist and featured in albums |
| `-e RELATED_ARTIST=false` | true = enabled :: Enabling this lets the script crawl your artist list for related artists and process them |
| `-e RELATED_ARTIST_RELATED=false` | true = enabled :: Enabling this lets the script crawl your related artists for additional related artists and process them accordingly :: WARNING this will cause an endless loop (spider crawling) until no more are found... |
| `-e RELATED_COUNT=20` | Maximum number of related artists to import per artist (20 is max) |
| `-e FAN_COUNT=1000000` | Minimum number of fans required for processing |
| `-e CONCURRENT_DOWNLOADS=1` | Controls download concurrency |
| `-e EMBEDDED_COVER_QUALITY=80` | Controls the quality of the cover image compression in percentage, 100 = no compression |
| `-e FORMAT=FLAC` | SET TO: ALAC or FLAC or AAC or MP3 or OPUS |
| `-e BITRATE=320` | FLAC -> OPUS/AAC/MP3 will be converted using this bitrate |
| `-e FORCECONVERT=false` | true = enabled :: This will convert lossy MP3 to desired target format (exluding FLAC/ALAC, ALAC will convert to AAC) |
| `-e POSTPROCESSTHREADS=1` | Controls number of threads used for Format conversion and replaygain tagging |
| `-e ALBUM_TYPE_FILTER=COMPILE` | Filter Types: COMPILE, SINGLE, ALBUM, EP (this is a ", " separated list of Album Types to skip) |
| `-e REQUIRE_QUALITY=false` | true = enabled :: Requires all downloaded files match target file extension (mp3 or flac) when enabled |
| `-e REPLAYGAIN=true` | true = enabled :: Scans and analyzes files to add replaygain tags to song metadata |
| `-e IGNORE_ARTIST_WITHOUT_IMAGE=false` | true = enabled :: Enabling this will prevent downloading albums from artists with default image (non-unique) |
| `-e COMPLETE_MY_ARTISTS=false` | true = enabled :: Eanabling this will add artist id's found in the library directory that are currently not in your list. This will then allow the script archive them accordingly :: !!!WARNING!!! Could cause an endless loop! |
| `-e FILE_PERMISSIONS=644` | Based on chmod linux permissions |
| `-e FOLDER_PERMISSIONS=755` | Based on chmod linux permissions |
| `-e ARL_TOKEN=ARLTOKEN` | User token for dl client, for instructions to obtain token: https://notabug.org/RemixDevs/DeezloaderRemix/wiki/Login+via+userToken |
| `-e LIDARR_LIST_IMPORT=true` | true = enabled :: imports artist list from lidarr |
| `-e LIDARR_URL=http://x.x.x.x:8686` | ONLY used if Lidarr List Import is enabled... |
| `-e LIDARR_API_KEY=08d108d108d108d108d108d108d108d1` | ONLY used if Lidarr List Import is enabled... |
| `-e NOTIFYPLEX=true` | true = enabled :: Plex must have a library added and be configured to use the exact same mount point (/downloads-ama) |
| `-e PLEXLIBRARYNAME=Music` | This must exactly match the name of the Plex Library that contains the Lidarr Media Folder data |
| `-e PLEXURL=http://x.x.x.x:32400` | ONLY used if NOTIFYPLEX is enabled... |
| `-e PLEXTOKEN=plextoken` | ONLY used if NOTIFYPLEX is enabled... |

## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=ama \
  -v /path/to/config/files:/config \
  -v /path/to/downloads:/downloads-ama \
  -e PUID=1000 \
  -e PGID=1000 \
  -e AUTOSTART=true \
  -e SCRIPTINTERVAL=1h \
  -e MODE=artist \
  -e RELATED_ARTIST=false \
  -e RELATED_ARTIST_RELATED=false \
  -e RELATED_COUNT=20 \
  -e FAN_COUNT=1000000 \
  -e CONCURRENT_DOWNLOADS=1 \
  -e EMBEDDED_COVER_QUALITY=80 \
  -e FORMAT=FLAC \
  -e BITRATE=320 \
  -e FORCECONVERT=false \
  -e POSTPROCESSTHREADS=1 \
  -e ALBUM_TYPE_FILTER=COMPILE \
  -e REQUIRE_QUALITY=false \
  -e REPLAYGAIN=true \
  -e IGNORE_ARTIST_WITHOUT_IMAGE=false \
  -e COMPLETE_MY_ARTISTS=false \
  -e FILE_PERMISSIONS=644 \
  -e FOLDER_PERMISSIONS=755 \
  -e LIDARR_LIST_IMPORT=false
  -e LIDARR_URL=http://x.x.x.x:8686 \
  -e LIDARR_API_KEY=LIDARRAPI \
  -e ARL_TOKEN=ARLTOKEN	\
  -e NOTIFYPLEX=false \
  -e PLEXLIBRARYNAME=Music \
  -e PLEXURL=http://x.x.x.x:8686 \
  -e PLEXTOKEN=plextoken \
  --restart unless-stopped \
  randomninjaatk/ama 
```

### docker-compose

Compatible with docker-compose v2 schemas.

```
version: "2.1"
services:
  amd:
    image: randomninjaatk/ama 
    container_name: ama
    volumes:
      - /path/to/config/files:/config
      - /path/to/downloads:/downloads-ama
    environment:
      - PUID=1000
      - PGID=1000
      - AUTOSTART=true
      - SCRIPTINTERVAL=1h
      - MODE=artist
      - RELATED_ARTIST=false
      - RELATED_ARTIST_RELATED=false
      - RELATED_COUNT=20
      - FAN_COUNT=1000000
      - CONCURRENT_DOWNLOADS=1
      - EMBEDDED_COVER_QUALITY=80
      - FORMAT=FLAC
      - BITRATE=320
      - FORCECONVERT=false
      - POSTPROCESSTHREADS=1
      - ALBUM_TYPE_FILTER=COMPILE
      - REQUIRE_QUALITY=false
      - IGNORE_ARTIST_WITHOUT_IMAGE=false
      - COMPLETE_MY_ARTISTS=false
      - REPLAYGAIN=true
      - FOLDER_PERMISSIONS=755
      - FILE_PERMISSIONS=644
      - LIDARR_LIST_IMPORT=false
      - LIDARR_URL=http://x.x.x.x:8686
      - LIDARR_API_KEY=LIDARRAPI
      - ARL_TOKEN=ARLTOKEN
      - NOTIFYPLEX=false
      - PLEXLIBRARYNAME=Music
      - PLEXURL=http://x.x.x.x:8686
      - PLEXTOKEN=plextoken
    restart: unless-stopped
```

# Script Information
* Script will automatically run when enabled, if disabled, you will need to manually execute with the following command:
  * From Host CLI: `docker exec -it ama /bin/bash -c 'bash /config/scripts/download.bash'`
  * From Docker CLI: `bash /config/scripts/download.bash`
  
## Directories:
* <strong>/config/scripts</strong>
  * Contains the scripts that are run
* <strong>/config/logs</strong>
  * Contains the log output from the script
* <strong>/config/cache</strong>
  * Contains the artist data cache to speed up processes
* <strong>/config/list</strong>
  * Contains the artist id file's named `deezerid` for processing
* <strong>/config/ignore</strong>
  * Contains the artist id file's named `deezerid` to ignore
* <strong>/config/deemix</strong>
  * Contains deemix app data
  
<br />
<br />
<br />
<br /> 


# Credits
- [Original Idea based on lidarr-download-automation by Migz93](https://github.com/Migz93/lidarr-download-automation)
- [Deemix download client](https://deemix.app/)
- [Lidarr](https://lidarr.audio/)
- [r128gain](https://github.com/desbma/r128gain)
- [Algorithm Implementation/Strings/Levenshtein distance](https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance)
- Icons made by <a href="http://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>

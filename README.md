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
| `-e mode=artist` | artist or discogrpahy :: artist mode downloads all albums listed as that artist, discography downloads all albums listed as that artist and featured in albums |
| `-e RELATED_ARTIST=false` | true = enabled :: Enabling this lets the script crawl your artist list for related artists and process them |
| `-e RELATED_ARTIST_RELATED=false` | true = enabled :: Enabling this lets the script crawl your related artists for additional related artists and process them accordingly :: WARNING this will cause an endless loop (spider crawling) until no more are found... |
| `-e NumberConcurrentProcess=1` | Number of concurrent processes, controls download concurrency and encoding/tagging concurrency |
| `-e Format=FLAC` | SET TO: ALAC or FLAC or AAC or MP3 or OPUS |
| `-e ConversionBitrate=320` | FLAC -> OPUS/AAC/MP3 will be converted using this bitrate |
| `-e replaygain=true` | true = enabled :: Scans and analyzes files to add replaygain tags to song metadata |
| `-e RemoveArtistWithoutImage=false` | true = enabled :: Enabling this will cleanup and remove artist folders that don't contain a unique artist image |
| `-e RemoveDuplicates=true` | true = enabled :: Eanabling this will attempt to remove duplicate clean and duplicate non-deluxe-clean versions of albums/singles/ep" |
| `-e CompleteMyArtists=false` | true = enabled :: Eanabling this will add artist id's found in the library directory that are currently not in your list. This will then allow the script archive them accordingly :: !!!WARNING!!! Could cause an endless loop! |
| `-e FilePermissions=666` | Based on chmod linux permissions |
| `-e FolderPermissions=777` | Based on chmod linux permissions |
| `-e ARL_TOKEN=ARLTOKEN` | User token for dl client, for instructions to obtain token: https://notabug.org/RemixDevs/DeezloaderRemix/wiki/Login+via+userToken |
| `-e LidarrListImport=true` | true = enabled :: imports artist list from lidarr |
| `-e LidarrUrl=http://127.0.0.1:8686` | ONLY used if Lidarr List Import is enabled... |
| `-e LidarrAPIkey=08d108d108d108d108d108d108d108d1` | ONLY used if Lidarr List Import is enabled... |



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

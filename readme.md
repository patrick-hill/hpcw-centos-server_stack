# HPCW Server Stack
This project is serving the purpose of not only getting my work into GitHub for all to see but also to standardize my home environment.
I'm using Puppet at work and find it tedious and am reviewing alternatives such as SaltStack & Ansible. This project will replace a few of my current projects on a taxed FreeNAS server.


## Vagrant Details
---
This is a multi machine vagrant environment creating the following VMs:
* proxy: A proxy server serving as a front for all other VMs
* meida: A media server hosting Movies, TV Shows, Music, Home videos and Pictures
* apps: An application server that will host the various applications (may need to split into 2 VMs)

## Ansible Details
---
This project is serving as my own testbed for Ansible. I've tested SaltStack and feel like Ansible will be a better fit for me. This project forces me to that commitment ;) 

## Software
---
I'm still deciding on the exact software stack but thus far the lists are:

### VM: proxy
* nginx

### VM: media
* plex
* music-streamer (undecided)

### VM: app
* Sabnzbd
* Torrent (Transmission for now)
* CouchPotato
* SickRage
* Headphones
* GitLab (Bambo/Stash: not sure yet)
* ownCloud (may move to own VM w/ git server)


##Complete List of Apps:
* Downloaders
	* SABnzbd (NZB's): http://sabnzbd.org/
	* Transmission (Torrent): http://www.transmissionbt.com/
	* uTorrent (Torrent): http://www.utorrent.com/downloads/linux
	* CouchPotato (Movies): https://couchpota.to/
	* LazyLibrarian (Book): https://github.com/itsmegb/LazyLibrarian
	* Headphones (Music): https://github.com/rembo10/headphones/wiki/Installation
	* SickRage (TV Shows): https://github.com/SiCKRAGETV/SickRage
	* Sonarr (TV Shows): https://sonarr.tv/
	* pyLoad (General Downloader): http://pyload.org/
	* Subliminal (Subtitles): https://github.com/Diaoul/subliminal
	* XDM (ALL): http://xdm.lad1337.de/
* Streamers
	* Plex: (Movie + TV Shows + Music): http://plex.tv
	* Subsonic (Music): http://www.subsonic.org/pages/index.jsp
	* MadSonic (Music: Subsonic Fork): http://beta.madsonic.org/pages/index.jsp
	* BicBucStriim (Book): http://projekte.textmulch.de/bicbucstriim/
* Home Automation
	* Domoticz (Home Automation): https://domoticz.com/
	* Home Assistant: https://home-assistant.io/
* Misc
	* GitLab (Source Control): https://about.gitlab.com/
	* ownCloud (Dropbox): https://owncloud.org/
	* uMurmur (VoIP): https://github.com/umurmur/umurmur

## Resources
* Package Sources: https://synocommunity.com/packages


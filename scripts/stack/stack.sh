#!/usr/bin/env bash

#################################################
#					TODO						#
#################################################
# Guacamole: http://guac-dev.org/
# Subsonic: http://www.subsonic.org/pages/index.jsp
# OwnCloud: https://owncloud.org/
# 


# Script installs the following software if set to true:
install_sabnzdb=true

install_couchpotato=true
install_sickrage=true
install_headphones=true

install_couchpotato=false
install_sickrage=false
install_headphones=false

install_sonarr=false
reboot=false

#################################################
#				PREREQUISITES					#
#################################################

# Stop & Disable Firewall
systemctl disable firewalld.service && systemctl stop firewalld.service
# Disable SELinux
sed -i /etc/selinux/config -r -e 's/^SELINUX=.*/SELINUX=disabled/g'

# Create usenet service account
useradd -r usenet

# Install EPEL repo
yum -y install epel-release

# Install RPMFusion repo
yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm

cat >/etc/yum.repos.d/SABnzbd.repo <<EOL
[SABnzbd]
name=SABnzbd for RHEL 7 and clones - Base
baseurl=https://dl.dropboxusercontent.com/u/14500830/SABnzbd/RHEL-CentOS/7/
failovermethod=priority
enabled=1
gpgcheck=0
EOL

# Install Prereqs
yum -y install wget git par2cmdline p7zip unrar unzip python-yenc python-feedparser python-configobj python-cheetah python-dbus python-support
# Install pyOpenSSL
yum -y install ftp://ftp.muug.mb.ca/mirror/centos/7.1.1503/os/x86_64/Packages/pyOpenSSL-0.13.1-3.el7.x86_64.rpm
yum -y update && reboot



#################################################
#				SABNZDB INSTALL					#
#################################################
if [ install_sabnzdb == true ]; then
	# Create data dir for SABnzbd
	mkdir -p /apps/data/.sabnzbd && cd /apps
	
	git clone https://github.com/sabnzbd/sabnzbd.git sabnzbd   # Download SABnzbd files
	
	chown -R usenet:usenet /apps   # Change ownership of SABnzbd files
	
	# Create systemd service script file
	cat >/etc/systemd/system/sabnzbd.service <<EOL
#
# Systemd unit file for SABnzbd
#

[Unit]
Description=SABnzbd Daemon

[Service]
Type=forking
User=usenet
Group=usenet
ExecStart=/usr/bin/python /apps/sabnzbd/SABnzbd.py --daemon --config-file=/apps/data/.sabnzbd/sabnzbd_config.ini -s 0.0.0.0
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOL

	# Set SABnzbd to start at system boot
	systemctl enable sabnzbd.service
fi


#################################################
#				SICKRAGE INSTALL				#
#################################################
if [ install_sickrage == true ]; then
	# Create data dir for SickRage
	mkdir -p /apps/data/.sickrage && cd /apps
	# Download SickRage files
	git clone https://github.com/SickRage/SickRage.git sickrage
	# Change ownership of SickRage files
	chown -R usenet:usenet /apps
	# Create systemd service script file
	cat >/etc/systemd/system/sickrage.service <<EOL
#
# Systemd unit file for SickRage
#

[Unit]
Description=SickRage Daemon

[Service]
Type=forking
User=usenet
Group=usenet
ExecStart=/usr/bin/python /apps/sickrage/SickBeard.py --daemon --datadir=/apps/data/.sickrage --config=/apps/data/.sickrage/sickrage_config.ini
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOL
	
	# Set SickRage to start at system boot
	systemctl enable sickrage.service
fi


#################################################
#				COUCHPOTATO INSTALL				#
#################################################
if [ install_couchpotato == true ]; then
	# Create data dir for CouchPotatoServer
	mkdir -p /apps/data/.couchpotatoserver && cd /apps
	# Download CouchPotatoServer files
	git clone https://github.com/RuudBurger/CouchPotatoServer.git couchpotatoserver   
	# Change ownership of CouchPotatoServer files
	chown -R usenet:usenet /apps
	# Create systemd service script file
	cat >/etc/systemd/system/couchpotatoserver.service <<EOL
#
# Systemd unit file for CouchPotatoServer
#

[Unit]
Description=CouchPotatoServer Daemon

[Service]
Type=forking
User=usenet
Group=usenet
ExecStart=/usr/bin/python /apps/couchpotatoserver/CouchPotato.py --daemon --data_dir=/apps/data/.couchpotatoserver --config_file=/apps/data/.couchpotatoserver/couchpotatoserver_config.ini --quiet
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOL

	# Set CouchPotatoServer to start at system boot
	systemctl enable couchpotatoserver.service
fi


#################################################
#				HEADPHONES INSTALL				#
#################################################
if [ install_headphones == true ]; then
	# Create data dir for Headphones
	mkdir -p /apps/data/.headphones && cd /apps
	# Download Headphones files
	git clone https://github.com/rembo10/headphones.git headphones
	# Change ownership of Headphones files
	chown -R usenet:usenet /apps
	# Create systemd service script file
	cat >/etc/systemd/system/headphones.service <<EOL
#
# Systemd unit file for Headphones
#

[Unit]
Description=Headphones Daemon

[Service]
Type=forking
User=usenet
Group=usenet
ExecStart=/usr/bin/python /apps/headphones/Headphones.py --daemon --datadir=/apps/data/.headphones --config=/apps/data/.headphones/headphones_config.ini --quiet --nolaunch
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOL 

	# Set Headphones to start at system boot
	systemctl enable headphones.service
fi



#################################################
#				SONARR INSTALL					#
#################################################
if [ install_sonarr == true ]; then
	cat >/etc/yum.repos.d/mono.repo <<EOL
[mono]
name=mono for Centos 7 - Base
baseurl=http://download.mono-project.com/repo/centos/
failovermethod=priority
enabled=1
gpgcheck=0
EOL

	# Additional pre-reqs for Sonarr
	yum -y install mediainfo libzen libmediainfo curl gettext mono-core mono-devel sqlite
	# Create data dir for Sonarr
	mkdir -p /apps/{data/.sonarr,sonarr} && cd /apps
	# Download Sonarr files
	wget http://download.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz
	# Extract Sonarr (NzbDrone) files
	tar -xvf NzbDrone.master.tar.gz
	# Move to sonarr folder, and cleanup after the download
	mv NzbDrone/* sonarr/. && rm -rf NzbDrone*
	# Change ownership of Sonarr files
	chown -R usenet:usenet /apps
	cat >/etc/systemd/system/sonarr.service <<EOL
#
# Systemd unit file for Sonarr
#

[Unit]
Description=Sonarr Daemon

[Service]
Type=simple
User=usenet
Group=usenet
ExecStart=/usr/bin/mono /apps/sonarr/NzbDrone.exe /data=/apps/data/.sonarr
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
EOL

	# Set Sonarr to start at system boot
	systemctl enable sonarr.service
fi

# Reboot for all services to start ;)
if [ reboot == true ]; then
	systemctl reboot
fi

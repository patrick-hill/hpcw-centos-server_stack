#!/usr/bin/env bash

this=`basename "$0"`
useScript=true
if [ $useScript == false ]; then
    echo "Not running script: $this"
    exit 0
fi
echo "Executing Script: $this"

# VBox Fix
sudo ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions

#################################################
#					TODO						#
#################################################
# Guacamole: http://guac-dev.org/
# Subsonic: http://www.subsonic.org/pages/index.jsp
# OwnCloud: https://owncloud.org/
# 


# Script installs the following software if set to true:
install_sabnzbd=true
install_guacamole=false

install_couchpotato=false
install_sickrage=false

install_headphones=false
install_sonarr=false

reboot=true

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
yum -y update



#################################################
#				SABNZDB INSTALL					#
#################################################
if [ $install_sabnzbd == true ]; then
	
	# Create data dir for SABnzbd
	mkdir -p /apps/data/.sabnzbd && cd /apps
	
	# Download SABnzbd files
	git clone https://github.com/sabnzbd/sabnzbd.git sabnzbd
	
	# Change ownership of SABnzbd files
	chown -R usenet:usenet /apps
	
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
if [ $install_sickrage == true ]; then
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
if [ $install_couchpotato == true ]; then
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
if [ $install_headphones == true ]; then
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
if [ $install_sonarr == true ]; then
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

#################################################
#				GUACAMOLE INSTAL				#
#################################################
# https://deviantengineer.com/2015/02/guacamole-centos7/
if [ $install_guacamole == true ]; then
	
	# prerequisites
	# EPEL Repo
	rpm -Uvh http://mirror.metrocast.net/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
	
	# Felfert Repo
	wget http://download.opensuse.org/repositories/home:/felfert/Fedora_19/home:felfert.repo && mv home\:felfert.repo /etc/yum.repos.d/
	# yum -y install wget
	yum -y install tomcat libvncserver freerdp libvorbis libguac libguac-client-vnc libguac-client-rdp libguac-client-ssh \
	cairo-devel pango-devel libvorbis-devel openssl-devel gcc pulseaudio-libs-devel libvncserver-devel terminus-fonts \
	freerdp-devel uuid-devel libssh2-devel libtelnet libtelnet-devel tomcat-webapps tomcat-admin-webapps java-1.7.0-openjdk.x86_64
	
	# guacd install
	mkdir ~/guacamole && cd ~/
	wget http://sourceforge.net/projects/guacamole/files/current/source/guacamole-server-0.9.7.tar.gz
	tar -xzf guacamole-server-0.9.7.tar.gz && cd guacamole-server-0.9.7
	./configure --with-init-dir=/etc/init.d
	make
	make install
	ldconfig
	
	# guacamole client
	mkdir -p /var/lib/guacamole && cd /var/lib/guacamole/
	wget http://sourceforge.net/projects/guacamole/files/current/binary/guacamole-0.9.7.war -O guacamole.war
	ln -s /var/lib/guacamole/guacamole.war /var/lib/tomcat/webapps/
	rm -rf /usr/lib64/freerdp/guacdr.so
	ln -s /usr/local/lib/freerdp/guacdr.so /usr/lib64/freerdp/
	
	# mysql authentication
	yum -y install mariadb mariadb-server
	mkdir -p /home/vagrant/guacamole/sqlauth && cd /home/vagrant/guacamole/sqlauth
	wget http://sourceforge.net/projects/guacamole/files/current/extensions/guacamole-auth-jdbc-0.9.7.tar.gz
	tar -zxf guacamole-auth-jdbc-0.9.7.tar.gz
	wget http://dev.mysql.com/get/Downloads/Connector/j/mysql-connector-java-5.1.32.tar.gz
	tar -zxf mysql-connector-java-5.1.32.tar.gz
	mkdir -p /usr/share/tomcat/.guacamole/{extensions,lib}
	mv guacamole-auth-jdbc-0.9.7/mysql/guacamole-auth-jdbc-mysql-0.9.7.jar /usr/share/tomcat/.guacamole/extensions/
	mv mysql-connector-java-5.1.32/mysql-connector-java-5.1.32-bin.jar /usr/share/tomcat/.guacamole/lib/
	systemctl restart mariadb.service
	
	exit 0
	# TODO FIX THIS!!!
	
	
	# configure database
	mysqladmin -u root password password
	cd ~
	cat >sql.sql <<EOL
create database guacdb;
create user 'guacuser'@'localhost' identified by 'guacDBpass';
grant select,insert,update,delete on guacdb.* to 'guacuser'@'localhost';
flush privileges;
quit
EOL
	# Enter above password
	mysql -u root --password='password' < sql.sql
	# Remove temp file
	rm sql.sql
	
	# extend database schema
	cd /home/vagrant/guacamole/sqlauth/guacamole-auth-jdbc-0.9.7/mysql/schema/
	# Enter SQL root password set above
	cat ./*.sql | mysql -u root --password='password' guacdb   
	
	# configure guacamole
	mkdir -p /etc/guacamole/
	cat >/etc/guacamole/guacamole.properties <<EOL
# MySQL properties
mysql-hostname: localhost
mysql-port: 3306
mysql-database: guacdb
mysql-username: guacuser
mysql-password: guacDBpass

# Additional settings
mysql-disallow-duplicate-connections: false
EOL
	ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat/.guacamole/
	
	# cleanup
	cd ~ && rm -rf guacamole*
	systemctl enable tomcat.service && systemctl enable mariadb.service && chkconfig guacd on
	# systemctl reboot
fi

#################################################
#				SCRIPT END						#
#################################################
# Reboot for all services to start ;)
if [ $reboot == true ]; then
	systemctl reboot
fi

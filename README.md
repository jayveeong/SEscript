# SEscript

# Prerequisites.

Virtual Private Server

Ubuntu 16.04 x64 or Debian 8.10 x64

Root privilege

# Input this code and wait to finish.

wget https://git.io/vhZF8 && chmod +x SEautoscript.sh && ./SEautoscript.sh

Enter Server IP:

Set Virtual Hub:

Set Hub username:

Set Hub password:

Set SE server password:


# Installation & Configuration of DNSmasq for a DHCP.

apt-get install dnsmasq

nano /etc/dnsmasq.conf

# Edit /etc/dnsmasq.conf and add these lines at the end :

interface=tap_tapvpn

dhcp-range=tap_tapvpn,192.168.7.50,192.168.7.60,12h

dhcp-option=tap_tapvpn,3,192.168.7.1

port=0 

dhcp-option=option:dns-server,208.67.222.222,208.67.220.220

# Add the file ipv4_forwarding.conf in the directory /etc/sysctl.d/ with the line net.ipv4.ip_forward = 1, just copy and paste the below line, it will create the file automatically :

echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/ipv4_forwarding.conf

to check : 

nano -w /etc/sysctl.d/ipv4_forwarding.conf

nano -w /etc/sysctl.conf

# Type the command to enable it :
sysctl --system

# Restart VPNserver & DNSmasq service :

service dnsmasq restart && service vpnserver restart

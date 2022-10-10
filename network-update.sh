#!/bin/sh

echo "Enter password for CreativeSolutions email."

read cs_password

sudo touch /etc/NetworkManager/system-connections/eduroam.nmconnection

sudo cat /etc/NetworkManager/system-connections/eduroam.nmconnection << EOF
[connection]
id=eduroam
uuid=6b1d86bc-aaaf-468f-a134-eb6dad0c693a
type=wifi
interface-name=wlp1s0

[wifi]
mode=infrastructure
ssid=eduroam

[wifi-security]
auth-alg=open
key-mgmt=wpa-eap

[802-1x]
eap=peap;
identity=creativesolutions@cedarville.edu
password=$cs_password
phase2-auth=mschapv2

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
EOF

sudo chmod 600 /etc/NetworkManager/system-connections/eduroam.nmconnection
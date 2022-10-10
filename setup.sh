#!/bin/bash

echo "A Product of Creative Solutions Group"
echo

echo "Attempting to setup the terminal application."
echo "Assuming there is no git key installed on GitHub."
echo
echo

git clone https://github.com/CreativeSolutionsGroup/smart-events-terminal-app.git ../app

echo "WARNING---- This script will now install all dependencies from apt."
echo "Waiting for five seconds."
sleep 5

(crontab -l ; echo "* * * * * git -C /home/kiosk/smart-events-terminal-app pull") | crontab -

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y nodejs npm

echo "Removing the network daemon setup."
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

# We can do this no matter what... doesn't really matter.
echo "cd ~/app && npm run dev" >> ~/.bashrc

SYSTEMD_EDITOR=tee sudo systemctl edit getty@tty1 << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -a kiosk --noclear %I $TERM
EOF

echo "Enter password for CreativeSolutions email."

read cs_password

sudo cat /etc/NetworkManager/system-connections/eduroam.nmconnection << EOF
[connection]
id=eduroam
uuid=6b1d86bc-aaaf-468f-a134-eb6dad0c693a
type=wifi
interface-name=enp0s31f6

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

cd ../app

echo "Input the backend URL (http://localhost:3001/v1):"

read backend_url

echo "Input the heartbeat URL (ws://localhost:3001):"

read heartbeat_url

echo BACKEND_URL=$backend_url >> .env
echo HEARTBEAT_URL=$heartbeat_url >> .env

npm i
#!/bin/bash

echo "A Product of Creative Solutions Group"
echo

echo "Attempting to setup the terminal application."
echo "Assuming there is no git key installed on GitHub."
echo
echo

curl https://github.com/CreativeSolutionsGroup/smart-events-rust-terminal/releases/download/v0.1.0/terminal_app_linux ./app

echo "WARNING---- This script will now install all dependencies from apt."
echo "Waiting for five seconds."
sleep 5

#(crontab -l ; echo "* * * * * git -C /home/kiosk/smart-events-terminal-app pull") | crontab -

sudo apt update -y && sudo apt upgrade -y

echo "Removing the network daemon setup."
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

sudo npm install -g pm2 n

sudo n stable

# We can do this no matter what... doesn't really matter.
sed -i '$ d' ~/.bashrc
echo "cd ~/app && pm2 start build/main.js --error ~/logs/error.\$(date +'%F_%H_%M').log && pm2 attach 0" >> ~/.bashrc

echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -a kiosk --noclear %I $TERM" | sudo SYSTEMD_EDITOR=tee systemctl edit getty@tty1
. network-update.sh

app

echo "Input the proxy URL (http://localhost:9951):"

read proxy_url

echo PROXY_URL=$proxy_url >> .env

npm i
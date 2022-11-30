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

sudo npm install -g pm2

# We can do this no matter what... doesn't really matter.
echo "cd ~/app && pm2-runtime start 'npm run dev' --watch" >> ~/.bashrc

echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -a kiosk --noclear %I $TERM" | sudo SYSTEMD_EDITOR=tee systemctl edit getty@tty1
. network-update.sh

cd ../app

echo "Input the backend URL (http://localhost:3001/v1):"

read backend_url

echo "Input the heartbeat URL (ws://localhost:3001):"

read heartbeat_url

echo BACKEND_URL=$backend_url >> .env
echo HEARTBEAT_URL=$heartbeat_url >> .env

npm i
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

sudo apt update && sudo apt upgrade

sudo apt install nodejs npm

echo "Removing the network daemon setup."
systemctl disable systemd-networkd-wait-online.service
systemctl mask systemd-networkd-wait-online.service

echo "if [[ "$(tty)" == "/dev/tty1" ]]
then
    cd ~/app && npm run dev
fi" >> ~/.bashrc

SYSTEMD_EDITOR=tee systemctl edit getty@tty1 << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -a kiosk --noclear %I $TERM
EOF

cd ../app

echo "Input the backend URL (http://localhost:3001/v1):"

read backend_url

echo "Input the heartbeat URL (ws://localhost:3001):"

read heartbeat_url

echo BACKEND_URL=$backend_url >> .env
echo HEARTBEAT_URL=$heartbeat_url >> .env

npm i
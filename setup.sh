#!/bin/bash

echo "A Product of Creative Solutions Group"
echo

echo "Attempting to setup the terminal application."
echo "Assuming there is no git key installed on GitHub."
echo
echo

cd ..

wget https://github.com/CreativeSolutionsGroup/smart-events-rust-terminal/releases/download/v0.1.2/terminal_app
chmod +x terminal_app

echo "Removing the network daemon setup."
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

echo -e "until ./terminal_app; do\nsleep 1\ndone" >> .bashrc

echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -a kiosk --noclear %I $TERM" | sudo SYSTEMD_EDITOR=tee systemctl edit getty@tty1
. network-update.sh

echo "Input the heartbeat URL (tcp://proxy.localhost:3001):"
read proxy_url

sudo echo PROXY_URL=$proxy_url >> /etc/environment


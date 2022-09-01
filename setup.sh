#!/bin/bash

echo "A Product of Creative Solutions Group"
echo

echo "Attempting to setup the terminal application."
echo "Assuming there is no git key installed on GitHub."
echo
echo

git clone https://github.com/CreativeSolutionsGroup/smart-events-terminal-app.git app

echo "WARNING---- This script will now install all dependencies from apt."
echo "Waiting for five seconds."
sleep 5

sudo apt update && sudo apt upgrade

sudo apt install nodejs npm
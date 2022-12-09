#!/usr/bin/env bash

echo "A Product of Creative Solutions Group"
echo

echo "Attempting to setup the terminal application."
echo "Assuming there is no git key installed on GitHub."

#(crontab -l ; echo "* * * * * git -C /home/kiosk/smart-events-terminal-app pull") | crontab -

install_dependencies () {
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y nodejs npm
  sudo npm install -g pm2 n
  sudo n stable
}

optimize () {
  echo "Removing the network daemon setup."
  sudo systemctl disable systemd-networkd-wait-online.service
  sudo systemctl mask systemd-networkd-wait-online.service
}

setup_app () {
  git clone https://github.com/CreativeSolutionsGroup/smart-events-terminal-app.git ../app
  # Add startup script
  sed -i '$ d' ~/.bashrc
  echo "cd ~/app && pm2 start build/main.js --error ~/logs/error.\$(date +'%F_%H_%M').log && pm2 attach 0" >> ~/.bashrc

  # Autologin
  echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -a kiosk --noclear %I \$TERM" | sudo SYSTEMD_EDITOR=tee systemctl edit getty@tty1

  # Build app
  cd ../app
  npm run build
}

prompt_network_update () {
  echo "Enter password for CreativeSolutions email."

  read cs_password

  sudo touch /etc/NetworkManager/system-connections/eduroam.nmconnection

  sudo bash -c "cat << EOF > /etc/NetworkManager/system-connections/eduroam.nmconnection
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
  EOF"

  sudo chmod 600 /etc/NetworkManager/system-connections/eduroam.nmconnection
  sudo systemctl restart NetworkManager 
  sudo nmcli con up eduroam
}

prompt_env () {
  echo "Input the backend URL (http://localhost:3001/v1):"

  read backend_url

  echo "Input the heartbeat URL (ws://localhost:3001):"

  read heartbeat_url

  echo BACKEND_URL=$backend_url >> .env
  echo HEARTBEAT_URL=$heartbeat_url >> .env
}

full_setup () {
  echo "Running full setup."
  install_dependencies
  optimize
  setup_app

  prompt_network_update
  prompt_env
}

select op in "install" "setup" "network" "env" "full" "exit"; do
    case $op in
        install ) install_dependencies; break;;
        setup ) setup_app; break;;
        network ) prompt_network_update; break;;
        env ) prompt_env; break;;
        full ) full_setup; break;;
        exit ) exit;;
    esac
done

npm i
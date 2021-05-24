#!/bin/bash

menu_from_array ()
{
  select item; do
    # Check the selected menu item number
    if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $# ];

    then
      #echo $item
      SELECTION=$item
      break
    else
      echo "Wrong selection: Select any number from 1-$#"
    fi
  done
}

editable_read ()
{
  commands=("$@")
  for i in "${!commands[@]}"
  do
    iter=$((i+1))
  	#printf "%s\t%s\n" "$iter/$#" "${commands[$i]}"
    read -e -p "${bold}(edit command) $iter/$# > ${normal}" -i "${commands[$i]}" command_edited
    eval $command_edited
  done
}

bold=$(tput bold)
normal=$(tput sgr0)
standout=$(tput smso)

while :
do
  # Call the subroutine to create the menu
  echo
  echo "${bold}Host control: ${standout}$HOSTNAME${normal}"
  options=( \
    'exit' \
    'reboot' \
    'shutdown' \
    'install-updates' \
    'install wget curl git gcc' \
    'change hostname' \
    'getIP' \
    'list directory sizes' \
    'ssh-keygen' \
    'update host-control.sh' \
    'install sudo' \
    'disable sudo pw' \
    'ufw allow' \
    'edit-ssh-config' \
    'deb10 fish shell' \
    'create alias hc (fish)' \
  )
  menu_from_array "${options[@]}"
  OPTION=$SELECTION
  echo -e "---> Selected Option: \e[38;5;0;48;5;255m$OPTION\e[0m "
  echo
  case $OPTION in
    'exit')
      break
      ;;
    'reboot')
      editable_read "sudo reboot"
      ;;
    'shutdown')
      editable_read "sudo shutdown now"
      ;;
	'ssh-keygen')
	  editable_read "ssh-keygen -t ed25519 -C \"\""
      ;;
    'install-updates')
      commands=('sudo apt-get update' 'sudo apt-get upgrade -y')
      editable_read "${commands[@]}"
      ;;
    'install wget curl git gcc')
      editable_read "sudo apt-get install wget curl git build-essential -y"
      ;;
    'change hostname')
      commands=('sudo nano /etc/hostname' 'sudo nano /etc/hosts')
      editable_read "${commands[@]}"
      ;;
    'update host-control.sh')
      commands=('git clone https://github.com/dforrer/host-control.git' 'cp ./host-control/host-control.sh ./' 'rm -rf host-control')
      editable_read "${commands[@]}"
      ;;
    'getIP')
      editable_read "ip a|grep 'inet 192.168.0'"
      ;;
    'list directory sizes')
      editable_read "du -h --max-depth 1 ."
      ;;
    'edit-ssh-config')
      editable_read "sudo nano /etc/ssh/sshd_config"
      ;;
    'install sudo')
      printf "${bold}(run the commands) > ${normal}"
      printf "su -\n"
      printf "${bold}(run the commands) > ${normal}"
      printf "apt-get install sudo\n"
      printf "${bold}(run the commands) > ${normal}"
      printf "usermod -aG sudo linux\n"
      editable_read "su -"
      ;;
    'disable sudo pw')
      printf "${bold}(replace this line)> ${normal}"
      printf "%%sudo   ALL=(ALL:ALL) ALL\n"
      printf "${bold}(with this line)   > ${normal}"
      printf "%%sudo   ALL=(ALL:ALL) NOPASSWD: ALL\n"
      editable_read "sudo nano /etc/sudoers"
      ;;
    'ufw allow')
      editable_read "sudo ufw allow from 192.168.0.0/24 to any port 5900"
      ;;
    'create alias hc (fish)')
      editable_read "alias hc='/bin/bash /home/linux/host-control.sh'"
      printf "${bold}(run this command) > ${normal}"
      printf "funcsave hc\n"
      ;;
    'deb10 fish shell')
      commands=( \
        "sudo apt update" \
        "sudo apt-get install gnupg -y" \
        "echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_10/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list" \
        "curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells:fish:release:3.gpg > /dev/null" \
        "sudo apt update" \
        "sudo apt install fish" \
        "chsh -s /usr/bin/fish" \
      )
      editable_read "${commands[@]}"
      ;;
  esac
done

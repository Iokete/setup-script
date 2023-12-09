#!/bin/bash

# Color Codes
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

# Variables
user=$SUDO_USER
nvim_flag=0 
pwn_flag=0 
wall_flag=0 
lsdb_flag=0 
all_flag=0

trap ctrl_c INT 

function ctrl_c(){
  echo -e "$red[!]$end${gray} Exiting...$end\n"
  exit 1
}


function lsdbat_install(){
  echo -e "$yellow[+]$end$gray Installing lsd and batcat...$end"
  sleep 1
  sudo apt install bat
  sudo apt install lsd
  sed -i '/alias cat="batcat"/d' /home/$user/.zshrc 2>/dev/null
  sed -i '/alias ls="lsd"/d' /home/$user/.zshrc 2>/dev/null
  echo 'alias cat="batcat"' >> /home/$user/.zshrc
  echo 'alias ls="lsd"' >> /home/$user/.zshrc
  clear
  echo -e "$green[*]$end$gray Done! added ls and cat alias to /home/$user/.zshrc  \n$end"
}

function nvim_install(){
  echo -e "$yellow[+]$end$gray Setting up nvim...$end"
  sleep 1
  wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
  7z x nvim-linux64.tar.gz
  7z x nvim-linux64.tar -o/opt/
  rm nvim-linux64.tar.gz
  rm nvim-linux64.tar
  mv /opt/nvim-linux64 opt/nvim
  chmod +xr -R /opt/nvim
  insert=$(cat /home/$user/.zshrc | grep "export PATH" | grep -v nvim | head -n 1)
  if [ "insert" ]; then
    echo "$insert:/opt/nvim/bin" >> /home/$user/.zshrc
  else
    echo "export PATH=$PATH:/opt/nvim/bin" >> /home/$user/.zshrc
  fi
  sudo -u $user git clone https://github.com/NvChad/NvChad /home/$user/.config/nvim --depth 1 
  clear



  echo -e "$yellow[+]$end$gray Setting up font...$end"
  sleep 1
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip
  mv Hack.zip /usr/share/fonts
  7z x /usr/share/fonts/Hack.zip -o /usr/share/fonts/
  fc-cache -fv


  echo -e "$green[*]$end$gray Done! Run nvim to finish installation. $end\n"
  sleep 1
  clear
}

function wallpapers(){
  echo -e "$yellow[+]$end$gray Downloading wallpapers...$end"
  sleep 1
  git clone https://github.com/owerdogan/wallpapers-for-kali /home/$user/Pictures
  clear

  echo -e "\n$green[*]$end$gray Done! Saved wallpapers at /home/$user/Pictures$end\n"
  sleep 1

}


function pwn_install(){
  echo -e "\n$yellow[+]$end$gray Setting up pwndbg and pwntools...$end"
  sleep 1 

  sudo apt install python3-pwntools

  [ ! -d /home/$user/repos ] && mkdir /home/$user/repos/

  sudo -u $user git clone https://github.com/pwndbg/pwndbg /home/$user/repos/
  sh /home/$user/repos/pwndbg/setup.sh
  clear

  echo -e "\n$green[*]$end$gray Done! GDB pwndbg and pwntools are now setup. $end\n"
  sleep 1
}

function help_panel(){
  echo -e "$yellow[*]$end$gray Usage: ./setup.sh <param> $end"
  echo -e "\t${purple}-n$end$gray\t Install Nvim with NvChad. $end"
  echo -e "\t${purple}-p$end$gray\t Install pwntools and gdb pwndbg. $end"
  echo -e "\t${purple}-l$end$gray\t Install lsd and batcat. $end"
  echo -e "\t${purple}-w$end$gray\t Download some wallpapers. $end"
  echo -e "\t${purple}-a$end$gray\t Full install. $end"
  echo -e "\t${purple}-h$end$gray\t Show the help panel. $end"
  echo -e "$red[!]$end$gray DISCLAIMER: This script must be executed with sudo, but every git clone that it executes will be done as the user. $end"
  exit 1
}


if [ $EUID -eq 0 ]
then
  while getopts "nplwha" arg; do 
    case "$arg" in
      n) nvim_flag=1 #nvim_install
      ;;
      p) pwn_flag=1 #pwn_install
      ;;
      l) lsdb_flag=1 #lsdbat_install
      ;;
      w) wall_flag=1 #wallpapers 
      ;;
      a) all_flag=1 #full_install
      ;;
      *) ;;
    esac
  done

  check=$nvim_flag+$pwn_flag+$lsdb_flag+$wall_flag+$all_flag

  if [[ $check -ne 1 ]] || [[ "$OPTIND" -eq 1 ]]; then
    help_panel
  else
    sudo apt update
    clear
    if [ "$nvim_flag" -eq 1 ]; then
      nvim_install
    elif [ "$pwn_flag" -eq 1 ]; then
      pwn_install
    elif [ "$lsdb_flag" -eq 1 ]; then
      lsdbat_install
    elif [ "$wall_flag" -eq 1 ]; then
      wallpapers
    elif [ "$all_flag" -eq 1 ]; then
      nvim_install
      pwn_install
      lsdbat_install
      wallpapers
    fi
    echo -e "$turquoise[*]$end$gray Bye! $end\n"
    exit 0
  fi

else
  echo -e "$yellow[-]$end$gray This is script must be run as sudo.$end"
  help_panel
fi
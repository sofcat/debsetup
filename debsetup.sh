#!/usr/bin/env bash

if [ $(id -u) -ne 0 ]; then
	echo "You must run this script as the root user!" > /dev/stderr
	exit 1
fi

read -p "Use unstable deb.debian.org repo? [Y/n] " boolMirror

if [[ ! boolMirror =~ ^[Nn] ]]; then
	echo "Adding mirrors..."
	echo -e "## DEBIAN SOURCES ##\ndeb http://deb.debian.org/debian/ unstable main contrib non-free\ndeb-src http://deb.debian.org/debian/ unstable main contrib non-free" > /etc/apt/sources.list
else
	declare -a mirrors
	declare urlBuf # buffer to copy to mirror array
	echo -e "Enter your mirrors, to quit adding type \"quit\"\nIf no mirrors are provided then no changes to sources.list will be made"
	read urlBuf # must read from it once outside of loop so user can quit immediately
	# use until loops so loop will quit as soon as the user tells it to
	until [[ $urlBuf == "quit" ]]; do
		mirrors=("${mirrors[@]}" "$urlBuf")
		read urlBuf
	done

	if [[ ${#mirrors} != 0 ]]; then
		echo "Overwritting mirrors with provided ones..."
		printf "## DEBIAN SOURCES ##\n" > /etc/apt/sources.list
		for (( i = 0; i < ${#mirrors}; i++ )); do
			printf "${mirrors[i]}\n" >> /etc/apt/sources.list
		done
	else
		echo "No mirrors provided... using defaults"
	fi
fi

echo "Updating sources..."
apt-get update
read -p "Upgrade the system? [Y/n]" boolUpdate
if [[ boolUpdate =~ ^[Nn] ]]; then
	echo "Skiping..."
else
	apt-get dist-upgrade
fi

programs=("sudo" "vim" "wget" "curl" "build-essentials" "mpv" "htop" "python3")

# TODO: allow user to add/remove programs from the list

apt-get install ${programs[@]}

read -p "Reboot the system? [y/N]" boolReboot
if [[ $boolReboot -eq 'y' || $boolReboot -eq 'Y' ]]; then
	echo "Rebooting in 60 seconds"
	shutdown -r
else
	echo "Finshed"
fi
# TODO: if Xorg is not installed prompt user to install

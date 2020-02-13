#!/usr/bin/env bash

nginxdir="/var/www/html"
gitproject="https://github.com/c0decrow/netmon-telegram-bot.git"
project="monitor"

func_python() {
	if command -v python -V >/dev/null; then
		$green; echo -e "\n  * Python already Installed"; $reset
	else
		$red; echo -e "\n  * Python not installed"
		$yellow; echo -e "\n  * Would you lnike to install it(y/n)? (must be root)"; $reset
		read answer
		if [ "$answer" == "y" ]; then
			if is_root; then
				apt-get update
				apt-get install python -y
			else
				:
			fi
		elif [ "$answer" == "n" ]; then
			$red; echo -e "\n  * Python needs to be installed before continuing. Exiting..."; $reset
			exit 1
		else
			$red; echo -e "\n  * Unrecognized input. Bye"; $reset
			exit 1
		fi
	fi
	
    sleep 1
	
	if command -v pip --version >/dev/null; then
		$green; echo -e "\n  * Pip already Installed"; $reset
	else
		$red; echo -e "\n  * Pip not installed"
		$yellow; echo -e "\n  * Would you like to install it(y/n)? (must be root)"; $reset
		read answer
		if [ "$answer" == "y" ]; then
			if is_root; then
				apt-get update
				apt-get install python-pip -y
			else
				:
			fi
		elif [ "$answer" == "n" ]; then
			$red; echo -e "\n  * Pip needs to be installed before continuing. Exiting..."; $reset
			exit 1
		else
			$red; echo -e "\n  * Unrecognized input. Bye"; $reset
			exit 1
		fi
    fi
	
	sleep 1
	
	echo -e "\n  * Checking pip packet 'Jinja2':"
	pip show Jinja2
	if [[ $? == 1 ]]; then
		$red; echo -e "\n  * Jinja2 not installed"
		$yellow; echo -e "\n  * Would you like to install it(y/n)? (must be root)"; $reset
		read answer
		if [ "$answer" == "y" ]; then
			if is_root; then
				echo -e "\n  * Installing pip packet 'Jinja2':"
				pip install jinja2
			else
				:
			fi
		elif [ "$answer" == "n" ]; then
			$red; echo -e "\n  * Jinja2 needs to be installed before continuing. Exiting..."; $reset
			exit 1
		else
			$red; echo -e "\n  * Unrecognized input. Bye"; $reset
			exit 1
		fi
	else
		$green; echo -e "\n  * 'Jinja2' found!"; $reset
	fi
	
	sleep 1
	
	echo -e "\n  * Checking pip packet 'requests':"
	pip show requests
	if [[ $? == 1 ]]; then
		$red; echo -e "\n  * requests not installed"
		$yellow; echo -e "\n  * Would you like to install it(y/n)? (must be root)"; $reset
		read answer
		if [ "$answer" == "y" ]; then
			if is_root; then
				echo -e "\n  * Installing pip packet 'requests':"
				pip install requests
			else
				:
			fi
		elif [ "$answer" == "n" ]; then
			$red; echo -e "\n  * Jinja2 needs to be installed before continuing. Exiting..."; $reset
			exit 1
		else
			$red; echo -e "\n  * Unrecognized input. Bye"; $reset
			exit 1
		fi
	else
		$green; echo -e "\n  * 'requests' found!"; $reset
	fi
}

func_nginx() {
	if command -v nginx >/dev/null; then
		$green; echo -e "\n  * Nginx already Installed"; $reset
	else
		$red; echo -e "\n  * Nginx not installed"
		$yellow; echo -e "\n  * Would you like to install it(y/n)? (must be root)"; $reset
		read answer
		if [ "$answer" == "y" ]; then
			if is_root; then
				apt-get update
				apt-get install nginx -y
			else
				:
			fi
		elif [ "$answer" == "n" ]; then
			$red; echo -e "\n  * Nginx needs to be installed before continuing. Exiting..."; $reset
			exit 1
		else
			$red; echo -e "\n  * Unrecognized input. Bye"; $reset
			exit 1
		fi
	fi
	
	if [ -d $nginxdir ]; then
		$green; echo -e "\n  * Nginx installed and Nginx directory detected"
		echo -e "\n  * Cloning project in 5 seconds"; $reset; echo
		sleep 5
		git clone $gitproject $nginxdir/$project
		chmod -R 755 $nginxdir/$project
	else
		$red; echo -e "\n  * ${nginxdir} not found"
		sleep 3
		echo -e "\n  * Exiting..."; $reset
		sleep 2
		exit 1
	fi
}

is_root() {
	if [ "$(id -u)" != "0" ]; then
		$red; echo -e "\n  * Must be root to install packages..."; $reset
		exit 1
	else
		return 0
	fi
}

if_ubuntu() {
	if command -v apt-get >/dev/null; then
		apt-get update apt-get >/dev/null
	else
		$red; echo -e "\n  * This script only works on debian/ubuntu."; $reset
		exit 1
	fi
}

##############
# Begin Script
##############
red="tput setaf 1"
green="tput setaf 2"
yellow="tput setaf 3"
reset="tput sgr0"

if_ubuntu

$green
echo "#########################################"
echo "#   NetMon-Telegram-Bot Easy Install    #"
echo "#########################################"
echo
$yellow
echo "Python, Python-pip and Nginx are required to deploy NetMon-Telegram-Bot via Easy-Install."
echo "This script can install packages for you, but you must be root."
echo "Alternatively, you can use docker, please see https://github.com/c0decrow/netmon-telegram-bot"
echo
sleep 3
$reset

if is_root; then
	$green; echo -e "\n  * You are running as root"; $reset
else
	$red; echo -e "\n  * You are not root"
	echo -e "\n  * You are $(whoami)"; $reset
fi

func_python
sleep 5

$green
echo -e "\n  * Deploying with Nginx..."
func_nginx
$reset

$green; echo -e "\n  * You're all set! Installation Completed successfully"; $reset

$green
echo -e "\n  * You will need to go to $nginxdir/$project and run \"python report.py\""
echo -e "  * I suggest starting the script inside a screen terminal (apt-get install screen)\n"
echo -e "  * Dashboard URL after starting: http://<your_IP>/monitor"
echo -e "  * Update the devices you would like to monitor by editing $nginxdir/$project/hostnames.json \n"; $reset

exit 0

#!/bin/bash

#Info: Installs Sanity daemon, Masternode based on privkey
#Tested OS: 16.04
#get the script:
# wget https://raw.githubusercontent.com/sanatorium/sanity-scripts/master/install-sanitymn.sh
# chmod +x -v ./install-sanitymn.sh
# ./install-sanitymn.sh

NEWUSER=sanitycore
COINGITHUB=https://github.com/sanatorium/sanity.git
COINDIR=sanity-src
COINBIN=sanity-bin
COINCORE=.sanitycore
COINCONFIG=sanity.conf
COINPORT=9999
COINRPCPORT=9998
COINDAEMON=sanityd
COINCLI=sanity-cli

MAX=14

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

message() {
	echo -e "${NONE}*** ${GREEN} $1 ${NONE}"
}

messagebig() {
	echo -e "${YELLOW}"
	echo -e "********************************************************************"
	echo -e "********************************************************************"
	echo -e "***"
	echo -e "*** ${GREEN} $1 ${CYAN}"
	echo -e "***"
	echo -e "********************************************************************"
	echo -e "********************************************************************"
	echo -e "${NONE}"
	sleep 2s
}

error() {
	echo -e "${RED}"
	echo -e "********************************************************************"
	echo -e "***"
	echo -e "*** An error occured, you must fix it to continue!"
	echo -e "***"
	echo -e "*** ${RED} $1 ${RED}"
	echo -e "***"
	echo -e "********************************************************************"
	echo -e "${NONE}"
	exit 1
}

checkForUbuntuVersion() {
   messagebig "Checking Ubuntu version..."
    if [[ `cat /etc/issue.net` == *16.04* ]]; then
        echo -e "${GREEN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
    else
        echo -e "${RED}* You are not running Ubuntu 16.04.X. You are running `cat /etc/issue.net` ${NONE}";
		echo -e "${BOLD}"
		read -p "Continue anyway? (y/n)? " response
		echo -e "${NONE}"

		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
			echo && echo "Trying to install on untested system configuration." && echo;
		else
	        echo && echo "Installation cancelled." && echo;
	        exit;
		fi
    fi
}

createUser() {
	messagebig "[Step 1/${MAX}] createUser: Create new user account '${NEWUSER}'"
	echo -e "${BOLD}"
	read -p "Create a new user-account ${NEWUSER}? (y/n)? " response
	echo -e "${NONE}"

	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
		message "Switching to root user. Enter your root password.";
		su

		message "Choose a password for your new user-account.";
		adduser $NEWUSER
		if [ $? -ne 0 ]; then error "createUser: adduser ${NEWUSER}"; fi
		#if [ $? -ne 0 ]; then error; sudo deluser $NEWUSER; rm -rf /home/$NEWUSER; fi

		usermod -aG sudo $NEWUSER
		if [ $? -ne 0 ]; then error "createUser: usermod -aG sudo ${NEWUSER}"; fi
		#if [ $? -ne 0 ]; then error; sudo deluser $NEWUSER; rm -rf /home/$NEWUSER; fi

		message "Checking account directory /home/${NEWUSER}.";
		ls /home/$NEWUSER

		message "Switching to new account.";
		su - $NEWUSER
		if [ $? -ne 0 ]; then error "createUser: su - ${NEWUSER}"; fi
		#if [ $? -ne 0 ]; then error; sudo deluser $NEWUSER; rm -rf /home/$NEWUSER; fi
	else
	    echo && echo "Creating new user skipped." && echo
	fi

	messagebig "[Step 1/${MAX}] createUser: Done.'${NEWUSER}'"
}

updateAndUpgrade() {
	messagebig "[Step 2/${MAX}] updateAndUpgrade: Running update and upgrade."

	sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y
	sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq

	messagebig "[Step 2/${MAX}] updateAndUpgrade: Done.";
}

installDependencies() {
	messagebig "[Step 3/${MAX}] installDependencies: Installing dependencies."

	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

	#build requirements
	message "Installing build requirements.";
	sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils

	#boost
	message "Installing boost.";
	sudo apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
	##not working -> sudo apt-get install libboost-all-dev

	#db4.8
	message "Installing db4.8.";
	sudo apt-get install -y software-properties-common
	sudo add-apt-repository ppa:bitcoin/bitcoin
	sudo apt-get update -y
	sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

	#zqm
	message "Installing zqm.";
	sudo apt-get install -y libzmq3-dev

	#qt5
	message "Installing qt5.";
	sudo apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler

	#git
	message "Installing git.";
	sudo apt install -y git

	#crlf to lf converter
	message "Installing sod2unix.";
	sudo apt-get install -y dos2unix

	#echo
	#echo -e "[5/${MAX}] Installing dependencies. Please wait..."
	#sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libboost-all-dev autoconf automake -qq -y > /dev/null 2>&1
	#sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -qq -y > /dev/null 2>&1
	#sudo apt-get install libgmp-dev -qq -y > /dev/null 2>&1
	#sudo apt-get install openssl -qq -y > /dev/null 2>&1
	#sudo apt-get install software-properties-common -qq -y > /dev/null 2>&1
	#sudo add-apt-repository ppa:bitcoin/bitcoin -y > /dev/null 2>&1
	#sudo apt-get update -qq -y > /dev/null 2>&1
	#sudo apt-get install libdb4.8-dev libdb4.8++-dev -qq -y > /dev/null 2>&1
	#echo -e "${NONE}${GREEN}* Done${NONE}";

	#install deps
	##sudo apt-get install dos2unix curl git ufw
	##sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
	##sudo apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
	##sudo apt-get install -y software-properties-common
	##sudo add-apt-repository -y ppa:bitcoin/bitcoin
	##sudo apt-get update

	##sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
	##sudo apt-get install -y libzmq3-dev
	##sudo apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
	##sudo apt-get install -y libqrencode-dev
	##sudo apt-get update
	##sudo apt-get -y upgrade

	#sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git software-properties-common
	#sudo add-apt-repository -y ppa:bitcoin/bitcoin
	#sudo apt-get update
	#sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
	messagebig "[Step 3/${MAX}] installDependencies: Done."
}

installFail2Ban() {
	messagebig "[Step 4/${MAX}] installFail2Ban: Installing fail2ban."

	message "Installing fail2ban.";
    sudo apt-get -y install fail2ban

	message "Enable fail2ban.";
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban

	messagebig "[Step 4/${MAX}] installFail2Ban: Done."
}

installFirewall() {
	messagebig "[Step 5/${MAX}] installFirewall: Installing ufw firewall."

	message "Installing ufw firewall.";
    sudo apt-get -y install ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
	message "Installing ufw firewall: enable ssh.";
    sudo ufw allow ssh
    sudo ufw limit ssh/tcp
	message "Installing ufw firewall: enable coinports.";
    sudo ufw allow $COINPORT/tcp
    sudo ufw allow $COINRPCPORT/tcp
	message "Installing ufw firewall: enable logging.";
    sudo ufw logging on
    echo "y" | sudo ufw enable

	messagebig "[Step 5/${MAX}] installFirewall: Done."
}

createSwap() { #TODO: add error detection
	messagebig "[Step 6/${MAX}] createSwap: Creating 2GB temporary swap file."

	sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
	sudo mkswap /swapfile
	sudo chown root:root /swapfile
	sudo chmod 0600 /swapfile
	sudo swapon /swapfile

	#optional: make swap permanent
	##sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab

	messagebig "[Step 6/${MAX}] createSwap: Done."
}

cloneGithub() {
	messagebig "[Step 7/${MAX}] cloneGithub: Cloning Sanity source from sanity-master repository."

	message "Cloning source from ${COINGITHUB} to ${COINDIR}."
	cd ~/
	git clone $COINGITHUB $COINDIR
	if [ $? -ne 0 ]; then error "cloneGithub: git clone ${COINGITHUB} ${COINDIR}"; fi

	messagebig "[Step 7/${MAX}] cloneGithub: Done."
}

removeWindowsLinefeeds() {
	messagebig "[Step 8/${MAX}] removeWindowsLinefeeds: Normalizing linefeeds to LF."

	#cd /home/$NEWUSER/$COINDIR
	cd ~/$COINDIR
	find . -type f -not -path '*/\.*' -exec grep -Il '.' {} \; | xargs -d '\n' -L 1 sudo dos2unix -k

	messagebig "[Step 8/${MAX}] removeWindowsLinefeeds: Done."
}

patchTimestamps() {
	messagebig "[Step 8/${MAX}] patchTimestamp: Adjusting Timestamps."

	#cd /home/$NEWUSER/$COINDIR
	cd ~/$COINDIR
	find . -type f | xargs -n 5 touch

	messagebig "[Step 8/${MAX}] patchTimestamp: Done."
}

compileSource() {
	messagebig "[Step 9/${MAX}] compileSource: Building Sanity."

	message "Preparing to build Sanity."
	cd ~/$COINDIR/src/leveldb && make clean && make libleveldb.a libmemenv.a
	if [ $? -ne 0 ]; then error "compileSource: leveldb"; fi

	#message "Building Sanity: sudo depends/sudo make"
	#cd ~/$COINDIR/depends
	#on "sudo make" error::: make: execvp: ./config.guess: Permission denied
	#sudo chmod 755 -v config.guess && sudo chmod +x -v config.sub
	#make

	message "Building Sanity for linux: sudo ./autogen.sh"
	cd ~/$COINDIR
	ls -al
	#sudo chmod 755 -v *.sh
	#sudo chmod 755 -v ./src/Makefile.am
	./autogen.sh
	if [ $? -ne 0 ]; then error "compileSource: ./autogen.sh"; fi

	message "Building Sanity for linux: ./configure ${1} --disable-tests"
	#sudo chmod 755 -v ./configure
	./configure $1 --disable-tests --disable-bench --disable-silent-rules --enable-debug
	if [ $? -ne 0 ]; then error "compileSource: ./configure"; fi

	message "Building Sanity for linux: make clean"
	make clean

	#sudo chmod 755 share/genbuild.sh

	message "Building Sanity for linux: make"
	make
	if [ $? -ne 0 ]; then error "compileSource: make"; fi

  	message "Storing sanityd and sanity-cli to ~/${COINBIN}"
	strip $COINDAEMON
	strip $COINCLI
	make install DESTDIR=~/$COINBIN
	if [ $? -ne 0 ]; then error "compileSource: make install"; fi

	message "Installing sanityd and sanity-cli to ~/${COINCORE}"
	if [ ! -d "~/$COINCORE" ]; then mkdir ~/$COINCORE; fi
	cp -uv ~/$COINBIN/usr/local/bin/sanityd ~/$COINCORE
	cp -uv ~/$COINBIN/usr/local/bin/sanity-cli ~/$COINCORE

  	#sudo ln -s sanityd /usr/bin
	#sudo ln -s sanity-cli /usr/bin
	if [ $? -ne 0 ]; then error "compileSource: copy"; fi

	messagebig "[Step 9/${MAX}] compileSource: Done."
}

createConfig() {
	messagebig "[Step 10/${MAX}] createConfig: Creating sanity.conf"
	mnkey=""
	if [ ! -d "~/$COINCORE" ]; then mkdir ~/$COINCORE; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 10 ; echo)
	rpcpass=$(openssl rand -base64 32)
	#printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "port=$COINPORT" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=$COINRPCPORT" > $CONFILE
	#rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
	#rpcpass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
	#echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}" > ~/$COINCORE/$COINCONFIG
	#echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcport=${COINRPCPORT}\nrpcallowip=127.0.0.1\nrpcthreads=8\nlisten=1\nserver=1\ndaemon=1\nstaking=0\ndiscover=1\nexternalip=${mnip}:${COINPORT}\nmasternode=1\nmasternodeprivkey=${mnkey}" > ~/$COINCORE/$COINCONFIG
	echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}" > ~/$COINCORE/$COINCONFIG

	message "Starting daemon."
  	~/$COINCORE/$COINDAEMON

  	message "Wait 20 seconds for daemon to load..."
  	sleep 20s

	message "Creating masternode key."
	mnkey=$(~/$COINCORE/$COINCLI masternode genkey)

	message "Stopping daemon."
	~/$COINCORE/$COINCLI stop

	message "wait 10 seconds for deamon to stop..."
  	sleep 10s

	sudo rm ~/$COINCORE/$COINCONFIG

	message "Updating ${COINCONFIG}."
	#printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "port=$COINPORT" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=$COINRPCPORT" > $CONFILE
	#echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcport=${COINRPCPORT}\nrpcallowip=127.0.0.1\nrpcthreads=8\nlisten=1\nserver=1\ndaemon=1\nstaking=0\ndiscover=1\nexternalip=${mnip}:${COINPORT}\nmasternode=1\nmasternodeprivkey=${mnkey}" > ~/$COINCORE/$COINCONFIG
	echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcport=${COINRPCPORT}\nrpcallowip=127.0.0.1\nrpcthreads=8\nlisten=1\nserver=1\ndaemon=1\ngen=0\ndiscover=1\nexternalip=${mnip}:${COINPORT}\nmasternode=1\nmasternodeprivkey=${mnkey}" > ~/$COINCORE/$COINCONFIG

	message "Show dir: ls ~/${COINCORE}"
	ls ~/$COINCORE

	message "Show config: cat ~/${$COINCORE}/${$COINCONFIG}"
	cat ~/$COINCORE/$COINCONFIG

	messagebig "[Step 10/${MAX}] createConfig: Done."
}

startWallet() {
	messagebig "[Step 11/${MAX}] startWallet: Starting wallet daemon."

	message "Reseting."
	cd ~/$COINCORE
	sudo rm governance.dat > /dev/null 2>&1
	sudo rm netfulfilled.dat > /dev/null 2>&1
	sudo rm peers.dat > /dev/null 2>&1
	sudo rm -r blocks > /dev/null 2>&1
	sudo rm mncache.dat > /dev/null 2>&1
	sudo rm -r chainstate > /dev/null 2>&1
	sudo rm fee_estimates.dat > /dev/null 2>&1
	sudo rm mnpayments.dat > /dev/null 2>&1
	sudo rm banlist.dat > /dev/null 2>&1

	message "Starting daemon."
	~/$COINCORE/$COINDAEMON -daemon

	messagebig "[Step 11/${MAX}] startWallet: Done. Damon is running."
}

syncWallet() {
    echo
	messagebig "[Step 12/${MAX}] syncWallet: Please wait for wallet to sync..."
    sleep 2
	~/$COINCORE/$COINCLI getinfo
	sleep 2
}

displayPromptToSendFunds() {
	message
	message "The VPS side of your masternode has been installed and is running."
	message "Stop the demon with ~/${COINCORE}/${COINCLI} stop"
	message "Restart the demon with ~/${COINCORE}/${COINDAMON} -daemon"
	message "Check status with ~/${COINCORE}/${COINCLI} -getinfo"
    message " "
	message "Now you need to fund your masternode at your local wallet."
	message "Switch to your local wallet, create a new address and send exactly 10000.00 SANITY to this address."
	message " "
	message "Wait for 15 Confirmations ..."
	message "Get the 'tx' and 'index' for your transaction."
	message " "
	message "Add the following line in your local wallets 'masternode.conf' and replace with 'tx' and 'index'"
    message "mn1 ${mnip}:${COINPORT} ${mnkey} tx index"
    message
    message "Restart your local wallet. Go to the masternode-tab, select your masternode and select 'start'."
}

startInstall() {
	checkForUbuntuVersion
	#createUser
	updateAndUpgrade
	installDependencies
	installFail2Ban
	installFirewall
	createSwap
	cloneGithub
	removeWindowsLinefeeds
	#patchTimestamps
	compileSource $1
	createConfig
	startWallet
	syncWallet
	displayPromptToSendFunds
}

clear
cd

echo
echo -e "--------------------------------------------------------------------"
echo -e "|                                                                  |"
echo -e "|                  ${BOLD}--+-- Sanity Masternode --+--${NONE}                   |"
echo -e "|                                                                  |"
echo -e "|               (c) 2018 The Sanity Core Developers                |"
echo -e "|                                                                  |"
echo -e "--------------------------------------------------------------------"

echo -e "${BOLD}"
read -p "This script will create and setup your Sanity Masternode. Do you wish to continue? (y/n)? " response
echo -e "${NONE}"

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
	#default to --without-gui for masternode
	startInstall --without-gui
else
    echo && echo "Installation cancelled" && echo
fi

#!/bin/sh
#Info: Installs Sanity daemon, Masternode based on privkey, and a simple web monitor.
#Tested OS: 16.04
#TODO: make script less "ubuntu" or add other linux flavors
#TODO: remove dependency on sudo user account to run script (i.e. run as root and specifiy sanity user so sanity user does not require sudo privileges)
#TODO: add specific dependencies depending on build option (i.e. gui requires QT4)

noflags() {
	echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    echo "Usage: install-sanity"
    echo "Example: install-sanity"
    echo "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    exit 1
}

message() {
	echo "╒════════════════════════════════════════════════════════════════════════════════>>"
	echo "| $1"
	echo "╘════════════════════════════════════════════<<<"
}

error() {
	message "An error occured, you must fix it to continue!"
	exit 1
}

prepdependencies() { #TODO: add error detection
	message "Installing Sanity dependencies..."
	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

	sudo apt-get update
	sudo apt-get -y upgrade

	#install deps
	sudo apt-get install dos2unix
	sudo apt-get install curl git ufw
	sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
	sudo apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
	sudo apt-get install -y software-properties-common
	sudo add-apt-repository -y ppa:bitcoin/bitcoin
	sudo apt-get update

	sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
	sudo apt-get install -y libzmq3-dev
	sudo apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
	sudo apt-get install -y libqrencode-dev
	sudo apt-get update
	sudo apt-get -y upgrade

	#sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git software-properties-common
	#sudo add-apt-repository -y ppa:bitcoin/bitcoin
	#sudo apt-get update
	#sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
}

clonerepo() { #TODO: add error detection
	message "Cloning Sanity source from sanity-master repository..."
  	cd ~/
	git clone https://github.com/sanatorium/sanity.git
}

compile() {
	cd sanity #TODO: squash relative path
	message "Preparing to build sanity ..."
	cd src/leveldb && make clean && make libleveldb.a libmemenv.a
	if [ $? -ne 0 ]; then error; fi
	cd ..
	if [ $? -ne 0 ]; then error; fi
	message "Building Sanity ... this may take a few minutes ..."

	sudo ./autogen.sh
	sudo ./configure --without-gui --disable-tests
	sudo make

	if [ $? -ne 0 ]; then error; fi
  message "Installing sanityd and sanity-cli ..."
	sudo make install

  #sudo ln -s sanityd /usr/bin
	#sudo ln -s sanity-cli /usr/bin
  if [ $? -ne 0 ]; then error; fi
}

createconf() {
	#TODO: Can check for flag and skip this

	message "Creating sanity.conf ..."
	MNPRIVKEY=""
	CONFDIR=~/.sanitycore
	CONFILE=$CONFDIR/sanity.conf
	if [ ! -d "$CONFDIR" ]; then mkdir $CONFDIR; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 10 ; echo)
	rpcpass=$(openssl rand -base64 32)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "port=9999" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=9998" > $CONFILE

  sanityd
  message "Wait 20 seconds for daemon to load..."
  sleep 20s
	MNPRIVKEY=$(sanity-cli masternode genkey)

	sanity-cli stop
	message "wait 10 seconds for deamon to stop..."
  sleep 10s
	sudo rm $CONFILE
	message "Updating sanity.conf..."
  printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "port=9999" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=9998" > $CONFILE
}

success() {
	sanityd -daemon
	message "SUCCESS! Sanity daemon. sanity.conf setting below..."
	message "Sanity $mnip:9999 $MNPRIVKEY TXHASH INDEX"
	exit 0
}

install() {
	prepdependencies
	createswap
	clonerepo
	compile $1
	createconf
	success
}

#default to --without-gui
install --without-gui

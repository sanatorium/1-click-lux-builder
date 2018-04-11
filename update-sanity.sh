#!/bin/bash

cd ~/
sudo sanity-cli stop
sudo rm -fr sanity/
sudo git clone https://github.com/sanatorium/sanity
cd sanity/src/leveldb
make clean && sudo chmod +x build_detect_platform && make libleveldb.a libmemenv.a
cd ..
sudo ./autogen.sh
sudo ./configure --without-gui --disable-tests
sudo make
sudo make install
sudo sanityd -daemon

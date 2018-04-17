#!/bin/bash

COINCORE=.sanitycore
COINPORT=9999
COINRPCPORT=9998
COINDAEMON=sanityd
COINCLI=sanity-cli

cd ~/
mkdir web
cd web
wget
wget
#todo
(crontab -l 2>/dev/null; echo "* * * * * echo MN Count:  > ~/web/stats.txt; ~/${COINCORE}/${COINCLI} masternode count >> ~/web/stats.txt; ~/${COINCORE}/${COINCLI} getinfo >> ~/web/stats.txt") | crontab -
mnip=$(curl -s https://api.ipify.org)
python3 -m http.server 8000 --bind $mnip 2>/dev/null &
echo "Your Sanity Masternode Web Server Started!  You can now access your stats page at http://$mnip:8000"

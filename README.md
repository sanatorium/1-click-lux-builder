## build scripts
===============

### install masternode without wallet-functionality (vps-part on linux):
    sudo apt install -y git
    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./sanity.sh user

    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./sanity.sh deps
    ./sanity.sh firewall
    ./sanity.sh swap
    ./sanity.sh clone
    ./sanity.sh compilemn
    ./sanity.sh configmn
    ./sanity.sh startmn

### install daemon with wallet-functionality (on linux):
    sudo apt install -y git
    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./sanity.sh user

    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./sanity.sh deps
    ./sanity.sh firewall
    ./sanity.sh swap
    ./sanity.sh clone
    ./sanity.sh compilewallet
    ./sanity.sh startwallet

### cross-compile (on linux) wallet for windows:
    sudo apt install -y git
    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./sanity.sh user

    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./sanity.sh deps
    ./sanity.sh firewall
    ./sanity.sh swap
    ./sanity.sh clone
    ./sanity.sh crosscompiledeps
    ./sanity.sh crosscompiledepends
    ./sanity.sh crosscompilebuild

### list all script functions
    sudo apt install -y git
    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./sanity.sh

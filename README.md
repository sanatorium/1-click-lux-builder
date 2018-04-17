# build scripts
===============

# install masternode without wallet-functionality (vps-part on linux):
    sudo apt install -y git
    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./install-sanitymn.sh user

    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./install-sanitymn.sh deps
    ./install-sanitymn.sh firewall
    ./install-sanitymn.sh swap
    ./install-sanitymn.sh clone
    ./install-sanitymn.sh compilemn
    ./install-sanitymn.sh configmn
    ./install-sanitymn.sh startmn

# install daemon with wallet-functionality (on linux):
    sudo apt install -y git
    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./install-sanitymn.sh user

    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./install-sanitymn.sh deps
    ./install-sanitymn.sh firewall
    ./install-sanitymn.sh swap
    ./install-sanitymn.sh clone
    ./install-sanitymn.sh compilewallet
    ./install-sanitymn.sh startwallet

# cross-compile (on linux) wallet for windows:
    sudo apt install -y git
    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./install-sanitymn.sh user

    git clone https://github.com/sanatorium/sanity-scripts.git
    cd sanity-scripts
    ./install-sanitymn.sh deps
    ./install-sanitymn.sh firewall
    ./install-sanitymn.sh swap
    ./install-sanitymn.sh clone
    ./install-sanitymn.sh crosscompiledeps
    ./install-sanitymn.sh crosscompiledepends
    ./install-sanitymn.sh crosscompilebuild

#!/bin/bash

#essentials
sudo apt install -qqy build-essential git 
sudo apt install -qqy libpcap-dev #required for naabu
sudo apt install -qqy zip unzip
sudo apt install -qqy python3-pip
sudo apt install -qqy ruby-rubygems

# install go if doesn't exist
if [[ -z "$GOPATH" ]]; then
    echo "go not found..."
    PS3="Install go now : "
    choices=("yes" "no")
    select choice in "${choices[@]}"; do
        case $choice in
            yes)
                echo "Installing go now..."
                
                wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz

                # remove old go if exist
                sudo rm -rf /usr/local/go
                sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz

                echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
                echo 'export GOPATH=$HOME/go' >> ~/.bashrc
                echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc

                rm -f go1.20.1.linux-amd64.tar.gz
                sleep 5
                source ~/.bashrc
                echo "Installed $(go version)"

                break
                ;;
            no)
                echo "Please install go and rerun the script..."
                echo "Aborting..."
                exit 1
                ;;
        esac
    done
else
    echo "$(go version) is found..."
    echo "Proceeding with installation..."
fi

#install rust
#curl https://sh.rustup.rs -sSf | sh

# utils
sudo apt -qqy install jq proxychains4 tor nmap

#unfurl
go install github.com/tomnomnom/unfurl@latest

#amass
go install -v github.com/OWASP/Amass/v3/...@master
#httprobe
go install github.com/tomnomnom/httprobe@latest
#httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
#nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

#ports
#nabbu
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
#rustscan
#TODO: install this only if not installed
#cargo install rustscan

# content discovery
if [[ -z $(which feroxbuster) ]]; then
    curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/master/install-nix.sh | bash
    sudo mv feroxbuster /usr/local/bin
fi

# parsings JS for endpoints
cd ~/tools
if [[ ! -d waymore ]]; then
    git clone https://github.com/xnl-h4ck3r/waymore.git
    cd waymore
    sudo python3 setup.py install
fi

cd ~/tools
if [[ ! -d xnLinkFinder ]]; then
    git clone https://github.com/xnl-h4ck3r/xnLinkFinder.git
    cd xnLinkFinder
    sudo python3 setup.py install
fi

# wordpress
sudo gem install wpscan

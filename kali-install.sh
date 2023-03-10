#!/bin/bash

#essentials
sudo apt install -qqy ruby-rubygems

#install rust
sudo apt install -qqy cargo

# utils
sudo apt -qqy install jq 

#unfurl
go install github.com/tomnomnom/unfurl@latest

#httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

#rustscan
cargo install rustscan

#webanalyze
go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest

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


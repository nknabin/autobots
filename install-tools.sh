#!/bin/bash

echo "running setup-env.."
source ./setup-env.sh

# create directories
if [ ! -d ~/tools ]; then
	mkdir ~/tools
fi

# install go if doesn't exist
if [[ -z "$GOPATH" ]]; then
	echo "go not found.."

	PS3="Install go now : "
	choices=("yes" "no")

	select choice in "${choices[@]}"; do
		case $choice in
		yes)
			echo "Installing go now..."

			wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz

			# remove old go if exist
			sudo rm -rf /usr/local/go
			sudo tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz

			echo "export GOROOT=/usr/local/go" >> ~/.bashrc
			echo "export GOPATH=$HOME/go" >> ~/.bashrc
			echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.bashrc

			rm -f go1.20.1.linux-amd64.tar.gz
			sleep 5
			source $HOME/.bashrc
			echo "Installed $(go version)"

			break
			;;
		no)
			echo "Please install go and rerun the script.."
			echo "Aborting.."
			exit 1
			;;
		esac
	done
else
	echo "$(go version) is found.."
	echo "Proceeding with installation.."
fi

# install ruby with rbenv
echo "Installing rbenv and ruby.."
if [[ ! -d $HOME/.rbenv ]]; then
	git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
	mkdir -p ~/.rbenv/plugins
	git clone https://github.com/rbenv/ruby-build.git $HOME/.rbenv/plugins/ruby-build
	echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc

	sleep 5

	. ~/.bashrc
	rbenv install $(rbenv install -l|head -n 1)
fi

# essentials
sudo $package_manager_install jq nmap tor whois
#TODO dig, nslookup, whois

# dependencies
sudo apt install -y libpcap-dev

# git clones
cd ~/tools
git clone https://github.com/danielmiessler/SecLists.git
git clone https://github.com/jobertabma/relative-url-extractor

# utils
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/unfurl@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/ffuf/ffuf/v2@latest
go install github.com/projectdiscovery/notify/cmd/notify@latest

# recon
go install software.sslmate.com/src/certspotter/cmd/certspotter@latest
go install github.com/owasp-amass/amass/v4/...@master
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

go install github.com/rverton/webanalyze/cmd/webanalyze@latest
if [ ! -f ~/technologies.json ]; then
	cd $HOME && wget https://raw.githubusercontent.com/rverton/webanalyze/master/technologies.json
fi

go install github.com/tomnomnom/waybackurls@latest

if [[ -z $(command -v feroxbuster) ]]; then
	curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash -s $HOME/bin
fi

# wordpress
gem install wpscan

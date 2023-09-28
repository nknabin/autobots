#!/bin/bash

echo "running setup-env.."
source ./setup-env.sh

# install go if doesn't exist
if [[ -z "$GO_HOME" ]]; then
	echo "go not found.."

	PS3="Install go now : "
	choices=("yes" "no")

	select choice in "${choices[@]}"; do
		case $choice in
		yes)
			echo "Installing go now..."

			wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz

			# remove old go if exist
			sudo rm -rf /usr/local/go
			sudo tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz

			echo "export GO_ROOT=/usr/local/go" >> ~/.bashrc
			echo "export GO_PATH=$HOME/go" >> ~/.bashrc
			echo "export PATH=$GO_PATH/bin:$GO_ROOT/bin:$PATH" >> ~/.bashrc

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
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv
	echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >>~/.bashrc
	sleep 5
	source $HOME/.bashrc
	git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
	#TODO install ruby with rbenv
fi

# essentials
sudo $package_manager_install jq nmap tor

# utils
go install github.com/tomnomnom/unfurl@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/ffuf/ffuf/v2@latest

# recon
go install software.sslmate.com/src/certspotter/cmd/certspotter@latest
go install github.com/owasp-amass/amass/v4/...@master
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

go install github.com/rverton/webanalyze/cmd/webanalyze@latest
cd $HOME && wget https://raw.githubusercontent.com/rverton/webanalyze/master/technologies.json

go install github.com/tomnomnom/waybackurls@latest

if [[ -z $(command -v feroxbuster) ]]; then
	curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash -s $HOME/bin
fi

# wordpress
gem install wpscan

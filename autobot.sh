#!/bin/bash

#set -xe

#TODO run first time to set up env
source $HOME/code/reconbot/utils.sh

getTargets() {
	#TODO filter from outscope.txt
	pwd

	if [[ ! -f inScope.txt || $(wc -l inScope.txt | cut -d " " -f 1) == 0 ]]; then
		echo "No inscope URLs found.."
		echo "Creating an inscope.txt file.."
		touch inScope.txt

		echo "Please select an option:"
		echo "[u] Enter a url"
		echo "[e] Open with nano"
		echo "[v] Open with vim"
		echo "[n] No, exit"
		read -n 1 -r inScopeChoice

		if [[ $inScopeChoice == "u" ]]; then
			read -p "Enter a url: " -r inScopeUrl
			echo $inScopeUrl >> inScope.txt
		elif [[ $inScopeChoice == "e" ]]; then
			echo "Opening with nano.."
			nano inScope.txt
		elif [[ $inScopeChoice == "v" ]]; then
			echo "Opening with vim.."
			vim inScope.txt
		else 
			echo "No target URLs defined. Exiting.."
			exit 1
		fi

		echo "No outScope.txt file found. All urls will be assumed in scope without this file."
		echo "Creating outScope.txt"
		touch outScope.txt

		echo "Please select an option:"
		echo "[u] Create and enter a URL"
		echo "[e] Open with nano"
		echo "[v] Open with vim"
		echo "[n] No, assume all URLs are in scope."
		read -n 1 -r outScopeChoice

		if [[ $outScopeChoice == "u" ]]; then
			read -p "Enter a url: " -r outScopeUrl
			echo $outScopeUrl >> outScope.txt
		elif [[ $outScopeChoice == "e" ]]; then
			echo "Opening with nano.."
			nano outScope.txt
		elif [[ $outScopeChoice == "v" ]]; then
			echo "Opening with vim.."
			vim outScope.txt
		else
			echo "All URLs will be assumed to be in scope."
			exit 1
		fi
	fi

	cat inScope.txt | unfurl -u domains > initialUrls.txt
}

getSubDomains() {
	cat initialUrls.txt | while read line || [[ -n $line ]]; do crtshApi $line >> urls.txt; done
	cat initialUrls.txt | while read line || [[ -n $line ]]; do ctSearchApi $line >> urls.txt; done
	sort -u urls.txt -o urls.txt

	amass enum -passive -df initialUrls.txt >> amass.txt

	cat initialUrls.txt urls.txt amass.txt | sort -u | httprobe > liveUrls.txt
	cat liveUrls.txt | unfurl -u domains > liveDomains.txt
}

getTechProfile() {
	webanalyze -hosts liveDomains.txt -crawl 5 -output csv -redirect 1 -worker 50 > webanalyze.csv
}

scanVuln() {
	nuclei -l liveUrls.txt -o nuclei.txt
	grep -vw info nuclei.txt > nuclei-noinfo.txt
}

scanPorts() {
	#nmap
	# this takes a long time so choose a target for this
	# loop for all files nmap -A -F -T1 10.10.10.223 -v 
	#rustscan
	#rustscan -b 2000 -a domains.txt -- -A -sC
	#nabbu
	naabu -list liveDomains.txt -p 1-10000 -json -o naabu.json
}

scanHttpx() {
	cat liveDomains.txt | httpx -title -wc -sc -cl -ct -method -ip -web-server -location -fr -threads 200 -p 8000,8080,843,443,80,8008,3000,5000,9000,900,7070,9200,15672,9004 -o httpx-out.txt
}

probeEndpoints() {
	cat liveDomains.txt | python3 ~/tools/waymore/waymore.py
	cat liveDomains.txt | python3 ~/tools/xnLinkFinder/xnLinkFinder.py -sf $target.* -o xnlinks.txt
}

main() {
	echo "collecting targets"
	getTargets

	echo "collecting subdomains.."
	getSubDomains $program

	echo "profiling tech.."
	getTechProfile

	echo "scanning for vulnerabilites with nuclei.."
	scanVuln

	echo "scanning ports.."
	scanPorts

	echo "running httpx.."
	scanHttpx

	echo "probing js for endpoints..."
	probeEndpoints
}

program=$1
echo "Program = $program"
[[ ! -d ~/data/$program ]] && mkdir -pv ~/data/$program
cd ~/data/$program

#TODO screenshot
# start
main $program

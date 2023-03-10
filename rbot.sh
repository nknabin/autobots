#!/bin/bash

# Reconbot
# Author: lazyhacker
# Created: 3/5/2023

source ~/tools/reconbot/utils.sh

getTargets() {
    #todo: filter from outscope.txt
    pwd
    cp inscope.txt target.txt
}

recon() {
    cat target.txt | while read line || [[ -n $line ]]; do crtsh $line >> urls.txt; done
    cat target.txt | while read line || [[ -n $line ]]; do certspotter $line >> urls.txt; done
    amass enum -passive -df target.txt >> amass.txt

    sort -u urls.txt -o urls.txt
    cat target.txt amass.txt urls.txt | sort -u | httprobe > httprobe.txt
    cat httprobe.txt | unfurl -u domains > domains.txt
}

techprofile() {
    webanalyze -hosts domains.txt -crawl 5 -output csv -redirect 1 -worker 50 > webanalyze.csv
}

scan_vuln() {
    nuclei -l httprobe.txt -o nuclei.txt
    grep -vw info nuclei.txt > nuclei-noinfo.txt
}

scan_ports() {
    #nmap
    #rustscan
    #rustscan -b 2000 -a domains.txt -- -A -sC
    #nabbu
    naabu -list domains.txt -p 1-10000 -json -o naabu.json
}

httpx_probe() {
    cat domains.txt | httpx -title -wc -sc -cl -ct -method -ip -web-server -location -fr -threads 200 -p 8000,8080,843,443,80,8008,3000,5000,9000,900,7070,9200,15672,9004 -o httpx-out.txt
}

probe_endpoints() {
    cat domains.txt | python3 ~/tools/waymore/waymore.py 
    cat domains.txt | python3 ~/tools/xnLinkFinder/xnLinkFinder.py -sf $target.* -o xnlinks.txt
}

main() {
    #getTargets

    echo "collecting subdomains..."
    #recon $program

    echo "profiling tech..."
    #techprofile

    echo "scanning for vulnerabilites with nuclei..."
    #scan_vuln

    echo "scanning ports..."
    #scan_ports

    echo "running httpx..."
    httpx_probe

    #echo "probing js for endpoints..."
    #probe_endpoints
}

program=$1
echo "Program = $program"
[[ ! -d ~/recondata/$program ]] && mkdir -pv ~/recondata/$program
cd ~/recondata/$program

main $program

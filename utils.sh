#!/bin/bash

# crtsh
crtsh() {
    curl -s https://crt.sh/?q=%.$1 | grep ">*.$1" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$1" | sort -u | awk 'NF'
}

# certspotter
certspotter() {
    proxychains curl -s https://api.certspotter.com/v1/issuances\?domain\=$1\&include_subdomains\=true\&expand\=dns_names\&expand\=issuer\&expand\=revocation | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1
}

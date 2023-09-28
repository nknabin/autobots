#!/bin/bash

# set up environment for running other scrips
# identify and set package managers and system architecture

declare -A pakMan;
declare -A pakManInstall;
pakMan[/etc/debian_version]="apt-get"
pakMan[/etc/alpine-release]="apk"
pakMan[/etc/centos-release]="yum"
pakMan[/etc/fedora-release]="dnf"
pakMan[/etc/arch-release]="pacman"
pakManInstall[/etc/debian_version]="apt-get install"
pakManInstall[/etc/alpine-release]="apk install"
pakManInstall[/etc/centos-release]="yum install"
pakManInstall[/etc/fedora-release]="dnf install"
pakManInstall[/etc/arch-release]="pacman -S --needed"

for f in ${!pakMan[@]}
do
    if [[ -f $f ]]; then
        export package_manager=${pakMan[$f]}
    fi
done

for f in ${!pakManInstall[@]}
do
    if [[ -f $f ]]; then
        export package_manager_install=${pakManInstall[$f]}
    fi
done

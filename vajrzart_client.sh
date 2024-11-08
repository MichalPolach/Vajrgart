#!/bin/bash

# Basic error handling
set -euo pipefail

# Function to check if script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERROR: This script must be run as root!"
        exit 1
    fi
}

check_dep() {
    if ! command -v dialog >/dev/null 2>&1; then
        apt-get update >/dev/null 2>&1
        apt-get install -y dialog >/dev/null 2>&1
    fi
}

# Function to install WireGuard if not already installed
install_wireguard() {
    if ! command -v wg-quick >/dev/null 2>&1; then
        dialog --title "WireGuard Installation" \
               --yesno "WireGuard is not installed. Do you want to install it?" 8 50
        
        response=$?
        
        if [ $response -eq 0 ]; then
            (
                echo "10" ; echo "XXX"
                echo "Updating package lists..."
                echo "XXX"
                
                apt-get update >/dev/null 2>&1
                
                echo "40" ; echo "XXX"
                echo "Installing WireGuard..."
                echo "XXX"
                
                apt-get install -y wireguard >/dev/null 2>&1
                
                echo "80" ; echo "XXX"
                echo "Finalizing installation..."
                echo "XXX"
                
                sleep 1
                
                echo "100" ; echo "XXX"
                echo "Installation complete!"
                echo "XXX"
            ) | dialog --title "WireGuard Installation" --gauge "Starting installation..." 8 50 0
            
            sleep 2
        fi
    else
        dialog --infobox "WireGuard is already installed" 8 50
        sleep 2
    fi
}

# Main script starts here
check_root

if [ -z "${1:-}" ]; then
    echo "ERROR: Please provide client configuration file as an argument!"
    exit 1
fi

check_dep
install_wireguard

wireguard_dir="/etc/wireguard"

# copy the configuration files to the WireGuard directory
mv $1 "$wireguard_dir"/wg0.conf

# Create and start the WireGuard interface
dialog --infobox "Starting WireGuard interface..." 8 50
sleep 2
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

dialog --title "Setup Wajrgard" \
       --msgbox "WireGuard setup completed successfully\n\n
                Configuration file: /etc/wireguard/wg0.conf" 12 50
